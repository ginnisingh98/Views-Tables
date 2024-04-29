--------------------------------------------------------
--  DDL for Package Body HRI_OPL_WRKFC_EVT_MGRH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_WRKFC_EVT_MGRH" AS
/* $Header: hriowevtmgr.pkb 120.4.12000000.2 2007/04/12 13:23:24 smohapat noship $ */

  TYPE g_number_tab_type   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_date_tab_type     IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

  g_tab_sup_person_fk               g_number_tab_type;
  g_tab_sup_mngrsc_fk               g_number_tab_type;
  g_tab_sup_directs_only_flag       g_varchar2_tab_type;
  g_tab_time_day_mnth_start_fk      g_date_tab_type;
  g_tab_time_day_mnth_end_fk        g_date_tab_type;
  g_tab_time_month_snp_fk           g_number_tab_type;
  g_tab_job_function_fk             g_varchar2_tab_type;
  g_tab_job_family_fk               g_varchar2_tab_type;
  g_tab_geo_country_fk              g_varchar2_tab_type;
  g_tab_prfm_perfband_fk            g_number_tab_type;
  g_tab_pow_powband_fk              g_number_tab_type;
  g_tab_ptyp_wrktyp_fk              g_varchar2_tab_type;
  g_tab_cur_currency_fk             g_varchar2_tab_type;
  g_tab_headcount_start             g_number_tab_type;
  g_tab_headcount_end               g_number_tab_type;
  g_tab_headcount_hire              g_number_tab_type;
  g_tab_headcount_term              g_number_tab_type;
  g_tab_headcount_sep_vol           g_number_tab_type;
  g_tab_headcount_sep_invol         g_number_tab_type;
  g_tab_headcount_prmtn             g_number_tab_type;
  g_tab_fte_start                   g_number_tab_type;
  g_tab_fte_end                     g_number_tab_type;
  g_tab_fte_hire                    g_number_tab_type;
  g_tab_fte_term                    g_number_tab_type;
  g_tab_fte_sep_vol                 g_number_tab_type;
  g_tab_fte_sep_invol               g_number_tab_type;
  g_tab_fte_prmtn                   g_number_tab_type;
  g_tab_count_pasg_end              g_number_tab_type;
  g_tab_count_pasg_hire             g_number_tab_type;
  g_tab_count_pasg_term             g_number_tab_type;
  g_tab_count_pasg_sep_vol          g_number_tab_type;
  g_tab_count_pasg_sep_invol        g_number_tab_type;
  g_tab_count_asg_end               g_number_tab_type;
  g_tab_count_asg_hire              g_number_tab_type;
  g_tab_count_asg_term              g_number_tab_type;
  g_tab_count_asg_sep_vol           g_number_tab_type;
  g_tab_count_asg_sep_invol         g_number_tab_type;
  g_tab_count_asg_prmtn             g_number_tab_type;
  g_tab_pow_days_on_end_date        g_number_tab_type;
  g_tab_pow_months_on_end_date      g_number_tab_type;
  g_tab_days_since_last_prmtn       g_number_tab_type;
  g_tab_months_since_last_prmtn     g_number_tab_type;
  g_tab_anl_slry_start              g_number_tab_type;
  g_tab_anl_slry_end                g_number_tab_type;
  g_tab_employee_ind                g_number_tab_type;
  g_tab_contingent_ind              g_number_tab_type;
  g_tab_adt_pow_band                g_number_tab_type;
  g_row_count                       NUMBER;

  -- End of time
  g_end_of_time    DATE := hr_general.end_of_time;

  -- Global HRI Multithreading Array
  g_mthd_action_array       HRI_ADM_MTHD_ACTIONS%rowtype;

  -- Global parameters
  g_refresh_start_date      DATE;
  g_refresh_to_date         DATE;
  g_full_refresh            VARCHAR2(30);
  g_sysdate                 DATE;
  g_user                    NUMBER;
  g_dbi_start_date          DATE;

  -- Number of quarters to process
  g_no_qtrs_to_process      PLS_INTEGER;


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

  l_dbi_collection_start_date   DATE;
  l_first_qtr_start_date        DATE;
  l_last_qtr_start_date         DATE;

BEGIN

-- If parameters haven't already been set, then set them
  IF (g_refresh_start_date IS NULL OR
      p_mthd_stage_code = 'PRE_PROCESS') THEN

    l_dbi_collection_start_date :=
           hri_oltp_conc_param.get_date_parameter_value
            (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
             p_process_table_name => 'HRI_MDS_WRKFC_MGRH_C01_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh :=
           hri_oltp_conc_param.get_parameter_value
            (p_parameter_name     => 'FULL_REFRESH',
             p_process_table_name => 'HRI_MDS_WRKFC_MGRH_C01_CT');

      -- Log defaulted parameters so the slave processes pick up
      hri_opl_multi_thread.update_parameters
       (p_mthd_action_id    => p_mthd_action_id,
        p_full_refresh      => g_full_refresh,
        p_global_start_date => l_dbi_collection_start_date);

    END IF;

    g_mthd_action_array    := hri_opl_multi_thread.get_mthd_action_array
                               (p_mthd_action_id);
    g_refresh_start_date   := g_mthd_action_array.collect_from_date;
    g_refresh_to_date      := g_mthd_action_array.collect_to_date;
    g_full_refresh         := g_mthd_action_array.full_refresh_flag;
    g_sysdate              := sysdate;
    g_user                 := fnd_global.user_id;
    g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;

    -- Calculate number of quarters to process
    l_first_qtr_start_date := trunc(g_dbi_start_date, 'Q');
    l_last_qtr_start_date  := trunc(g_refresh_to_date, 'Q');
    g_no_qtrs_to_process := (MONTHS_BETWEEN(l_last_qtr_start_date,
                                            l_first_qtr_start_date) / 3) + 1;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:    N/A');

  END IF;

END set_parameters;

PROCEDURE bulk_insert_rows IS

BEGIN

  IF g_row_count > 0 THEN

    FORALL i IN 1..g_row_count
      INSERT INTO hri_mds_wrkfc_mgrh_c01_ct
       (sup_person_fk
       ,sup_mngrsc_fk
       ,sup_directs_only_flag
       ,time_day_mnth_start_fk
       ,time_day_mnth_end_fk
       ,time_month_snp_fk
       ,job_function_fk
       ,job_family_fk
       ,geo_country_fk
       ,prfm_perfband_fk
       ,pow_powband_fk
       ,ptyp_wrktyp_fk
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
       ,adt_pow_band
       ,creation_date
       ,created_by
       ,last_updated_by
       ,last_update_login
       ,last_update_date)
       VALUES
       (g_tab_sup_person_fk(i)
       ,g_tab_sup_mngrsc_fk(i)
       ,g_tab_sup_directs_only_flag(i)
       ,g_tab_time_day_mnth_start_fk(i)
       ,g_tab_time_day_mnth_end_fk(i)
       ,g_tab_time_month_snp_fk(i)
       ,g_tab_job_function_fk(i)
       ,g_tab_job_family_fk(i)
       ,g_tab_geo_country_fk(i)
       ,g_tab_prfm_perfband_fk(i)
       ,g_tab_pow_powband_fk(i)
       ,g_tab_ptyp_wrktyp_fk(i)
       ,g_tab_cur_currency_fk(i)
       ,g_tab_headcount_start(i)
       ,g_tab_headcount_end(i)
       ,g_tab_headcount_hire(i)
       ,g_tab_headcount_term(i)
       ,g_tab_headcount_sep_vol(i)
       ,g_tab_headcount_sep_invol(i)
       ,g_tab_headcount_prmtn(i)
       ,g_tab_fte_start(i)
       ,g_tab_fte_end(i)
       ,g_tab_fte_hire(i)
       ,g_tab_fte_term(i)
       ,g_tab_fte_sep_vol(i)
       ,g_tab_fte_sep_invol(i)
       ,g_tab_fte_prmtn(i)
       ,g_tab_count_pasg_end(i)
       ,g_tab_count_pasg_hire(i)
       ,g_tab_count_pasg_term(i)
       ,g_tab_count_pasg_sep_vol(i)
       ,g_tab_count_pasg_sep_invol(i)
       ,g_tab_count_asg_end(i)
       ,g_tab_count_asg_hire(i)
       ,g_tab_count_asg_term(i)
       ,g_tab_count_asg_sep_vol(i)
       ,g_tab_count_asg_sep_invol(i)
       ,g_tab_count_asg_prmtn(i)
       ,g_tab_pow_days_on_end_date(i)
       ,g_tab_pow_months_on_end_date(i)
       ,g_tab_days_since_last_prmtn(i)
       ,g_tab_months_since_last_prmtn(i)
       ,g_tab_anl_slry_start(i)
       ,g_tab_anl_slry_end(i)
       ,g_tab_employee_ind(i)
       ,g_tab_contingent_ind(i)
       ,g_tab_adt_pow_band(i)
       ,g_sysdate
       ,g_user
       ,g_user
       ,g_user
       ,g_sysdate);

    g_row_count := 0;
    commit;

  END IF;

END bulk_insert_rows;

PROCEDURE insert_row
   (p_sup_person_fk             IN NUMBER
   ,p_sup_mngrsc_fk             IN NUMBER
   ,p_sup_directs_only_flag     IN VARCHAR2
   ,p_time_day_mnth_start_fk    IN DATE
   ,p_time_day_mnth_end_fk      IN DATE
   ,p_time_month_snp_fk         IN NUMBER
   ,p_job_function_fk           IN VARCHAR2
   ,p_job_family_fk             IN VARCHAR2
   ,p_geo_country_fk            IN VARCHAR2
   ,p_prfm_perfband_fk          IN NUMBER
   ,p_pow_powband_fk            IN NUMBER
   ,p_ptyp_wrktyp_fk            IN VARCHAR2
   ,p_cur_currency_fk           IN VARCHAR2
   ,p_headcount_start           IN NUMBER
   ,p_headcount_end             IN NUMBER
   ,p_headcount_hire            IN NUMBER
   ,p_headcount_term            IN NUMBER
   ,p_headcount_sep_vol         IN NUMBER
   ,p_headcount_sep_invol       IN NUMBER
   ,p_headcount_prmtn           IN NUMBER
   ,p_fte_start                 IN NUMBER
   ,p_fte_end                   IN NUMBER
   ,p_fte_hire                  IN NUMBER
   ,p_fte_term                  IN NUMBER
   ,p_fte_sep_vol               IN NUMBER
   ,p_fte_sep_invol             IN NUMBER
   ,p_fte_prmtn                 IN NUMBER
   ,p_count_pasg_end            IN NUMBER
   ,p_count_pasg_hire           IN NUMBER
   ,p_count_pasg_term           IN NUMBER
   ,p_count_pasg_sep_vol        IN NUMBER
   ,p_count_pasg_sep_invol      IN NUMBER
   ,p_count_asg_end             IN NUMBER
   ,p_count_asg_hire            IN NUMBER
   ,p_count_asg_term            IN NUMBER
   ,p_count_asg_sep_vol         IN NUMBER
   ,p_count_asg_sep_invol       IN NUMBER
   ,p_count_asg_prmtn           IN NUMBER
   ,p_pow_days_on_end_date      IN NUMBER
   ,p_pow_months_on_end_date    IN NUMBER
   ,p_days_since_last_prmtn     IN NUMBER
   ,p_months_since_last_prmtn   IN NUMBER
   ,p_anl_slry_start            IN NUMBER
   ,p_anl_slry_end              IN NUMBER
   ,p_employee_ind              IN NUMBER
   ,p_contingent_ind            IN NUMBER
   ,p_adt_pow_band              IN NUMBER) IS

BEGIN

  g_row_count := g_row_count + 1;
  g_tab_sup_person_fk(g_row_count) := p_sup_person_fk;
  g_tab_sup_mngrsc_fk(g_row_count) := p_sup_mngrsc_fk;
  g_tab_sup_directs_only_flag(g_row_count) := p_sup_directs_only_flag;
  g_tab_time_day_mnth_start_fk(g_row_count) := p_time_day_mnth_start_fk;
  g_tab_time_day_mnth_end_fk(g_row_count) := p_time_day_mnth_end_fk;
  g_tab_time_month_snp_fk(g_row_count) := p_time_month_snp_fk;
  g_tab_job_function_fk(g_row_count) := p_job_function_fk;
  g_tab_job_family_fk(g_row_count) := p_job_family_fk;
  g_tab_geo_country_fk(g_row_count) := p_geo_country_fk;
  g_tab_prfm_perfband_fk(g_row_count) := p_prfm_perfband_fk;
  g_tab_pow_powband_fk(g_row_count) := p_pow_powband_fk;
  g_tab_ptyp_wrktyp_fk(g_row_count) := p_ptyp_wrktyp_fk;
  g_tab_cur_currency_fk(g_row_count) := p_cur_currency_fk;
  g_tab_headcount_start(g_row_count) := p_headcount_start;
  g_tab_headcount_end(g_row_count) := p_headcount_end;
  g_tab_headcount_hire(g_row_count) := p_headcount_hire;
  g_tab_headcount_term(g_row_count) := p_headcount_term;
  g_tab_headcount_sep_vol(g_row_count) := p_headcount_sep_vol;
  g_tab_headcount_sep_invol(g_row_count) := p_headcount_sep_invol;
  g_tab_headcount_prmtn(g_row_count) := p_headcount_prmtn;
  g_tab_fte_start(g_row_count) := p_fte_start;
  g_tab_fte_end(g_row_count) := p_fte_end;
  g_tab_fte_hire(g_row_count) := p_fte_hire;
  g_tab_fte_term(g_row_count) := p_fte_term;
  g_tab_fte_sep_vol(g_row_count) := p_fte_sep_vol;
  g_tab_fte_sep_invol(g_row_count) := p_fte_sep_invol;
  g_tab_fte_prmtn(g_row_count) := p_fte_prmtn;
  g_tab_count_pasg_end(g_row_count) := p_count_pasg_end;
  g_tab_count_pasg_hire(g_row_count) := p_count_pasg_hire;
  g_tab_count_pasg_term(g_row_count) := p_count_pasg_term;
  g_tab_count_pasg_sep_vol(g_row_count) := p_count_pasg_sep_vol;
  g_tab_count_pasg_sep_invol(g_row_count) := p_count_pasg_sep_invol;
  g_tab_count_asg_end(g_row_count) := p_count_asg_end;
  g_tab_count_asg_hire(g_row_count) := p_count_asg_hire;
  g_tab_count_asg_term(g_row_count) := p_count_asg_term;
  g_tab_count_asg_sep_vol(g_row_count) := p_count_asg_sep_vol;
  g_tab_count_asg_sep_invol(g_row_count) := p_count_asg_sep_invol;
  g_tab_count_asg_prmtn(g_row_count) := p_count_asg_prmtn;
  g_tab_pow_days_on_end_date(g_row_count) := p_pow_days_on_end_date;
  g_tab_pow_months_on_end_date(g_row_count) := p_pow_months_on_end_date;
  g_tab_days_since_last_prmtn(g_row_count) := p_days_since_last_prmtn;
  g_tab_months_since_last_prmtn(g_row_count) := p_months_since_last_prmtn;
  g_tab_anl_slry_start(g_row_count) := p_anl_slry_start;
  g_tab_anl_slry_end(g_row_count) := p_anl_slry_end;
  g_tab_employee_ind(g_row_count) := p_employee_ind;
  g_tab_contingent_ind(g_row_count) := p_contingent_ind;
  g_tab_adt_pow_band(g_row_count) := p_adt_pow_band;

END insert_row;


-- ----------------------------------------------------------------------------
-- Processes snapshot in full refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_snapshot(p_manager_id     IN NUMBER,
                           p_snapshot_date  IN DATE) IS

  CURSOR snp_csr(v_month_id  IN NUMBER) IS
  SELECT
   tab.sup_person_fk
  ,tab.sup_mngrsc_fk
  ,tab.sup_directs_only_flag
  ,tab.time_day_mnth_start_fk
  ,tab.time_day_mnth_end_fk
  ,tab.time_month_snp_fk
  ,tab.job_function_fk
  ,tab.job_family_fk
  ,tab.geo_country_fk
  ,tab.prfm_perfband_fk
  ,tab.pow_powband_fk
  ,tab.ptyp_wrktyp_fk
  ,tab.cur_currency_fk
  ,SUM(tab.headcount_start)         headcount_start
  ,SUM(tab.headcount_end)           headcount_end
  ,SUM(tab.headcount_hire)          headcount_hire
  ,SUM(tab.headcount_term)          headcount_term
  ,SUM(tab.headcount_sep_vol)       headcount_sep_vol
  ,SUM(tab.headcount_sep_invol)     headcount_sep_invol
  ,SUM(tab.headcount_prmtn)         headcount_prmtn
  ,SUM(tab.fte_start)               fte_start
  ,SUM(tab.fte_end)                 fte_end
  ,SUM(tab.fte_hire)                fte_hire
  ,SUM(tab.fte_term)                fte_term
  ,SUM(tab.fte_sep_vol)             fte_sep_vol
  ,SUM(tab.fte_sep_invol)           fte_sep_invol
  ,SUM(tab.fte_prmtn)               fte_prmtn
  ,SUM(tab.count_pasg_end)          count_pasg_end
  ,SUM(tab.count_pasg_hire)         count_pasg_hire
  ,SUM(tab.count_pasg_term)         count_pasg_term
  ,SUM(tab.count_pasg_sep_vol)      count_pasg_sep_vol
  ,SUM(tab.count_pasg_sep_invol)    count_pasg_sep_invol
  ,SUM(tab.count_asg_end)           count_asg_end
  ,SUM(tab.count_asg_hire)          count_asg_hire
  ,SUM(tab.count_asg_term)          count_asg_term
  ,SUM(tab.count_asg_sep_vol)       count_asg_sep_vol
  ,SUM(tab.count_asg_sep_invol)     count_asg_sep_invol
  ,SUM(tab.count_asg_prmtn)         count_asg_prmtn
  ,SUM(tab.pow_days_on_end_date)    pow_days_on_end_date
  ,SUM(tab.pow_months_on_end_date)  pow_months_on_end_date
  ,SUM(tab.days_since_last_prmtn)   days_since_last_prmtn
  ,SUM(tab.months_since_last_prmtn) months_since_last_prmtn
  ,SUM(tab.anl_slry_start)          anl_slry_start
  ,SUM(tab.anl_slry_end)            anl_slry_end
  ,tab.employee_ind
  ,tab.contingent_ind
  ,tab.adt_pow_band
  FROM
   (SELECT
     suph.sup_person_id                sup_person_fk
    ,chn.mgrs_mngrsc_pk                sup_mngrsc_fk
    ,'N'                               sup_directs_only_flag
    ,fct.time_day_mnth_start_fk
    ,fct.time_day_mnth_end_fk
    ,fct.time_month_snp_fk
    ,fct.job_function_fk
    ,fct.job_family_fk
    ,fct.geo_country_fk
    ,fct.prfm_perfband_fk
    ,fct.pow_powband_fk
    ,fct.ptyp_wrktyp_fk
    ,fct.cur_currency_fk
    ,fct.headcount_start
    ,fct.headcount_end
    ,fct.headcount_hire
    ,fct.headcount_term
    ,fct.headcount_sep_vol
    ,fct.headcount_sep_invol
    ,fct.headcount_prmtn
    ,fct.fte_start
    ,fct.fte_end
    ,fct.fte_hire
    ,fct.fte_term
    ,fct.fte_sep_vol
    ,fct.fte_sep_invol
    ,fct.fte_prmtn
    ,fct.count_pasg_end
    ,fct.count_pasg_hire
    ,fct.count_pasg_term
    ,fct.count_pasg_sep_vol
    ,fct.count_pasg_sep_invol
    ,fct.count_asg_end
    ,fct.count_asg_hire
    ,fct.count_asg_term
    ,fct.count_asg_sep_vol
    ,fct.count_asg_sep_invol
    ,fct.count_asg_prmtn
    ,fct.pow_days_on_end_date
    ,fct.pow_months_on_end_date
    ,fct.days_since_last_prmtn
    ,fct.months_since_last_prmtn
    ,fct.anl_slry_start
    ,fct.anl_slry_end
    ,fct.employee_ind
    ,fct.contingent_ind
    ,fct.adt_pow_band
    FROM
     hri_cs_mngrsc_ct            chn
    ,hri_cs_suph                 suph
    ,hri_mds_wrkfc_mgrh_c01_ct   fct
    WHERE chn.mgrs_person_fk = p_manager_id
    AND p_snapshot_date BETWEEN chn.mgrs_date_start
                        AND chn.mgrs_date_end
    AND suph.sup_person_id = chn.mgrs_person_fk
    AND suph.sub_relative_level = 1
    AND p_snapshot_date BETWEEN suph.effective_start_date
                        AND suph.effective_end_date
    AND suph.sub_person_id = fct.sup_person_fk
    AND fct.time_month_snp_fk = v_month_id
    AND fct.sup_directs_only_flag = 'N'
    UNION ALL
    SELECT /*+ ORDERED USE_NL(wevt ctr jobh ptyp) */
     wevt.per_person_mgr_fk            sup_person_fk
    ,wevt.mgr_mngrsc_fk                sup_mngrsc_fk
    ,dcts.sup_directs_only_flag        sup_directs_only_flag
    ,wevt.time_day_mnth_start_fk       time_day_mnth_start_fk
    ,wevt.time_day_mnth_end_fk         time_day_mnth_end_fk
    ,wevt.time_month_snp_fk            time_month_snp_fk
    ,jobh.job_fnctn_code               job_function_fk
    ,jobh.job_fmly_code                job_family_fk
    ,ctr.country_code                  geo_country_fk
    ,wevt.prfm_perfband_fk             prfm_perfband_fk
    ,wevt.pow_powband_fk               pow_powband_fk
    ,ptyp.wkth_wktyp_sk_fk             ptyp_wrktyp_fk
    ,wevt.cur_currency_fk              cur_currency_fk
    ,wevt.headcount_start              headcount_start
    ,wevt.headcount_end                headcount_end
    ,wevt.headcount_hire               headcount_hire
    ,wevt.headcount_term               headcount_term
    ,wevt.headcount_sep_vol            headcount_sep_vol
    ,wevt.headcount_sep_invol          headcount_sep_invol
    ,wevt.headcount_prmtn              headcount_prmtn
    ,wevt.fte_start                    fte_start
    ,wevt.fte_end                      fte_end
    ,wevt.fte_hire                     fte_hire
    ,wevt.fte_term                     fte_term
    ,wevt.fte_sep_vol                  fte_sep_vol
    ,wevt.fte_sep_invol                fte_sep_invol
    ,wevt.fte_prmtn                    fte_prmtn
    ,wevt.count_pasg_end               count_pasg_end
    ,wevt.count_pasg_hire              count_pasg_hire
    ,wevt.count_pasg_term              count_pasg_term
    ,wevt.count_pasg_sep_vol           count_pasg_sep_vol
    ,wevt.count_pasg_sep_invol         count_pasg_sep_invol
    ,wevt.count_asg_end                count_asg_end
    ,wevt.count_asg_hire               count_asg_hire
    ,wevt.count_asg_term               count_asg_term
    ,wevt.count_asg_sep_vol            count_asg_sep_vol
    ,wevt.count_asg_sep_invol          count_asg_sep_invol
    ,wevt.count_asg_prmtn              count_asg_prmtn
    ,wevt.pow_days_on_end_date         pow_days_on_end_date
    ,wevt.pow_months_on_end_date       pow_months_on_end_date
    ,wevt.days_since_last_prmtn        days_since_last_prmtn
    ,wevt.months_since_last_prmtn      months_since_last_prmtn
    ,wevt.anl_slry_start               anl_slry_start
    ,wevt.anl_slry_end                 anl_slry_end
    ,wevt.employee_ind                 employee_ind
    ,wevt.contingent_ind               contingent_ind
    ,wevt.adt_pow_band                 adt_pow_band
    FROM
     hri_cs_mngrsc_ct            chn
    ,hri_mds_wrkfc_mnth_ct       wevt
    ,hri_cs_geo_lochr_ct         ctr
    ,hri_cs_jobh_ct              jobh
    ,hri_cs_prsntyp_ct           ptyp
    ,(SELECT 'Y' sup_directs_only_flag FROM dual
      UNION ALL
      SELECT 'N' sup_directs_only_flag FROM dual
     )                           dcts
    WHERE chn.mgrs_person_fk = p_manager_id
    AND p_snapshot_date BETWEEN chn.mgrs_date_start
                         AND chn.mgrs_date_end
    AND wevt.mgr_mngrsc_fk = chn.mgrs_mngrsc_pk
    AND wevt.time_month_snp_fk = v_month_id
    AND ctr.location_id = wevt.geo_location_fk
    AND jobh.job_id = wevt.job_job_fk
    AND ptyp.prsntyp_sk_pk = wevt.ptyp_pertyp_fk
   )  tab
  GROUP BY
   tab.sup_person_fk
  ,tab.sup_mngrsc_fk
  ,tab.sup_directs_only_flag
  ,tab.time_day_mnth_start_fk
  ,tab.time_day_mnth_end_fk
  ,tab.time_month_snp_fk
  ,tab.cur_currency_fk
  ,tab.job_function_fk
  ,tab.job_family_fk
  ,tab.geo_country_fk
  ,tab.prfm_perfband_fk
  ,tab.pow_powband_fk
  ,tab.ptyp_wrktyp_fk
  ,tab.cur_currency_fk
  ,tab.employee_ind
  ,tab.contingent_ind
  ,tab.adt_pow_band;

  l_month_id      NUMBER;
  l_sup_person_fk            g_number_tab_type;
  l_sup_mngrsc_fk            g_number_tab_type;
  l_sup_directs_only_flag    g_varchar2_tab_type;
  l_time_day_mnth_start_fk   g_date_tab_type;
  l_time_day_mnth_end_fk     g_date_tab_type;
  l_time_month_snp_fk        g_number_tab_type;
  l_job_function_fk          g_varchar2_tab_type;
  l_job_family_fk            g_varchar2_tab_type;
  l_geo_country_fk           g_varchar2_tab_type;
  l_prfm_perfband_fk         g_number_tab_type;
  l_pow_powband_fk           g_number_tab_type;
  l_ptyp_wrktyp_fk           g_varchar2_tab_type;
  l_cur_currency_fk          g_varchar2_tab_type;
  l_headcount_start          g_number_tab_type;
  l_headcount_end            g_number_tab_type;
  l_headcount_hire           g_number_tab_type;
  l_headcount_term           g_number_tab_type;
  l_headcount_sep_vol        g_number_tab_type;
  l_headcount_sep_invol      g_number_tab_type;
  l_headcount_prmtn          g_number_tab_type;
  l_fte_start                g_number_tab_type;
  l_fte_end                  g_number_tab_type;
  l_fte_hire                 g_number_tab_type;
  l_fte_term                 g_number_tab_type;
  l_fte_sep_vol              g_number_tab_type;
  l_fte_sep_invol            g_number_tab_type;
  l_fte_prmtn                g_number_tab_type;
  l_count_pasg_end           g_number_tab_type;
  l_count_pasg_hire          g_number_tab_type;
  l_count_pasg_term          g_number_tab_type;
  l_count_pasg_sep_vol       g_number_tab_type;
  l_count_pasg_sep_invol     g_number_tab_type;
  l_count_asg_end            g_number_tab_type;
  l_count_asg_hire           g_number_tab_type;
  l_count_asg_term           g_number_tab_type;
  l_count_asg_sep_vol        g_number_tab_type;
  l_count_asg_sep_invol      g_number_tab_type;
  l_count_asg_prmtn          g_number_tab_type;
  l_pow_days_on_end_date     g_number_tab_type;
  l_pow_months_on_end_date   g_number_tab_type;
  l_days_since_last_prmtn    g_number_tab_type;
  l_months_since_last_prmtn  g_number_tab_type;
  l_anl_slry_start           g_number_tab_type;
  l_anl_slry_end             g_number_tab_type;
  l_employee_ind             g_number_tab_type;
  l_contingent_ind           g_number_tab_type;
  l_adt_pow_band             g_number_tab_type;

BEGIN

  l_month_id := to_number(to_char(p_snapshot_date, 'YYYYQMM'));

  OPEN snp_csr(l_month_id);
  FETCH snp_csr BULK COLLECT INTO
    l_sup_person_fk,
    l_sup_mngrsc_fk,
    l_sup_directs_only_flag,
    l_time_day_mnth_start_fk,
    l_time_day_mnth_end_fk,
    l_time_month_snp_fk,
    l_job_function_fk,
    l_job_family_fk,
    l_geo_country_fk,
    l_prfm_perfband_fk,
    l_pow_powband_fk,
    l_ptyp_wrktyp_fk,
    l_cur_currency_fk,
    l_headcount_start,
    l_headcount_end,
    l_headcount_hire,
    l_headcount_term,
    l_headcount_sep_vol,
    l_headcount_sep_invol,
    l_headcount_prmtn,
    l_fte_start,
    l_fte_end,
    l_fte_hire,
    l_fte_term,
    l_fte_sep_vol,
    l_fte_sep_invol,
    l_fte_prmtn,
    l_count_pasg_end,
    l_count_pasg_hire,
    l_count_pasg_term,
    l_count_pasg_sep_vol,
    l_count_pasg_sep_invol,
    l_count_asg_end,
    l_count_asg_hire,
    l_count_asg_term,
    l_count_asg_sep_vol,
    l_count_asg_sep_invol,
    l_count_asg_prmtn,
    l_pow_days_on_end_date,
    l_pow_months_on_end_date,
    l_days_since_last_prmtn,
    l_months_since_last_prmtn,
    l_anl_slry_start,
    l_anl_slry_end,
    l_employee_ind,
    l_contingent_ind,
    l_adt_pow_band;
  CLOSE snp_csr;

  -- Transfer results to global array for bulk insert
  IF l_sup_person_fk.EXISTS(1) THEN
    FOR i IN 1..l_sup_person_fk.LAST LOOP
      insert_row
       (p_sup_person_fk => l_sup_person_fk(i)
       ,p_sup_mngrsc_fk => l_sup_mngrsc_fk(i)
       ,p_sup_directs_only_flag => l_sup_directs_only_flag(i)
       ,p_time_day_mnth_start_fk => l_time_day_mnth_start_fk(i)
       ,p_time_day_mnth_end_fk => l_time_day_mnth_end_fk(i)
       ,p_time_month_snp_fk => l_time_month_snp_fk(i)
       ,p_job_function_fk => l_job_function_fk(i)
       ,p_job_family_fk => l_job_family_fk(i)
       ,p_geo_country_fk => l_geo_country_fk(i)
       ,p_prfm_perfband_fk => l_prfm_perfband_fk(i)
       ,p_pow_powband_fk => l_pow_powband_fk(i)
       ,p_ptyp_wrktyp_fk => l_ptyp_wrktyp_fk(i)
       ,p_cur_currency_fk => l_cur_currency_fk(i)
       ,p_headcount_start => l_headcount_start(i)
       ,p_headcount_end => l_headcount_end(i)
       ,p_headcount_hire => l_headcount_hire(i)
       ,p_headcount_term => l_headcount_term(i)
       ,p_headcount_sep_vol => l_headcount_sep_vol(i)
       ,p_headcount_sep_invol => l_headcount_sep_invol(i)
       ,p_headcount_prmtn => l_headcount_prmtn(i)
       ,p_fte_start => l_fte_start(i)
       ,p_fte_end => l_fte_end(i)
       ,p_fte_hire => l_fte_hire(i)
       ,p_fte_term => l_fte_term(i)
       ,p_fte_sep_vol => l_fte_sep_vol(i)
       ,p_fte_sep_invol => l_fte_sep_invol(i)
       ,p_fte_prmtn => l_fte_prmtn(i)
       ,p_count_pasg_end => l_count_pasg_end(i)
       ,p_count_pasg_hire => l_count_pasg_hire(i)
       ,p_count_pasg_term => l_count_pasg_term(i)
       ,p_count_pasg_sep_vol => l_count_pasg_sep_vol(i)
       ,p_count_pasg_sep_invol => l_count_pasg_sep_invol(i)
       ,p_count_asg_end => l_count_asg_end(i)
       ,p_count_asg_hire => l_count_asg_hire(i)
       ,p_count_asg_term => l_count_asg_term(i)
       ,p_count_asg_sep_vol => l_count_asg_sep_vol(i)
       ,p_count_asg_sep_invol => l_count_asg_sep_invol(i)
       ,p_count_asg_prmtn => l_count_asg_prmtn(i)
       ,p_pow_days_on_end_date => l_pow_days_on_end_date(i)
       ,p_pow_months_on_end_date => l_pow_months_on_end_date(i)
       ,p_days_since_last_prmtn => l_days_since_last_prmtn(i)
       ,p_months_since_last_prmtn => l_months_since_last_prmtn(i)
       ,p_anl_slry_start => l_anl_slry_start(i)
       ,p_anl_slry_end => l_anl_slry_end(i)
       ,p_employee_ind => l_employee_ind(i)
       ,p_contingent_ind => l_contingent_ind(i)
       ,p_adt_pow_band => l_adt_pow_band(i));
    END LOOP;
  END IF;

  -- Bulk insert rows periodically
  IF g_row_count > 2000 THEN
    bulk_insert_rows;
  END IF;

END process_snapshot;


-- ----------------------------------------------------------------------------
-- Processes chunk in full refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_range_full(p_start_object_id    IN NUMBER,
                             p_end_object_id      IN NUMBER,
                             p_mthd_range_lvl     IN NUMBER) IS

  CURSOR work_csr IS
  SELECT DISTINCT
   mgr.mgrs_person_fk   manager_id
  ,mnth.end_date        snapshot_date
  FROM
   hri_cs_mngrsc_ct           mgr
  ,hri_cl_wkr_sup_status_ct   stt
  ,(SELECT
     month.month_id
    ,add_months(to_date(SUBSTR(to_char(month.month_id), 1, 4) || '-' ||
                        SUBSTR(to_char(month.month_id), 6, 2), 'YYYY-MM'),
              1) - 1    end_date
    FROM fii_time_month  month
   )                          mnth
  WHERE mnth.month_id >= to_number(to_char(g_dbi_start_date, 'YYYYQMM'))
  AND mnth.month_id <= to_number(to_char(g_sysdate, 'YYYYQMM'))
  AND mgr.mgrs_level = p_mthd_range_lvl
  AND mgr.mgrs_person_fk BETWEEN p_start_object_id
                         AND p_end_object_id
  AND mgr.mgrs_person_fk = stt.person_id
  AND mnth.end_date BETWEEN mgr.mgrs_date_start
                    AND mgr.mgrs_date_end
  AND mnth.end_date BETWEEN stt.effective_start_date
                    AND ADD_MONTHS(stt.effective_end_date, 3)
  AND stt.supervisor_flag = 'Y'
  AND mgr.mgrs_date_start <= ADD_MONTHS(stt.effective_end_date, 3)
  AND mgr.mgrs_date_end >= stt.effective_start_date;

BEGIN

  FOR mgr_snap IN work_csr LOOP

    process_snapshot
     (p_manager_id    => mgr_snap.manager_id,
      p_snapshot_date => mgr_snap.snapshot_date);

  END LOOP;

END process_range_full;


-- ----------------------------------------------------------------------------
-- Processes chunk in incremental refresh mode
-- ----------------------------------------------------------------------------
PROCEDURE process_range_incr(p_start_object_id    IN NUMBER,
                             p_end_object_id      IN NUMBER,
                             p_mthd_range_lvl     IN NUMBER) IS

  CURSOR work_csr IS
  SELECT DISTINCT
   mgr.mgrs_person_fk   manager_id
  ,mnth.end_date        snapshot_date
  FROM
   hri_eq_wrkfc_evt_mgrh      eq
  ,hri_cs_mngrsc_ct           mgr
  ,hri_cl_wkr_sup_status_ct   stt
  ,(SELECT
     month.month_id
    ,add_months(to_date(SUBSTR(to_char(month.month_id), 1, 4) || '-' ||
                        SUBSTR(to_char(month.month_id), 6, 2), 'YYYY-MM'),
              1) - 1    end_date
    FROM fii_time_month  month
   )                          mnth
  WHERE eq.sup_person_id BETWEEN p_start_object_id
                         AND p_end_object_id
  AND eq.sup_person_id = mgr.mgrs_person_fk
  AND mgr.mgrs_level = p_mthd_range_lvl
  AND mgr.mgrs_date_end >= eq.erlst_evnt_effective_date
  AND mgr.mgrs_person_fk = stt.person_id
  AND stt.supervisor_flag = 'Y'
  AND stt.effective_end_date >= eq.erlst_evnt_effective_date
  AND mnth.month_id >= to_number(to_char(eq.erlst_evnt_effective_date, 'YYYYQMM'))
  AND mnth.month_id >= to_number(to_char(g_dbi_start_date, 'YYYYQMM'))
  AND mnth.month_id <= to_number(to_char(g_sysdate, 'YYYYQMM'))
  AND mnth.end_date BETWEEN mgr.mgrs_date_start
                    AND mgr.mgrs_date_end
  AND mnth.end_date BETWEEN stt.effective_start_date
                    AND ADD_MONTHS(stt.effective_end_date, 3)
  AND mgr.mgrs_date_start <= ADD_MONTHS(stt.effective_end_date, 3)
  AND mgr.mgrs_date_end >= stt.effective_start_date;

BEGIN

  -- Remove rows to be replaced for range
  DELETE FROM hri_mds_wrkfc_mgrh_c01_ct  snp
  WHERE snp.rowid IN
   (SELECT /*+ ORDERED */
     snp2.rowid
    FROM
     hri_eq_wrkfc_evt_mgrh      eq
    ,hri_cs_mngrsc_ct           mgr
    ,hri_mds_wrkfc_mgrh_c01_ct  snp2
    WHERE eq.sup_person_id = snp2.sup_person_fk
    AND eq.sup_person_id = mgr.mgrs_person_fk
    AND mgr.mgrs_level = p_mthd_range_lvl
    AND eq.erlst_evnt_effective_date <= mgr.mgrs_date_end
    AND eq.sup_person_id BETWEEN p_start_object_id AND p_end_object_id
    AND snp2.time_month_snp_fk >=
        to_number(to_char(eq.erlst_evnt_effective_date, 'YYYYQMM'))
   );

  -- Loop through snapshots to reprocess
  FOR mgr_snap IN work_csr LOOP

    process_snapshot
     (p_manager_id    => mgr_snap.manager_id,
      p_snapshot_date => mgr_snap.snapshot_date);

  END LOOP;

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
                       ,p_mthd_range_lvl   IN NUMBER
                       ,p_start_object_id  IN NUMBER
                       ,p_end_object_id    IN NUMBER) IS

BEGIN

-- Set the parameters
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');

-- Set sysdate parameter
  g_sysdate := sysdate;

-- Initialize stored record count
  g_row_count := 0;

-- Process range in corresponding refresh mode
  IF g_full_refresh = 'Y' THEN
    process_range_full
     (p_start_object_id => p_start_object_id,
      p_end_object_id   => p_end_object_id,
      p_mthd_range_lvl  => p_mthd_range_lvl);
  ELSE
    process_range_incr
     (p_start_object_id => p_start_object_id,
      p_end_object_id   => p_end_object_id,
      p_mthd_range_lvl  => p_mthd_range_lvl);
  END IF;

  -- Bulk insert any leftover rows
  IF g_row_count > 0 THEN
    bulk_insert_rows;
  END IF;

END process_range;


-- ----------------------------------------------------------------------------
-- Removes duplicates in event queue
-- ----------------------------------------------------------------------------
PROCEDURE remove_eq_duplicates IS

BEGIN

  -- Remove records in event queue that have duplicate records in event queue for
  -- an earlier refresh date
  DELETE FROM hri_eq_wrkfc_evt_mgrh  eq
  WHERE EXISTS
   (SELECT null
    FROM hri_eq_wrkfc_evt_mgrh  eq2
    WHERE eq2.sup_person_id = eq.sup_person_id
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

  -- Disable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MDS_WRKFC_MGRH_C01_CT_WHO DISABLE');

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out absence dimension table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MDS_WRKFC_MGRH_C01_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

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
        p_table_name             => 'HRI_MDS_WRKFC_MGRH_C01_CT',
        p_table_owner            => l_schema,
        p_index_excptn_lst       => 'HRI_MDS_WRKFC_MGRH_C01_CT_N2');

      -- Set the SQL statement for the entire range
      p_sqlstr :=
       'SELECT /*+ PARALLEL(mgr, default, default) */ DISTINCT
          mgr.mgrs_person_fk  object_id
         ,mgr.mgrs_level      object_lvl
         FROM
          hri_cs_mngrsc_ct           mgr
         WHERE mgr.mgrs_person_fk <> -1
         AND mgr.mgrs_date_end >= hri_bpl_parameter.get_bis_global_start_date
         AND mgr.mgrs_date_start <= trunc(sysdate)
         ORDER BY
          mgr.mgrs_level DESC
         ,mgr.mgrs_person_fk';

    END IF;

  ELSE

    -- Remove event queue duplicates
    remove_eq_duplicates;

    -- Set the SQL statement for the incremental range
      p_sqlstr :=
       'SELECT DISTINCT
          mgr.mgrs_person_fk  object_id
         ,mgr.mgrs_level      object_lvl
         FROM
          hri_eq_wrkfc_evt_mgrh      eq
         ,hri_cs_mngrsc_ct           mgr
         WHERE eq.sup_person_id = mgr.mgrs_person_fk
         AND mgr.mgrs_date_end >= eq.erlst_evnt_effective_date
         AND mgr.mgrs_date_end >= hri_bpl_parameter.get_bis_global_start_date
         AND mgr.mgrs_date_start <= trunc(sysdate)
         ORDER BY
          mgr.mgrs_level DESC
         ,mgr.mgrs_person_fk';

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
    hri_bpl_conc_log.record_process_start('HRI_MDS_WRKFC_MGRH_C01_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Enable WHO trigger
  run_sql_stmt_noerr('ALTER TRIGGER HRI_MGR_WRKFC_MGRH_C01_CT_WHO ENABLE');

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes in full refresh mode
  IF (g_full_refresh = 'Y') THEN
    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MDS_WRKFC_MGRH_C01_CT',
      p_table_owner            => l_schema);

  END IF;

  -- Empty out workforce manager summary event queue
  l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_WRKFC_EVT_MGRH';
  EXECUTE IMMEDIATE(l_sql_stmt);

END post_process;

-- Populates table in a single thread
PROCEDURE single_thread_process(p_full_refresh_flag  IN VARCHAR2) IS

  CURSOR chunk_csr IS
   SELECT
    mthd_range_id
   ,object_lvl
   ,min(object_id)  start_object_id
   ,max(object_id)  end_object_id
   FROM
    (SELECT
      1000 - object_lvl + CEIL(ROWNUM / 20)  mthd_range_id
     ,object_lvl
     ,object_id
     FROM
      (SELECT object_id, object_lvl
       FROM
        (SELECT /*+ PARALLEL(mgr, default, default) */ DISTINCT
          mgr.mgrs_person_fk  object_id
         ,mgr.mgrs_level      object_lvl
         FROM
          hri_cs_mngrsc_ct           mgr
         WHERE mgr.mgrs_date_end >= hri_bpl_parameter.get_bis_global_start_date
         AND mgr.mgrs_date_start <= trunc(sysdate))
       ORDER BY object_lvl DESC, object_id))
   GROUP BY
    mthd_range_id
   ,object_lvl
   ORDER BY object_lvl DESC, mthd_range_id;

  CURSOR chunk_csr_incr IS
  SELECT
   chunk_no
  ,MIN(object_id)  start_object_id
  ,MAX(object_id)  end_object_id
  FROM
   (SELECT
     object_id
    ,CEIL(ROWNUM / 20)  chunk_no
    FROM
     (SELECT DISTINCT
       (mgr.person_id * g_no_qtrs_to_process) +
       (months_between(qtr.start_date,
                       trunc(g_dbi_start_date,'Q')) / 3)  object_id
      FROM
       hri_eq_wrkfc_evt_mgrh      eq
      ,hri_cl_wkr_sup_status_ct   mgr
      ,fii_time_qtr               qtr
      WHERE eq.sup_person_id = mgr.person_id
      AND qtr.end_date >= eq.erlst_evnt_effective_date
      AND mgr.supervisor_flag = 'Y'
      AND qtr.end_date BETWEEN mgr.effective_start_date
                       AND ADD_MONTHS(mgr.effective_end_date, 3)
      AND qtr.end_date >= hri_bpl_parameter.get_bis_global_start_date
      AND qtr.start_date <=   trunc(sysdate)
      ORDER BY 1
     )  tab
   )  chunks
  GROUP BY
   chunk_no;

  l_dummy                 VARCHAR2(2000);
  l_first_qtr_start_date  DATE;
  l_last_qtr_start_date   DATE;
  l_max_sup_lvl   PLS_INTEGER;

BEGIN

  g_full_refresh := p_full_refresh_flag;
  g_refresh_to_date := trunc(sysdate);
  g_sysdate := trunc(sysdate);
  g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;
  l_first_qtr_start_date := trunc(g_dbi_start_date, 'Q');
  l_last_qtr_start_date  := trunc(g_refresh_to_date, 'Q');
  g_no_qtrs_to_process := (MONTHS_BETWEEN(l_last_qtr_start_date,
                                          l_first_qtr_start_date) / 3) + 1;

  pre_process(-1, l_dummy);

  IF g_full_refresh = 'Y' THEN
    FOR chunk_rec IN chunk_csr LOOP
      process_range_full
       (chunk_rec.start_object_id
       ,chunk_rec.end_object_id
       ,chunk_rec.object_lvl);
    END LOOP;
  ELSE
    FOR chunk_rec IN chunk_csr_incr LOOP
      process_range_incr(chunk_rec.start_object_id, chunk_rec.end_object_id, 1);
    END LOOP;
  END IF;


  post_process(-1);

END single_thread_process;

END hri_opl_wrkfc_evt_mgrh;

/
