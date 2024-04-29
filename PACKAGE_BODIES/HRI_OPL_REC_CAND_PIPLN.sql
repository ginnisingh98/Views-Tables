--------------------------------------------------------
--  DDL for Package Body HRI_OPL_REC_CAND_PIPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_REC_CAND_PIPLN" AS
/* $Header: hriprpipln.pkb 120.7.12000000.2 2007/04/12 13:28:03 smohapat noship $ */

  TYPE g_info_rec_type IS RECORD
   (event_seq           NUMBER
   ,asg_id              NUMBER
   ,psn_id              NUMBER
   ,appl_ended_ind      NUMBER
   ,idx_strt_date       DATE
   ,appl_strt_date      DATE
   ,asmt_strt_date      DATE
   ,asmt_int1_date      DATE
   ,asmt_int2_date      DATE
   ,asmt_end_date       DATE
   ,offr_extd_date      DATE
   ,offr_rjct_date      DATE
   ,offr_acpt_date      DATE
   ,appl_end_date       DATE
   ,hire_date           DATE
   ,appl_term_date      DATE
   ,pow1_date           DATE
   ,perf_date           DATE
   ,emp_sprtn_date      DATE
   ,curr_strt_date      DATE
   ,appl_term_rsn       VARCHAR2(30)
   ,perf_norm_rtng      NUMBER
   ,perf_band           NUMBER
   ,latest_stage        VARCHAR2(30)
   ,last_apl_idx        NUMBER);

  TYPE g_apl_event_rec_type IS RECORD
   (time_day_evt_fk            DATE
   ,time_day_evt_end_fk        DATE
   ,time_event                 DATE
   ,person_cand_fk             NUMBER
   ,person_mngr_fk             NUMBER
   ,person_rcrt_fk             NUMBER
   ,person_rmgr_fk             NUMBER
   ,person_auth_fk             NUMBER
   ,person_refr_fk             NUMBER
   ,person_rsed_fk             NUMBER
   ,person_mrgd_fk             NUMBER
   ,org_organztn_fk            NUMBER
   ,org_organztn_mrgd_fk       NUMBER
   ,org_organztn_recr_fk       NUMBER
   ,geo_location_fk            NUMBER
   ,job_job_fk                 NUMBER
   ,grd_grade_fk               NUMBER
   ,pos_position_fk            NUMBER
   ,prfm_perfband_fk           NUMBER
   ,rvac_vacncy_fk            NUMBER
   ,ract_recactvy_fk            NUMBER
   ,rern_recevtrn_fk            VARCHAR2(30)
   ,tarn_trmaplrn_fk            VARCHAR2(30)
   ,headcount                  NUMBER
   ,fte                        NUMBER
   ,perf_norm_rtng             NUMBER
   ,adt_application_id         NUMBER
   ,adt_business_group_id      NUMBER
   ,event_date                 DATE
   ,stage_start_date           DATE
   ,assignment_status_type_id  NUMBER
   ,user_status                VARCHAR2(80)
   ,per_system_status          VARCHAR2(30));

  TYPE g_ind_rec_type IS RECORD
   (appl_ind                     NUMBER
   ,appl_new_ind                 NUMBER
   ,appl_emp_ind                 NUMBER
   ,appl_cwk_ind                 NUMBER
   ,appl_strt_evnt_ind           NUMBER
   ,appl_strt_nevnt_ind          NUMBER
   ,asmt_strt_evnt_ind           NUMBER
   ,asmt_strt_nevnt_ind          NUMBER
   ,asmt_end_evnt_ind            NUMBER
   ,asmt_end_nevnt_ind           NUMBER
   ,offr_extd_evnt_ind           NUMBER
   ,offr_extd_nevnt_ind          NUMBER
   ,offr_rjct_evnt_ind           NUMBER
   ,offr_rjct_nevnt_ind          NUMBER
   ,offr_acpt_evnt_ind           NUMBER
   ,offr_acpt_nevnt_ind          NUMBER
   ,appl_term_evnt_ind           NUMBER
   ,appl_term_nevnt_ind          NUMBER
   ,appl_term_vol_evnt_ind       NUMBER
   ,appl_term_vol_nevnt_ind      NUMBER
   ,appl_term_invol_evnt_ind     NUMBER
   ,appl_term_invol_nevnt_ind    NUMBER
   ,appl_hire_evnt_ind           NUMBER
   ,appl_hire_nevnt_ind          NUMBER
   ,hire_evnt_ind                NUMBER
   ,hire_nevnt_ind               NUMBER
   ,pow1_end_evnt_ind            NUMBER
   ,pow1_end_nevnt_ind           NUMBER
   ,perf_rtng_evnt_ind           NUMBER
   ,perf_rtng_nevnt_ind          NUMBER
   ,emp_sprtn_evnt_ind           NUMBER
   ,emp_sprtn_nevnt_ind          NUMBER
   ,init_appl_stg_ind          NUMBER
   ,asmt_stg_ind               NUMBER
   ,offr_extd_stg_ind          NUMBER
   ,strt_pndg_stg_ind          NUMBER
   ,hire_stg_ind               NUMBER
   ,hire_org_chng_ind            NUMBER
   ,hire_job_chng_ind            NUMBER
   ,hire_grd_chng_ind            NUMBER
   ,hire_pos_chng_ind            NUMBER
   ,hire_loc_chng_ind            NUMBER
   ,current_record_ind           NUMBER);

  TYPE g_master_evt_rec_type IS RECORD
   (apl_idx      NUMBER
   ,event_code   VARCHAR2(30)
   ,stage_code   VARCHAR2(30)
   ,event_seq    NUMBER
   ,cnstrct_evt  VARCHAR2(30)
   ,event_ind    g_ind_rec_type);

  -- Table Types
  TYPE g_varchar2_tab_type IS TABLE OF VARCHAR2(80)
                           INDEX BY BINARY_INTEGER;
  TYPE g_number_tab_type IS TABLE OF NUMBER
                           INDEX BY BINARY_INTEGER;
  TYPE g_date_tab_type IS TABLE OF DATE
                           INDEX BY BINARY_INTEGER;
  TYPE g_apl_tab_type IS TABLE OF g_apl_event_rec_type
                           INDEX BY BINARY_INTEGER;
  TYPE g_master_evt_tab_type IS TABLE OF g_master_evt_rec_type
                           INDEX BY BINARY_INTEGER;
  TYPE g_master_tab_type IS TABLE OF g_master_evt_tab_type
                           INDEX BY BINARY_INTEGER;
  TYPE g_event_tab_type IS TABLE OF VARCHAR2(30)
                           INDEX BY VARCHAR2(30);

  -- Event cache
  g_event_cache                     g_event_tab_type;
  g_empty_event_cache               g_event_tab_type;

  -- PL/SQL table representing database table
  g_time_day_evt_fk                 g_date_tab_type;
  g_time_day_evt_end_fk             g_date_tab_type;
  g_time_day_stg_evt_eff_end_fk     g_date_tab_type;
  g_person_cand_fk                  g_number_tab_type;
  g_person_mngr_fk                  g_number_tab_type;
  g_person_rcrt_fk                  g_number_tab_type;
  g_person_rmgr_fk                  g_number_tab_type;
  g_person_auth_fk                  g_number_tab_type;
  g_person_refr_fk                  g_number_tab_type;
  g_person_rsed_fk                  g_number_tab_type;
  g_person_mrgd_fk                  g_number_tab_type;
  g_org_organztn_fk                 g_number_tab_type;
  g_org_organztn_mrgd_fk            g_number_tab_type;
  g_org_organztn_recr_fk            g_number_tab_type;
  g_geo_location_fk                 g_number_tab_type;
  g_job_job_fk                      g_number_tab_type;
  g_grd_grade_fk                    g_number_tab_type;
  g_pos_position_fk                 g_number_tab_type;
  g_prfm_perfband_fk                g_number_tab_type;
  g_rvac_vacncy_fk                 g_number_tab_type;
  g_ract_recactvy_fk                 g_number_tab_type;
  g_rev_recevent_fk                 g_varchar2_tab_type;
  g_rern_recevtrn_fk                 g_varchar2_tab_type;
  g_tarn_trmaplrn_fk                 g_varchar2_tab_type;
  g_headcount                       g_number_tab_type;
  g_fte                             g_number_tab_type;
  g_nrmlsd_perf_rtng                g_number_tab_type;
  g_event_seq                       g_number_tab_type;
  g_appl_ind                        g_number_tab_type;
  g_appl_new_ind                    g_number_tab_type;
  g_appl_emp_ind                    g_number_tab_type;
  g_appl_cwk_ind                    g_number_tab_type;
  g_appl_strt_evnt_ind              g_number_tab_type;
  g_appl_strt_nevnt_ind             g_number_tab_type;
  g_asmt_strt_evnt_ind              g_number_tab_type;
  g_asmt_strt_nevnt_ind             g_number_tab_type;
  g_asmt_end_evnt_ind               g_number_tab_type;
  g_asmt_end_nevnt_ind              g_number_tab_type;
  g_offr_extd_evnt_ind              g_number_tab_type;
  g_offr_extd_nevnt_ind             g_number_tab_type;
  g_offr_rjct_evnt_ind              g_number_tab_type;
  g_offr_rjct_nevnt_ind             g_number_tab_type;
  g_offr_acpt_evnt_ind              g_number_tab_type;
  g_offr_acpt_nevnt_ind             g_number_tab_type;
  g_appl_term_evnt_ind              g_number_tab_type;
  g_appl_term_nevnt_ind             g_number_tab_type;
  g_appl_term_vol_evnt_ind          g_number_tab_type;
  g_appl_term_vol_nevnt_ind         g_number_tab_type;
  g_appl_term_invol_evnt_ind        g_number_tab_type;
  g_appl_term_invol_nevnt_ind       g_number_tab_type;
  g_appl_hire_evnt_ind              g_number_tab_type;
  g_appl_hire_nevnt_ind             g_number_tab_type;
  g_hire_evnt_ind                   g_number_tab_type;
  g_hire_nevnt_ind                  g_number_tab_type;
  g_pow1_end_evnt_ind               g_number_tab_type;
  g_pow1_end_nevnt_ind              g_number_tab_type;
  g_perf_rtng_evnt_ind              g_number_tab_type;
  g_perf_rtng_nevnt_ind             g_number_tab_type;
  g_emp_sprtn_evnt_ind              g_number_tab_type;
  g_emp_sprtn_nevnt_ind             g_number_tab_type;
  g_hire_org_chng_ind               g_number_tab_type;
  g_hire_job_chng_ind               g_number_tab_type;
  g_hire_pos_chng_ind               g_number_tab_type;
  g_hire_grd_chng_ind               g_number_tab_type;
  g_hire_loc_chng_ind               g_number_tab_type;
  g_current_record_ind              g_number_tab_type;
  g_current_stage_strt_ind          g_number_tab_type;
  g_gen_record_ind                  g_number_tab_type;
  g_appl_strt_to_asmt_strt_days     g_number_tab_type;
  g_appl_strt_to_asmt_end_days      g_number_tab_type;
  g_appl_strt_to_offr_extd_days     g_number_tab_type;
  g_appl_strt_to_offr_rjct_days     g_number_tab_type;
  g_appl_strt_to_offr_acpt_days     g_number_tab_type;
  g_appl_strt_to_hire_days          g_number_tab_type;
  g_appl_strt_to_term_days          g_number_tab_type;
  g_init_appl_stg_ind               g_number_tab_type;
  g_asmt_stg_ind                    g_number_tab_type;
  g_offr_extd_stg_ind               g_number_tab_type;
  g_strt_pndg_stg_ind               g_number_tab_type;
  g_hire_stg_ind                    g_number_tab_type;
  g_appl_strt_date                  g_date_tab_type;
  g_asmt_strt_date                  g_date_tab_type;
  g_asmt_end_date                   g_date_tab_type;
  g_offr_extd_date                  g_date_tab_type;
  g_offr_rjct_date                  g_date_tab_type;
  g_offr_acpt_date                  g_date_tab_type;
  g_appl_term_date                  g_date_tab_type;
  g_hire_date                       g_date_tab_type;
  g_emp_sprtn_date                  g_date_tab_type;
  g_event_date                      g_date_tab_type;
  g_stage_start_date                g_date_tab_type;
  g_adt_assignment_id               g_number_tab_type;
  g_adt_asg_effctv_start_date       g_date_tab_type;
  g_adt_asg_effctv_end_date         g_date_tab_type;
  g_adt_application_id              g_number_tab_type;
  g_no_rows                         PLS_INTEGER;


  -- Global HRI Multithreading Array
  g_mthd_action_array       HRI_ADM_MTHD_ACTIONS%rowtype;

  -- Global parameters
  g_refresh_start_date      DATE;
  g_refresh_to_date         DATE;
  g_full_refresh            VARCHAR2(30);
  g_sysdate                 DATE;
  g_user                    NUMBER;
  g_dbi_start_date          DATE;
  g_end_of_time             DATE := hr_general.end_of_time;
  g_debug                   BOOLEAN;

  -- Length of POW1 Band
  g_pow1_no_days            NUMBER;
  g_pow1_no_months          NUMBER;


-- ----------------------------------------------------------------------------
-- Debug Output
-- ----------------------------------------------------------------------------
PROCEDURE dbg(p_text   IN VARCHAR2) IS

BEGIN

  IF g_debug THEN
    hri_bpl_conc_log.dbg(p_text);
  END IF;

  --dbms_output.put_line(p_text);

END dbg;

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
-- Initializes an indicator record
-- ----------------------------------------------------------------------------
FUNCTION initialize_indicator_rec RETURN g_ind_rec_type IS

  l_ind_rec          g_ind_rec_type;

BEGIN

  l_ind_rec.appl_ind                   := 0;
  l_ind_rec.appl_new_ind               := 0;
  l_ind_rec.appl_emp_ind               := 0;
  l_ind_rec.appl_cwk_ind               := 0;
  l_ind_rec.appl_strt_evnt_ind         := 0;
  l_ind_rec.appl_strt_nevnt_ind        := 0;
  l_ind_rec.asmt_strt_evnt_ind         := 0;
  l_ind_rec.asmt_strt_nevnt_ind        := 0;
  l_ind_rec.asmt_end_evnt_ind          := 0;
  l_ind_rec.asmt_end_nevnt_ind         := 0;
  l_ind_rec.offr_extd_evnt_ind         := 0;
  l_ind_rec.offr_extd_nevnt_ind        := 0;
  l_ind_rec.offr_rjct_evnt_ind         := 0;
  l_ind_rec.offr_rjct_nevnt_ind        := 0;
  l_ind_rec.offr_acpt_evnt_ind         := 0;
  l_ind_rec.offr_acpt_nevnt_ind        := 0;
  l_ind_rec.appl_term_evnt_ind         := 0;
  l_ind_rec.appl_term_nevnt_ind        := 0;
  l_ind_rec.appl_term_vol_evnt_ind     := 0;
  l_ind_rec.appl_term_vol_nevnt_ind    := 0;
  l_ind_rec.appl_term_invol_evnt_ind   := 0;
  l_ind_rec.appl_term_invol_nevnt_ind  := 0;
  l_ind_rec.appl_hire_evnt_ind         := 0;
  l_ind_rec.appl_hire_nevnt_ind        := 0;
  l_ind_rec.hire_evnt_ind              := 0;
  l_ind_rec.hire_nevnt_ind             := 0;
  l_ind_rec.pow1_end_evnt_ind          := 0;
  l_ind_rec.pow1_end_nevnt_ind         := 0;
  l_ind_rec.perf_rtng_evnt_ind         := 0;
  l_ind_rec.perf_rtng_nevnt_ind        := 0;
  l_ind_rec.emp_sprtn_evnt_ind         := 0;
  l_ind_rec.emp_sprtn_nevnt_ind        := 0;
  l_ind_rec.init_appl_stg_ind          := 0;
  l_ind_rec.asmt_stg_ind               := 0;
  l_ind_rec.offr_extd_stg_ind          := 0;
  l_ind_rec.strt_pndg_stg_ind          := 0;
  l_ind_rec.hire_stg_ind               := 0;
  l_ind_rec.hire_org_chng_ind          := 0;
  l_ind_rec.hire_job_chng_ind          := 0;
  l_ind_rec.hire_grd_chng_ind          := 0;
  l_ind_rec.hire_pos_chng_ind          := 0;
  l_ind_rec.hire_loc_chng_ind          := 0;
  l_ind_rec.current_record_ind         := 0;

  RETURN l_ind_rec;

END initialize_indicator_rec;


-- ----------------------------------------------------------------------------
-- Sets global parameters from multi-threading process parameters
-- ----------------------------------------------------------------------------
PROCEDURE reset_event_cache IS

BEGIN

  g_event_cache := g_empty_event_cache;

END reset_event_cache;

-- ----------------------------------------------------------------------------
-- Returns the event index for the last record on the master table
-- ----------------------------------------------------------------------------
FUNCTION get_event_idx(p_master_tab  IN g_master_tab_type,
                       p_master_idx  IN NUMBER)
    RETURN NUMBER IS

  l_event_idx    NUMBER;

BEGIN

  -- Trap exception when master table is empty at specified index
  BEGIN

    -- Get last index value
    l_event_idx := p_master_tab(p_master_idx).LAST;

    -- This execption should be raised automatically
    IF l_event_idx IS NULL THEN
      RAISE no_data_found;
    END IF;

  EXCEPTION WHEN OTHERS THEN

    -- If not found return 0
    l_event_idx := 0;

  END;

  RETURN l_event_idx;

END get_event_idx;

-- ----------------------------------------------------------------------------
-- Sets global parameters from multi-threading process parameters
-- ----------------------------------------------------------------------------
PROCEDURE set_parameters(p_mthd_action_id   IN NUMBER,
                         p_mthd_stage_code  IN VARCHAR2) IS

  l_dbi_collection_start_date   DATE;

  CURSOR pow1_csr IS
  SELECT
   CASE WHEN set_uom = 'Years'
        THEN (band_range_high - band_range_low) * 12
        WHEN set_uom = 'Months'
        THEN (band_range_high - band_range_low)
        ELSE to_number(null)
   END        pow1_no_months
  ,CASE WHEN set_uom = 'Weeks'
        THEN (band_range_high - band_range_low) * 7
        WHEN set_uom = 'Days'
        THEN (band_range_high - band_range_low)
        ELSE to_number(null)
   END        pow1_no_days
  FROM hri_cs_pow_band_ct
  WHERE band_sequence = 1
  AND wkth_wktyp_sk_fk = 'EMP';

BEGIN

-- If parameters haven't already been set, then set them
  IF (p_mthd_action_id = -1) THEN

    g_sysdate              := sysdate;
    g_user                 := fnd_global.user_id;

    OPEN pow1_csr;
    FETCH pow1_csr INTO g_pow1_no_months, g_pow1_no_days;
    CLOSE pow1_csr;

  ELSIF (g_refresh_start_date IS NULL OR
      p_mthd_stage_code = 'PRE_PROCESS') THEN

    l_dbi_collection_start_date :=
           hri_oltp_conc_param.get_date_parameter_value
            (p_parameter_name     => 'FULL_REFRESH_FROM_DATE',
             p_process_table_name => 'HRI_MB_REC_CAND_PIPLN_CT');

    -- If called for the first time set the defaulted parameters
    IF (p_mthd_stage_code = 'PRE_PROCESS') THEN

      g_full_refresh :=
           hri_oltp_conc_param.get_parameter_value
            (p_parameter_name     => 'FULL_REFRESH',
             p_process_table_name => 'HRI_MB_REC_CAND_PIPLN_CT');

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
    g_dbi_start_date       := hri_bpl_parameter.get_bis_global_start_date;
    g_debug                := FALSE;

    hri_bpl_conc_log.dbg('Full refresh:   ' || g_full_refresh);
    hri_bpl_conc_log.dbg('Collect from:    N/A');

    OPEN pow1_csr;
    FETCH pow1_csr INTO g_pow1_no_months, g_pow1_no_days;
    CLOSE pow1_csr;

  END IF;

  -- Currently only full refresh is supported
  g_full_refresh := 'Y';

END set_parameters;


-- ----------------------------------------------------------------------------
-- Commits records to DB from PL/SQL tables
-- ----------------------------------------------------------------------------
PROCEDURE bulk_insert_rows IS

BEGIN

  IF g_no_rows > 0 THEN

    FORALL i IN 1..g_no_rows
      INSERT INTO hri_mb_rec_cand_pipln_ct
       (time_day_evt_fk,
        time_day_evt_end_fk,
        time_day_stg_evt_eff_end_fk,
        per_person_cand_fk,
        per_person_mngr_fk,
        per_person_rcrt_fk,
        per_person_rmgr_fk,
        per_person_auth_fk,
        per_person_refr_fk,
        per_person_rsed_fk,
        per_person_mrgd_fk,
        org_organztn_fk,
        org_organztn_mrgd_fk,
        org_organztn_recr_fk,
        geo_location_fk,
        job_job_fk,
        grd_grade_fk,
        pos_position_fk,
        prfm_perfband_fk,
        rvac_vacncy_fk,
        ract_recactvy_fk,
        rev_recevent_fk,
        rern_recevtrn_fk,
        tarn_trmaplrn_fk,
        headcount,
        fte,
        post_hire_nrmlsd_perf_rtng,
        event_seq,
        appl_ind,
        appl_new_ind,
        appl_emp_ind,
        appl_cwk_ind,
        appl_strt_evnt_ind,
        appl_strt_nevnt_ind,
        asmt_strt_evnt_ind,
        asmt_strt_nevnt_ind,
        asmt_end_evnt_ind,
        asmt_end_nevnt_ind,
        offr_extd_evnt_ind,
        offr_extd_nevnt_ind,
        offr_rjct_evnt_ind,
        offr_rjct_nevnt_ind,
        offr_acpt_evnt_ind,
        offr_acpt_nevnt_ind,
        appl_term_evnt_ind,
        appl_term_nevnt_ind,
        appl_term_vol_evnt_ind,
        appl_term_vol_nevnt_ind,
        appl_term_invol_evnt_ind,
        appl_term_invol_nevnt_ind,
        appl_hire_evnt_ind,
        appl_hire_nevnt_ind,
        hire_evnt_ind,
        hire_nevnt_ind,
        post_hire_pow1_end_evnt_ind,
        post_hire_pow1_end_nevnt_ind,
        post_hire_perf_evnt_ind,
        post_hire_perf_nevnt_ind,
        emp_sprtn_evnt_ind,
        emp_sprtn_nevnt_ind,
        hire_org_chng_ind,
        hire_job_chng_ind,
        hire_pos_chng_ind,
        hire_grd_chng_ind,
        hire_loc_chng_ind,
        current_record_ind,
        current_stage_strt_ind,
        gen_record_ind,
        appl_strt_to_asmt_strt_days,
        appl_strt_to_asmt_end_days,
        appl_strt_to_offr_extd_days,
        appl_strt_to_offr_rjct_days,
        appl_strt_to_offr_acpt_days,
        appl_strt_to_hire_days,
        appl_strt_to_term_days,
        init_appl_stg_ind,
        asmt_stg_ind,
        offr_extd_stg_ind,
        strt_pndg_stg_ind,
        hire_stg_ind,
        appl_strt_date,
        asmt_strt_date,
        asmt_end_date,
        offr_extd_date,
        offr_rjct_date,
        offr_acpt_date,
        appl_term_date,
        hire_date,
        emp_sprtn_date,
        event_date,
        stage_start_date,
        adt_assignment_id,
        adt_asg_effctv_start_date,
        adt_asg_effctv_end_date,
        adt_application_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        created_by,
        creation_date)
      VALUES
       (g_time_day_evt_fk(i),
        g_time_day_evt_end_fk(i),
        g_time_day_stg_evt_eff_end_fk(i),
        g_person_cand_fk(i),
        g_person_mngr_fk(i),
        g_person_rcrt_fk(i),
        g_person_rmgr_fk(i),
        g_person_auth_fk(i),
        g_person_refr_fk(i),
        g_person_rsed_fk(i),
        g_person_mrgd_fk(i),
        g_org_organztn_fk(i),
        g_org_organztn_mrgd_fk(i),
        g_org_organztn_recr_fk(i),
        g_geo_location_fk(i),
        g_job_job_fk(i),
        g_grd_grade_fk(i),
        g_pos_position_fk(i),
        g_prfm_perfband_fk(i),
        g_rvac_vacncy_fk(i),
        g_ract_recactvy_fk(i),
        g_rev_recevent_fk(i),
        g_rern_recevtrn_fk(i),
        g_tarn_trmaplrn_fk(i),
        g_headcount(i),
        g_fte(i),
        g_nrmlsd_perf_rtng(i),
        g_event_seq(i),
        g_appl_ind(i),
        g_appl_new_ind(i),
        g_appl_emp_ind(i),
        g_appl_cwk_ind(i),
        g_appl_strt_evnt_ind(i),
        g_appl_strt_nevnt_ind(i),
        g_asmt_strt_evnt_ind(i),
        g_asmt_strt_nevnt_ind(i),
        g_asmt_end_evnt_ind(i),
        g_asmt_end_nevnt_ind(i),
        g_offr_extd_evnt_ind(i),
        g_offr_extd_nevnt_ind(i),
        g_offr_rjct_evnt_ind(i),
        g_offr_rjct_nevnt_ind(i),
        g_offr_acpt_evnt_ind(i),
        g_offr_acpt_nevnt_ind(i),
        g_appl_term_evnt_ind(i),
        g_appl_term_nevnt_ind(i),
        g_appl_term_vol_evnt_ind(i),
        g_appl_term_vol_nevnt_ind(i),
        g_appl_term_invol_evnt_ind(i),
        g_appl_term_invol_nevnt_ind(i),
        g_appl_hire_evnt_ind(i),
        g_appl_hire_nevnt_ind(i),
        g_hire_evnt_ind(i),
        g_hire_nevnt_ind(i),
        g_pow1_end_evnt_ind(i),
        g_pow1_end_nevnt_ind(i),
        g_perf_rtng_evnt_ind(i),
        g_perf_rtng_nevnt_ind(i),
        g_emp_sprtn_evnt_ind(i),
        g_emp_sprtn_nevnt_ind(i),
        g_hire_org_chng_ind(i),
        g_hire_job_chng_ind(i),
        g_hire_pos_chng_ind(i),
        g_hire_grd_chng_ind(i),
        g_hire_loc_chng_ind(i),
        g_current_record_ind(i),
        g_current_stage_strt_ind(i),
        g_gen_record_ind(i),
        g_appl_strt_to_asmt_strt_days(i),
        g_appl_strt_to_asmt_end_days(i),
        g_appl_strt_to_offr_extd_days(i),
        g_appl_strt_to_offr_rjct_days(i),
        g_appl_strt_to_offr_acpt_days(i),
        g_appl_strt_to_hire_days(i),
        g_appl_strt_to_term_days(i),
        g_init_appl_stg_ind(i),
        g_asmt_stg_ind(i),
        g_offr_extd_stg_ind(i),
        g_strt_pndg_stg_ind(i),
        g_hire_stg_ind(i),
        g_appl_strt_date(i),
        g_asmt_strt_date(i),
        g_asmt_end_date(i),
        g_offr_extd_date(i),
        g_offr_rjct_date(i),
        g_offr_acpt_date(i),
        g_appl_term_date(i),
        g_hire_date(i),
        g_emp_sprtn_date(i),
        g_event_date(i),
        g_stage_start_date(i),
        g_adt_assignment_id(i),
        g_adt_asg_effctv_start_date(i),
        g_adt_asg_effctv_end_date(i),
        g_adt_application_id(i),
        g_sysdate,
        g_user,
        g_user,
        g_user,
        g_sysdate);

    -- Commit
    COMMIT;

    -- Reset counter
    g_no_rows := 0;

  END IF;

END bulk_insert_rows;


-- ----------------------------------------------------------------------------
-- Inserts a row into PL/SQL tables
-- ----------------------------------------------------------------------------
PROCEDURE insert_row
   (p_time_day_evt_fk               IN DATE,
    p_time_day_evt_end_fk           IN DATE,
    p_time_day_stg_evt_eff_end_fk   IN DATE,
    p_person_cand_fk                IN NUMBER,
    p_person_mngr_fk                IN NUMBER,
    p_person_rcrt_fk                IN NUMBER,
    p_person_rmgr_fk                IN NUMBER,
    p_person_auth_fk                IN NUMBER,
    p_person_refr_fk                IN NUMBER,
    p_person_rsed_fk                IN NUMBER,
    p_person_mrgd_fk                IN NUMBER,
    p_org_organztn_fk               IN NUMBER,
    p_org_organztn_mrgd_fk          IN NUMBER,
    p_org_organztn_recr_fk          IN NUMBER,
    p_geo_location_fk               IN NUMBER,
    p_job_job_fk                    IN NUMBER,
    p_grd_grade_fk                  IN NUMBER,
    p_pos_position_fk               IN NUMBER,
    p_prfm_perfband_fk              IN NUMBER,
    p_rvac_vacncy_fk               IN NUMBER,
    p_ract_recactvy_fk               IN NUMBER,
    p_rev_recevent_fk               IN VARCHAR2,
    p_rern_recevtrn_fk               IN VARCHAR2,
    p_tarn_trmaplrn_fk               IN VARCHAR2,
    p_headcount                     IN NUMBER,
    p_fte                           IN NUMBER,
    p_nrmlsd_perf_rtng              IN NUMBER,
    p_event_seq                     IN NUMBER,
    p_appl_ind                      IN NUMBER,
    p_appl_new_ind                  IN NUMBER,
    p_appl_emp_ind                  IN NUMBER,
    p_appl_cwk_ind                  IN NUMBER,
    p_appl_strt_evnt_ind            IN NUMBER,
    p_appl_strt_nevnt_ind           IN NUMBER,
    p_asmt_strt_evnt_ind            IN NUMBER,
    p_asmt_strt_nevnt_ind           IN NUMBER,
    p_asmt_end_evnt_ind             IN NUMBER,
    p_asmt_end_nevnt_ind            IN NUMBER,
    p_offr_extd_evnt_ind            IN NUMBER,
    p_offr_extd_nevnt_ind           IN NUMBER,
    p_offr_rjct_evnt_ind            IN NUMBER,
    p_offr_rjct_nevnt_ind           IN NUMBER,
    p_offr_acpt_evnt_ind            IN NUMBER,
    p_offr_acpt_nevnt_ind           IN NUMBER,
    p_appl_term_evnt_ind            IN NUMBER,
    p_appl_term_nevnt_ind           IN NUMBER,
    p_appl_term_vol_evnt_ind        IN NUMBER,
    p_appl_term_vol_nevnt_ind       IN NUMBER,
    p_appl_term_invol_evnt_ind      IN NUMBER,
    p_appl_term_invol_nevnt_ind     IN NUMBER,
    p_appl_hire_evnt_ind            IN NUMBER,
    p_appl_hire_nevnt_ind           IN NUMBER,
    p_hire_evnt_ind                 IN NUMBER,
    p_hire_nevnt_ind                IN NUMBER,
    p_pow1_end_evnt_ind             IN NUMBER,
    p_pow1_end_nevnt_ind            IN NUMBER,
    p_perf_rtng_evnt_ind            IN NUMBER,
    p_perf_rtng_nevnt_ind           IN NUMBER,
    p_emp_sprtn_evnt_ind            IN NUMBER,
    p_emp_sprtn_nevnt_ind           IN NUMBER,
    p_hire_org_chng_ind             IN NUMBER,
    p_hire_job_chng_ind             IN NUMBER,
    p_hire_pos_chng_ind             IN NUMBER,
    p_hire_grd_chng_ind             IN NUMBER,
    p_hire_loc_chng_ind             IN NUMBER,
    p_current_record_ind            IN NUMBER,
    p_current_stage_strt_ind        IN NUMBER,
    p_gen_record_ind                IN NUMBER,
    p_appl_strt_to_asmt_strt_days   IN NUMBER,
    p_appl_strt_to_asmt_end_days    IN NUMBER,
    p_appl_strt_to_offr_extd_days   IN NUMBER,
    p_appl_strt_to_offr_rjct_days   IN NUMBER,
    p_appl_strt_to_offr_acpt_days   IN NUMBER,
    p_appl_strt_to_hire_days        IN NUMBER,
    p_appl_strt_to_term_days        IN NUMBER,
    p_init_appl_stg_ind             IN NUMBER,
    p_asmt_stg_ind                  IN NUMBER,
    p_offr_extd_stg_ind             IN NUMBER,
    p_strt_pndg_stg_ind             IN NUMBER,
    p_hire_stg_ind                  IN NUMBER,
    p_appl_strt_date                IN DATE,
    p_asmt_strt_date                IN DATE,
    p_asmt_end_date                 IN DATE,
    p_offr_extd_date                IN DATE,
    p_offr_rjct_date                IN DATE,
    p_offr_acpt_date                IN DATE,
    p_appl_term_date                IN DATE,
    p_hire_date                     IN DATE,
    p_emp_sprtn_date                IN DATE,
    p_event_date                    IN DATE,
    p_stage_start_date              IN DATE,
    p_adt_assignment_id             IN NUMBER,
    p_adt_asg_effctv_start_date     IN DATE,
    p_adt_asg_effctv_end_date       IN DATE,
    p_adt_application_id            IN NUMBER) IS

BEGIN

  g_no_rows := g_no_rows + 1;
  g_time_day_evt_fk(g_no_rows) := p_time_day_evt_fk;
  g_time_day_evt_end_fk(g_no_rows) := p_time_day_evt_end_fk;
  g_time_day_stg_evt_eff_end_fk(g_no_rows) := p_time_day_stg_evt_eff_end_fk;
  g_person_cand_fk(g_no_rows) := p_person_cand_fk;
  g_person_mngr_fk(g_no_rows) := p_person_mngr_fk;
  g_person_rcrt_fk(g_no_rows) := p_person_rcrt_fk;
  g_person_rmgr_fk(g_no_rows) := p_person_rmgr_fk;
  g_person_auth_fk(g_no_rows) := p_person_auth_fk;
  g_person_refr_fk(g_no_rows) := p_person_refr_fk;
  g_person_rsed_fk(g_no_rows) := p_person_rsed_fk;
  g_person_mrgd_fk(g_no_rows) := p_person_mrgd_fk;
  g_org_organztn_fk(g_no_rows) := p_org_organztn_fk;
  g_org_organztn_mrgd_fk(g_no_rows) := p_org_organztn_mrgd_fk;
  g_org_organztn_recr_fk(g_no_rows) := p_org_organztn_recr_fk;
  g_geo_location_fk(g_no_rows) := p_geo_location_fk;
  g_job_job_fk(g_no_rows) := p_job_job_fk;
  g_grd_grade_fk(g_no_rows) := p_grd_grade_fk;
  g_pos_position_fk(g_no_rows) := p_pos_position_fk;
  g_prfm_perfband_fk(g_no_rows) := p_prfm_perfband_fk;
  g_rvac_vacncy_fk(g_no_rows) := p_rvac_vacncy_fk;
  g_ract_recactvy_fk(g_no_rows) := p_ract_recactvy_fk;
  g_rev_recevent_fk(g_no_rows) := p_rev_recevent_fk;
  g_rern_recevtrn_fk(g_no_rows) := p_rern_recevtrn_fk;
  g_tarn_trmaplrn_fk(g_no_rows) := p_tarn_trmaplrn_fk;
  g_headcount(g_no_rows) := p_headcount;
  g_fte(g_no_rows) := p_fte;
  g_nrmlsd_perf_rtng(g_no_rows) := p_nrmlsd_perf_rtng;
  g_event_seq(g_no_rows) := p_event_seq;
  g_appl_ind(g_no_rows) := p_appl_ind;
  g_appl_new_ind(g_no_rows) := p_appl_new_ind;
  g_appl_emp_ind(g_no_rows) := p_appl_emp_ind;
  g_appl_cwk_ind(g_no_rows) := p_appl_cwk_ind;
  g_appl_strt_evnt_ind(g_no_rows) := p_appl_strt_evnt_ind;
  g_appl_strt_nevnt_ind(g_no_rows) := p_appl_strt_nevnt_ind;
  g_asmt_strt_evnt_ind(g_no_rows) := p_asmt_strt_evnt_ind;
  g_asmt_strt_nevnt_ind(g_no_rows) := p_asmt_strt_nevnt_ind;
  g_asmt_end_evnt_ind(g_no_rows) := p_asmt_end_evnt_ind;
  g_asmt_end_nevnt_ind(g_no_rows) := p_asmt_end_nevnt_ind;
  g_offr_extd_evnt_ind(g_no_rows) := p_offr_extd_evnt_ind;
  g_offr_extd_nevnt_ind(g_no_rows) := p_offr_extd_nevnt_ind;
  g_offr_rjct_evnt_ind(g_no_rows) := p_offr_rjct_evnt_ind;
  g_offr_rjct_nevnt_ind(g_no_rows) := p_offr_rjct_nevnt_ind;
  g_offr_acpt_evnt_ind(g_no_rows) := p_offr_acpt_evnt_ind;
  g_offr_acpt_nevnt_ind(g_no_rows) := p_offr_acpt_nevnt_ind;
  g_appl_term_evnt_ind(g_no_rows) := p_appl_term_evnt_ind;
  g_appl_term_nevnt_ind(g_no_rows) := p_appl_term_nevnt_ind;
  g_appl_term_vol_evnt_ind(g_no_rows) := p_appl_term_vol_evnt_ind;
  g_appl_term_vol_nevnt_ind(g_no_rows) := p_appl_term_vol_nevnt_ind;
  g_appl_term_invol_evnt_ind(g_no_rows) := p_appl_term_invol_evnt_ind;
  g_appl_term_invol_nevnt_ind(g_no_rows) := p_appl_term_invol_nevnt_ind;
  g_appl_hire_evnt_ind(g_no_rows) := p_appl_hire_evnt_ind;
  g_appl_hire_nevnt_ind(g_no_rows) := p_appl_hire_nevnt_ind;
  g_hire_evnt_ind(g_no_rows) := p_hire_evnt_ind;
  g_hire_nevnt_ind(g_no_rows) := p_hire_nevnt_ind;
  g_pow1_end_evnt_ind(g_no_rows) := p_pow1_end_evnt_ind;
  g_pow1_end_nevnt_ind(g_no_rows) := p_pow1_end_nevnt_ind;
  g_perf_rtng_evnt_ind(g_no_rows) := p_perf_rtng_evnt_ind;
  g_perf_rtng_nevnt_ind(g_no_rows) := p_perf_rtng_nevnt_ind;
  g_emp_sprtn_evnt_ind(g_no_rows) := p_emp_sprtn_evnt_ind;
  g_emp_sprtn_nevnt_ind(g_no_rows) := p_emp_sprtn_nevnt_ind;
  g_hire_org_chng_ind(g_no_rows) := p_hire_org_chng_ind;
  g_hire_job_chng_ind(g_no_rows) := p_hire_job_chng_ind;
  g_hire_pos_chng_ind(g_no_rows) := p_hire_pos_chng_ind;
  g_hire_grd_chng_ind(g_no_rows) := p_hire_grd_chng_ind;
  g_hire_loc_chng_ind(g_no_rows) := p_hire_loc_chng_ind;
  g_current_record_ind(g_no_rows) := p_current_record_ind;
  g_current_stage_strt_ind(g_no_rows) := p_current_stage_strt_ind;
  g_gen_record_ind(g_no_rows) := p_gen_record_ind;
  g_appl_strt_to_asmt_strt_days(g_no_rows) := p_appl_strt_to_asmt_strt_days;
  g_appl_strt_to_asmt_end_days(g_no_rows) := p_appl_strt_to_asmt_end_days;
  g_appl_strt_to_offr_extd_days(g_no_rows) := p_appl_strt_to_offr_extd_days;
  g_appl_strt_to_offr_rjct_days(g_no_rows) := p_appl_strt_to_offr_rjct_days;
  g_appl_strt_to_offr_acpt_days(g_no_rows) := p_appl_strt_to_offr_acpt_days;
  g_appl_strt_to_hire_days(g_no_rows) := p_appl_strt_to_hire_days;
  g_appl_strt_to_term_days(g_no_rows) := p_appl_strt_to_term_days;
  g_init_appl_stg_ind(g_no_rows) := p_init_appl_stg_ind;
  g_asmt_stg_ind(g_no_rows) := p_asmt_stg_ind;
  g_offr_extd_stg_ind(g_no_rows) := p_offr_extd_stg_ind;
  g_strt_pndg_stg_ind(g_no_rows) := p_strt_pndg_stg_ind;
  g_hire_stg_ind(g_no_rows) := p_hire_stg_ind;
  g_appl_strt_date(g_no_rows) := p_appl_strt_date;
  g_asmt_strt_date(g_no_rows) := p_asmt_strt_date;
  g_asmt_end_date(g_no_rows) := p_asmt_end_date;
  g_offr_extd_date(g_no_rows) := p_offr_extd_date;
  g_offr_rjct_date(g_no_rows) := p_offr_rjct_date;
  g_offr_acpt_date(g_no_rows) := p_offr_acpt_date;
  g_appl_term_date(g_no_rows) := p_appl_term_date;
  g_hire_date(g_no_rows) := p_hire_date;
  g_emp_sprtn_date(g_no_rows) := p_emp_sprtn_date;
  g_event_date(g_no_rows) := p_event_date;
  g_stage_start_date(g_no_rows) := p_stage_start_date;
  g_adt_assignment_id(g_no_rows) := p_adt_assignment_id;
  g_adt_asg_effctv_start_date(g_no_rows) := p_adt_asg_effctv_start_date;
  g_adt_asg_effctv_end_date(g_no_rows) := p_adt_asg_effctv_end_date;
  g_adt_application_id(g_no_rows) := p_adt_application_id;

END insert_row;


-- ----------------------------------------------------------------------------
-- Returns date tracked end date for event row
-- ----------------------------------------------------------------------------
FUNCTION get_end_date(p_dt_idx_tab    IN g_number_tab_type,
                      p_info_rec      IN g_info_rec_type,
                      p_master_idx    IN NUMBER,
                      p_event_idx     IN NUMBER)
         RETURN DATE IS

  l_dt_end_idx   NUMBER;
  l_end_date     DATE;

BEGIN

  -- Set end date if event is flagged as a date-track event
  IF p_dt_idx_tab.EXISTS(p_master_idx) THEN

    IF (p_dt_idx_tab(p_master_idx) = p_event_idx) THEN

      l_dt_end_idx := p_dt_idx_tab.NEXT(p_master_idx);

      -- If no further date tracked records then use end of time
      IF l_dt_end_idx IS NULL THEN
        l_end_date := g_end_of_time;
      ELSE
        l_end_date := p_info_rec.idx_strt_date + l_dt_end_idx - 1;
      END IF;

    END IF;

  END IF;

  RETURN l_end_date;

END get_end_date;


-- ----------------------------------------------------------------------------
-- Loops through data structures and inserts records into PL/SQL structure
-- ready for bulk insert
-- ----------------------------------------------------------------------------
PROCEDURE merge_and_insert_data
   (p_master_tab   IN g_master_tab_type,
    p_apl_tab      IN g_apl_tab_type,
    p_dt_idx_tab   IN g_number_tab_type,
    p_info_rec     IN g_info_rec_type,
    p_ind_rec      IN g_ind_rec_type) IS

  l_master_idx               NUMBER;
  l_last_idx                 NUMBER;
  l_event_idx                NUMBER;
  l_apl_idx                  NUMBER;
  l_ind_rec                  g_ind_rec_type;
  l_gen_record_ind           NUMBER;
  l_end_date                 DATE;
  l_master_tab               g_master_tab_type;
  l_current_stage_strt_ind   PLS_INTEGER;
  l_current_stage_strt_seq   PLS_INTEGER;

BEGIN

  -- Copy the master table
  l_master_tab := p_master_tab;

  -- Set master index to first record
  -- Set current indicator for last record
  BEGIN

    -- Set indexes
    l_master_idx := p_master_tab.FIRST;
    l_last_idx   := p_master_tab.LAST;
    l_event_idx  := p_master_tab(l_last_idx).LAST;

    -- Set current indicator
    l_master_tab(l_last_idx)(l_event_idx).event_ind.current_record_ind := 1;

  -- Trap any exception that occurs if the master table is empty
  EXCEPTION WHEN OTHERS THEN
    null;
  END;

  -- Loop until all records have been processed
  WHILE l_master_idx IS NOT NULL LOOP

    -- Loop through events occurring on the same day
    FOR l_event_idx IN 1..l_master_tab(l_master_idx).LAST LOOP

      -- Extract information from master table
      l_apl_idx := l_master_tab(l_master_idx)(l_event_idx).apl_idx;
      l_ind_rec := l_master_tab(l_master_idx)(l_event_idx).event_ind;
      IF l_master_tab(l_master_idx)(l_event_idx).cnstrct_evt = 'Y' THEN
        l_gen_record_ind := 1;
      ELSE
        l_gen_record_ind := 0;
      END IF;

      -- Determine current_stage_start
      IF l_master_tab(l_master_idx)(l_event_idx).stage_code = p_info_rec.latest_stage AND
         l_current_stage_strt_seq IS NULL THEN
        l_current_stage_strt_seq := l_master_tab(l_master_idx)(l_event_idx).event_seq;
        l_current_stage_strt_ind := 1;
      ELSE
        l_current_stage_strt_ind := 0;
      END IF;

      -- Set date-track end date
      l_end_date := get_end_date
                     (p_dt_idx_tab => p_dt_idx_tab,
                      p_info_rec   => p_info_rec,
                      p_master_idx => l_master_idx,
                      p_event_idx  => l_event_idx);

      -- Insert record for each event
      insert_row
       (p_time_day_evt_fk => p_apl_tab(l_apl_idx).time_day_evt_fk
       ,p_time_day_evt_end_fk => p_apl_tab(l_apl_idx).time_day_evt_end_fk
       ,p_time_day_stg_evt_eff_end_fk => l_end_date
       ,p_person_cand_fk => p_apl_tab(l_apl_idx).person_cand_fk
       ,p_person_mngr_fk => p_apl_tab(l_apl_idx).person_mngr_fk
       ,p_person_rcrt_fk => p_apl_tab(l_apl_idx).person_rcrt_fk
       ,p_person_rmgr_fk => p_apl_tab(l_apl_idx).person_rmgr_fk
       ,p_person_auth_fk => p_apl_tab(l_apl_idx).person_auth_fk
       ,p_person_refr_fk => p_apl_tab(l_apl_idx).person_refr_fk
       ,p_person_rsed_fk => p_apl_tab(l_apl_idx).person_rsed_fk
       ,p_person_mrgd_fk => p_apl_tab(l_apl_idx).person_mrgd_fk
       ,p_org_organztn_fk => p_apl_tab(l_apl_idx).org_organztn_fk
       ,p_org_organztn_mrgd_fk => p_apl_tab(l_apl_idx).org_organztn_mrgd_fk
       ,p_org_organztn_recr_fk => p_apl_tab(l_apl_idx).org_organztn_recr_fk
       ,p_geo_location_fk => p_apl_tab(l_apl_idx).geo_location_fk
       ,p_job_job_fk => p_apl_tab(l_apl_idx).job_job_fk
       ,p_grd_grade_fk => p_apl_tab(l_apl_idx).grd_grade_fk
       ,p_pos_position_fk => p_apl_tab(l_apl_idx).pos_position_fk
       ,p_prfm_perfband_fk => p_info_rec.perf_band
       ,p_rvac_vacncy_fk => p_apl_tab(l_apl_idx).rvac_vacncy_fk
       ,p_ract_recactvy_fk => p_apl_tab(l_apl_idx).ract_recactvy_fk
       ,p_rev_recevent_fk => l_master_tab(l_master_idx)(l_event_idx).event_code
       ,p_rern_recevtrn_fk => p_apl_tab(l_apl_idx).rern_recevtrn_fk
       ,p_tarn_trmaplrn_fk => p_apl_tab(l_apl_idx).tarn_trmaplrn_fk
       ,p_headcount => p_apl_tab(l_apl_idx).headcount
       ,p_fte => p_apl_tab(l_apl_idx).fte
       ,p_nrmlsd_perf_rtng => p_info_rec.perf_norm_rtng
       ,p_event_seq => l_master_tab(l_master_idx)(l_event_idx).event_seq
       ,p_appl_ind  => l_ind_rec.appl_ind
       ,p_appl_new_ind => l_ind_rec.appl_new_ind
       ,p_appl_emp_ind => l_ind_rec.appl_emp_ind
       ,p_appl_cwk_ind => l_ind_rec.appl_cwk_ind
       ,p_appl_strt_evnt_ind => l_ind_rec.appl_strt_evnt_ind
       ,p_appl_strt_nevnt_ind => p_ind_rec.appl_strt_nevnt_ind
       ,p_asmt_strt_evnt_ind => l_ind_rec.asmt_strt_evnt_ind
       ,p_asmt_strt_nevnt_ind => p_ind_rec.asmt_strt_nevnt_ind
       ,p_asmt_end_evnt_ind => l_ind_rec.asmt_end_evnt_ind
       ,p_asmt_end_nevnt_ind => p_ind_rec.asmt_end_nevnt_ind
       ,p_offr_extd_evnt_ind => l_ind_rec.offr_extd_evnt_ind
       ,p_offr_extd_nevnt_ind => p_ind_rec.offr_extd_nevnt_ind
       ,p_offr_rjct_evnt_ind => l_ind_rec.offr_rjct_evnt_ind
       ,p_offr_rjct_nevnt_ind => p_ind_rec.offr_rjct_nevnt_ind
       ,p_offr_acpt_evnt_ind => l_ind_rec.offr_acpt_evnt_ind
       ,p_offr_acpt_nevnt_ind => p_ind_rec.offr_acpt_nevnt_ind
       ,p_appl_term_evnt_ind => l_ind_rec.appl_term_evnt_ind
       ,p_appl_term_nevnt_ind => p_ind_rec.appl_term_nevnt_ind
       ,p_appl_term_vol_evnt_ind => l_ind_rec.appl_term_vol_evnt_ind
       ,p_appl_term_vol_nevnt_ind => p_ind_rec.appl_term_vol_nevnt_ind
       ,p_appl_term_invol_evnt_ind => l_ind_rec.appl_term_invol_evnt_ind
       ,p_appl_term_invol_nevnt_ind => p_ind_rec.appl_term_invol_nevnt_ind
       ,p_appl_hire_evnt_ind => l_ind_rec.appl_hire_evnt_ind
       ,p_appl_hire_nevnt_ind => p_ind_rec.appl_hire_nevnt_ind
       ,p_hire_evnt_ind => l_ind_rec.hire_evnt_ind
       ,p_hire_nevnt_ind => p_ind_rec.hire_nevnt_ind
       ,p_pow1_end_evnt_ind => l_ind_rec.pow1_end_evnt_ind
       ,p_pow1_end_nevnt_ind => p_ind_rec.pow1_end_nevnt_ind
       ,p_perf_rtng_evnt_ind => l_ind_rec.perf_rtng_evnt_ind
       ,p_perf_rtng_nevnt_ind => p_ind_rec.perf_rtng_nevnt_ind
       ,p_emp_sprtn_evnt_ind => l_ind_rec.emp_sprtn_evnt_ind
       ,p_emp_sprtn_nevnt_ind => p_ind_rec.emp_sprtn_nevnt_ind
       ,p_hire_org_chng_ind => l_ind_rec.hire_org_chng_ind
       ,p_hire_job_chng_ind => l_ind_rec.hire_job_chng_ind
       ,p_hire_pos_chng_ind => l_ind_rec.hire_pos_chng_ind
       ,p_hire_grd_chng_ind => l_ind_rec.hire_grd_chng_ind
       ,p_hire_loc_chng_ind => l_ind_rec.hire_loc_chng_ind
       ,p_current_record_ind => l_ind_rec.current_record_ind
       ,p_current_stage_strt_ind => l_current_stage_strt_ind
       ,p_gen_record_ind => l_gen_record_ind
       ,p_appl_strt_to_asmt_strt_days => p_info_rec.asmt_strt_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_asmt_end_days => p_info_rec.asmt_end_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_offr_extd_days => p_info_rec.offr_extd_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_offr_rjct_days => p_info_rec.offr_rjct_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_offr_acpt_days => p_info_rec.offr_acpt_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_hire_days => p_info_rec.hire_date - p_info_rec.appl_strt_date
       ,p_appl_strt_to_term_days => p_info_rec.appl_term_date - p_info_rec.appl_strt_date
       ,p_init_appl_stg_ind => l_ind_rec.init_appl_stg_ind
       ,p_asmt_stg_ind => l_ind_rec.asmt_stg_ind
       ,p_offr_extd_stg_ind => l_ind_rec.offr_extd_stg_ind
       ,p_strt_pndg_stg_ind => l_ind_rec.strt_pndg_stg_ind
       ,p_hire_stg_ind => l_ind_rec.hire_stg_ind
       ,p_appl_strt_date => p_info_rec.appl_strt_date
       ,p_asmt_strt_date => p_info_rec.asmt_strt_date
       ,p_asmt_end_date => p_info_rec.asmt_end_date
       ,p_offr_extd_date => p_info_rec.offr_extd_date
       ,p_offr_rjct_date => p_info_rec.offr_rjct_date
       ,p_offr_acpt_date => p_info_rec.offr_acpt_date
       ,p_appl_term_date => p_info_rec.appl_term_date
       ,p_hire_date => p_info_rec.hire_date
       ,p_emp_sprtn_date => to_date(null)
       ,p_event_date => p_apl_tab(l_apl_idx).event_date
       ,p_stage_start_date => p_apl_tab(l_apl_idx).stage_start_date
       ,p_adt_assignment_id => p_info_rec.asg_id
       ,p_adt_asg_effctv_start_date => p_apl_tab(l_apl_idx).time_day_evt_fk
       ,p_adt_asg_effctv_end_date => p_apl_tab(l_apl_idx).time_day_evt_end_fk
       ,p_adt_application_id => p_apl_tab(l_apl_idx).adt_application_id);

    END LOOP;

    -- Increment master index
    l_master_idx := l_master_tab.NEXT(l_master_idx);

  END LOOP;

END merge_and_insert_data;


-- ----------------------------------------------------------------------------
-- Determines event for a particular assignment status and event history
-- ----------------------------------------------------------------------------
FUNCTION get_event_code(p_apl_tab        IN g_apl_tab_type,
                        p_apl_idx        IN NUMBER)
       RETURN VARCHAR2 IS

  l_status_change   BOOLEAN;
  l_event_code      VARCHAR2(30);

BEGIN

  -- Detect whether event is a status change
  IF p_apl_idx = 1 THEN
    l_status_change := TRUE;
  ELSE
    IF (p_apl_tab(p_apl_idx).assignment_status_type_id <>
        p_apl_tab(p_apl_idx - 1).assignment_status_type_id) THEN
      l_status_change := TRUE;
    ELSE
      l_status_change := FALSE;
    END IF;
  END IF;

  -- If event is a status change, determine the event code
  IF l_status_change THEN
    l_event_code := hri_bpl_rec_pipln.get_event_code
                     (p_system_status => p_apl_tab(p_apl_idx).per_system_status,
                      p_status_id => p_apl_tab(p_apl_idx).assignment_status_type_id,
                      p_user_status => p_apl_tab(p_apl_idx).user_status);
  -- Otherwise classify the event as a non-pipeline event
  ELSE
    l_event_code := 'NA_EDW';
  END IF;

  -- Check if event has already occurred - if so then
  -- subsequent identical events are not classified
  IF g_event_cache.EXISTS(l_event_code) THEN
    l_event_code := 'NA_EDW';

  -- Otherwise note the first occurrence of the event
  ELSE
    g_event_cache(l_event_code) := 'Y';
  END IF;

  RETURN l_event_code;

END get_event_code;


-- ----------------------------------------------------------------------------
-- Interprets a given applicant assignment event within the framework of
-- recruitment pipeline stages and events
-- ----------------------------------------------------------------------------
PROCEDURE interpret_appl_event(p_master_tab     IN OUT NOCOPY g_master_tab_type,
                               p_apl_tab        IN g_apl_tab_type,
                               p_apl_idx        IN NUMBER,
                               p_dt_idx_tab     IN OUT NOCOPY g_number_tab_type,
                               p_info_rec       IN OUT NOCOPY g_info_rec_type,
                               p_ind_rec        IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;
  l_con_rec         g_ind_rec_type;

  l_construct_appl_strt_stg     BOOLEAN;
  l_construct_asmt_strt_stg     BOOLEAN;
  l_construct_offr_extd_stg     BOOLEAN;

BEGIN

  -- dbg('Interpreting event on:  ' || to_char(p_apl_tab(p_apl_idx).time_day_evt_fk));

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set master table index
  l_master_idx := p_apl_tab(p_apl_idx).time_day_evt_fk - p_info_rec.idx_strt_date;

  -- Set event index to the last index on the current day
  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Get Stage Code
  l_stage_code := hri_bpl_rec_pipln.get_stage_code
                   (p_system_status => p_apl_tab(p_apl_idx).per_system_status,
                    p_status_id   => p_apl_tab(p_apl_idx).assignment_status_type_id,
                    p_user_status => p_apl_tab(p_apl_idx).user_status);

  -- Get Event Code
  l_event_code := get_event_code
                   (p_apl_tab   => p_apl_tab,
                    p_apl_idx   => p_apl_idx);

  -- dbg('Event:   ' || l_event_code || '   Stage:   ' || l_stage_code);

  -- -----------------------------------------------------
  -- STAGES - Identify events signifying new stage reached
  -- -----------------------------------------------------

  -- Application Start
  IF (l_stage_code = 'INIT_APPL_STG' AND
      p_info_rec.appl_strt_date IS NULL) THEN

    p_info_rec.appl_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_info_rec.latest_stage := 'INIT_APPL_STG';
    p_info_rec.curr_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    l_ind_rec.appl_strt_evnt_ind := 1;
    p_ind_rec.appl_strt_nevnt_ind := 1;
    l_ind_rec.init_appl_stg_ind := 1;
    p_ind_rec.init_appl_stg_ind := 1;

  -- Assessment Start
  ELSIF (l_stage_code = 'ASMT_STG' AND
         p_info_rec.asmt_strt_date IS NULL) THEN

    -- Construct Application Start Stage if it was skipped
    IF (p_info_rec.appl_strt_date IS NULL) THEN
      l_construct_appl_strt_stg := TRUE;
    END IF;

    -- Construct Assessment Start Stage if it is not directly mapped
    IF (l_event_code <> 'ASMT_STRT') THEN
      l_construct_asmt_strt_stg := TRUE;
    ELSE
      l_ind_rec.asmt_strt_evnt_ind := 1;
      p_ind_rec.asmt_strt_nevnt_ind := 1;
    END IF;

    p_info_rec.asmt_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_info_rec.latest_stage := 'ASMT_STG';
    p_info_rec.curr_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    l_ind_rec.init_appl_stg_ind := 0;
    p_ind_rec.init_appl_stg_ind := 0;
    l_ind_rec.asmt_stg_ind := 1;
    p_ind_rec.asmt_stg_ind := 1;

  -- Offer
  ELSIF (l_stage_code = 'OFFR_EXTD_STG' AND
         p_info_rec.offr_extd_date IS NULL) THEN

    -- Construct Application Start Stage if it was skipped
    IF (p_info_rec.appl_strt_date IS NULL) THEN
      l_construct_appl_strt_stg := TRUE;
    END IF;

    -- Construct Assessment Start Stage if it was skipped
    IF (p_info_rec.asmt_strt_date IS NULL) THEN
      l_construct_asmt_strt_stg := TRUE;
    END IF;

    -- Flag Assessment End
    IF (p_info_rec.asmt_end_date IS NULL) THEN
      p_info_rec.asmt_end_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
      l_ind_rec.asmt_end_evnt_ind := 1;
      p_ind_rec.asmt_end_nevnt_ind := 1;
    END IF;

    p_info_rec.offr_extd_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_info_rec.latest_stage := 'OFFR_EXTD_STG';
    p_info_rec.curr_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    l_ind_rec.offr_extd_evnt_ind := 1;
    p_ind_rec.offr_extd_nevnt_ind := 1;
    l_ind_rec.init_appl_stg_ind := 0;
    p_ind_rec.init_appl_stg_ind := 0;
    l_ind_rec.asmt_stg_ind := 0;
    p_ind_rec.asmt_stg_ind := 0;
    l_ind_rec.offr_extd_stg_ind := 1;
    p_ind_rec.offr_extd_stg_ind := 1;

  -- Offer Accepted
  ELSIF (l_stage_code = 'STRT_PNDG_STG' AND
         p_info_rec.offr_acpt_date IS NULL) THEN

    -- Construct Application Start Stage if it was skipped
    IF (p_info_rec.appl_strt_date IS NULL) THEN
      l_construct_appl_strt_stg := TRUE;
    END IF;

    -- Construct Assessment Start Stage if it was skipped
    IF (p_info_rec.asmt_strt_date IS NULL) THEN
      l_construct_asmt_strt_stg := TRUE;
    END IF;

    -- Construct Offer Stage if it was skipped
    IF (p_info_rec.offr_extd_date IS NULL) THEN
      l_construct_offr_extd_stg := TRUE;
    END IF;

    -- Flag Assessment End
    IF (p_info_rec.asmt_end_date IS NULL) THEN
      p_info_rec.asmt_end_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
      l_ind_rec.asmt_end_evnt_ind := 1;
      p_ind_rec.asmt_end_nevnt_ind := 1;
    END IF;

    p_info_rec.offr_acpt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_info_rec.latest_stage := 'STRT_PNDG_STG';
    p_info_rec.curr_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    l_ind_rec.offr_acpt_evnt_ind := 1;
    p_ind_rec.offr_acpt_nevnt_ind := 1;
    l_ind_rec.init_appl_stg_ind := 0;
    p_ind_rec.init_appl_stg_ind := 0;
    l_ind_rec.asmt_stg_ind := 0;
    p_ind_rec.asmt_stg_ind := 0;
    l_ind_rec.offr_extd_stg_ind := 0;
    p_ind_rec.offr_extd_stg_ind := 0;
    l_ind_rec.strt_pndg_stg_ind := 1;
    p_ind_rec.strt_pndg_stg_ind := 1;

  -- Termination
  ELSIF (l_stage_code = 'APPL_TERM_STG') THEN

    p_info_rec.appl_term_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_info_rec.latest_stage := 'APPL_TERM_STG';
    p_info_rec.curr_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    l_ind_rec.appl_term_evnt_ind := 1;
    p_ind_rec.appl_term_nevnt_ind := 1;
    l_ind_rec.init_appl_stg_ind := 0;
    p_ind_rec.init_appl_stg_ind := 0;
    l_ind_rec.asmt_stg_ind := 0;
    p_ind_rec.asmt_stg_ind := 0;
    l_ind_rec.offr_extd_stg_ind := 0;
    p_ind_rec.offr_extd_stg_ind := 0;
    l_ind_rec.strt_pndg_stg_ind := 0;
    p_ind_rec.strt_pndg_stg_ind := 0;

  END IF;


  -- ------------------------------------------------------------
  -- CONSTRUCTED STAGE EVENTS - Fill in events for skipped stages
  -- ------------------------------------------------------------

  -- Construct application start stage
  IF l_construct_appl_strt_stg THEN
    l_con_rec := p_ind_rec;
    l_con_rec.init_appl_stg_ind := 1;
    l_con_rec.asmt_stg_ind := 0;
    l_con_rec.offr_extd_stg_ind := 0;
    l_con_rec.strt_pndg_stg_ind := 0;
    l_con_rec.appl_strt_evnt_ind  := 1;
    p_ind_rec.appl_strt_nevnt_ind := 1;
    l_event_idx := l_event_idx + 1;
    p_info_rec.event_seq := p_info_rec.event_seq + 1;
    p_info_rec.appl_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_master_tab(l_master_idx)(l_event_idx).apl_idx     := p_apl_idx;
    p_master_tab(l_master_idx)(l_event_idx).event_seq   := p_info_rec.event_seq;
    p_master_tab(l_master_idx)(l_event_idx).event_code  := 'APPL_STRT';
    p_master_tab(l_master_idx)(l_event_idx).stage_code  := 'INIT_APPL_STG';
    p_master_tab(l_master_idx)(l_event_idx).event_ind   := l_con_rec;
    p_master_tab(l_master_idx)(l_event_idx).cnstrct_evt := 'Y';
    p_dt_idx_tab(l_master_idx) := l_event_idx;
  END IF;

  -- Construct assessment start stage
  IF l_construct_asmt_strt_stg THEN
    l_con_rec := p_ind_rec;
    l_con_rec.init_appl_stg_ind := 0;
    l_con_rec.asmt_stg_ind := 1;
    l_con_rec.offr_extd_stg_ind := 0;
    l_con_rec.strt_pndg_stg_ind := 0;
    l_con_rec.asmt_strt_evnt_ind  := 1;
    p_ind_rec.asmt_strt_nevnt_ind := 1;
    l_event_idx := l_event_idx + 1;
    p_info_rec.event_seq := p_info_rec.event_seq + 1;
    p_info_rec.asmt_strt_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_master_tab(l_master_idx)(l_event_idx).apl_idx     := p_apl_idx;
    p_master_tab(l_master_idx)(l_event_idx).event_seq   := p_info_rec.event_seq;
    p_master_tab(l_master_idx)(l_event_idx).event_code  := 'ASMT_STRT';
    p_master_tab(l_master_idx)(l_event_idx).stage_code  := 'ASMT_STG';
    p_master_tab(l_master_idx)(l_event_idx).event_ind   := l_con_rec;
    p_master_tab(l_master_idx)(l_event_idx).cnstrct_evt := 'Y';
    p_dt_idx_tab(l_master_idx) := l_event_idx;
  END IF;

  -- Construct offer extended stage
  IF l_construct_offr_extd_stg THEN
    l_con_rec := p_ind_rec;
    l_con_rec.init_appl_stg_ind := 0;
    l_con_rec.asmt_stg_ind := 0;
    l_con_rec.offr_extd_stg_ind := 1;
    l_con_rec.strt_pndg_stg_ind := 0;
    l_con_rec.offr_extd_evnt_ind  := 1;
    p_ind_rec.offr_extd_nevnt_ind := 1;
    l_event_idx := l_event_idx + 1;
    p_info_rec.event_seq := p_info_rec.event_seq + 1;
    p_info_rec.offr_extd_date := p_apl_tab(p_apl_idx).time_day_evt_fk;
    p_master_tab(l_master_idx)(l_event_idx).apl_idx     := p_apl_idx;
    p_master_tab(l_master_idx)(l_event_idx).event_seq   := p_info_rec.event_seq;
    p_master_tab(l_master_idx)(l_event_idx).event_code  := 'OFFR_EXTD';
    p_master_tab(l_master_idx)(l_event_idx).stage_code  := 'OFFR_EXTD_STG';
    p_master_tab(l_master_idx)(l_event_idx).event_ind   := l_con_rec;
    p_master_tab(l_master_idx)(l_event_idx).cnstrct_evt := 'Y';
    p_dt_idx_tab(l_master_idx) := l_event_idx;
  END IF;

  -- -------------------------------------------------------
  -- STAGE EVENTS - Identify events occurring within a stage
  -- -------------------------------------------------------

  -- Assessment Step 1
  IF (l_event_code = 'ASMT_INT1' AND
      p_info_rec.asmt_int1_date IS NULL) THEN

    p_info_rec.asmt_int1_date := p_apl_tab(p_apl_idx).time_day_evt_fk;

  -- Assessment Step 2
  ELSIF (l_event_code = 'ASMT_INT2' AND
      p_info_rec.asmt_int2_date IS NULL) THEN

    p_info_rec.asmt_int2_date := p_apl_tab(p_apl_idx).time_day_evt_fk;

  -- Other user defined
  ELSIF l_stage_code IS NULL THEN

    -- Add code to handle user defined stages/events
    null;

  END IF;

  -- Update master record with event if it is not unassigned, skip or null
  IF l_event_code <> 'NA_EDW' AND
     l_event_code <> 'SKIP' THEN

    l_event_idx := l_event_idx + 1;
    p_info_rec.event_seq := p_info_rec.event_seq + 1;
    p_master_tab(l_master_idx)(l_event_idx).apl_idx    := p_apl_idx;
    p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
    p_master_tab(l_master_idx)(l_event_idx).event_code := l_event_code;
    p_master_tab(l_master_idx)(l_event_idx).stage_code := l_stage_code;
    p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;

    -- Keep date-tracked status for pipeline events
    IF l_stage_code <> 'NON_PIPLN_STG' THEN
      p_dt_idx_tab(l_master_idx) := l_event_idx;
    END IF;

  END IF;

END interpret_appl_event;


-- ----------------------------------------------------------------------------
-- Adds application fail event
-- ----------------------------------------------------------------------------
PROCEDURE add_appl_fail_event
    (p_master_tab     IN OUT NOCOPY g_master_tab_type,
     p_apl_tab        IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab     IN OUT NOCOPY g_number_tab_type,
     p_info_rec       IN OUT NOCOPY g_info_rec_type,
     p_ind_rec        IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_apl_idx         PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;
  l_term_type       VARCHAR2(30);

BEGIN

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set master table index
  l_master_idx := p_info_rec.appl_end_date - p_info_rec.idx_strt_date + 1;

  -- Set event index to the last index on the current day
  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Add termination record to applicant cursor
  l_apl_idx := p_info_rec.last_apl_idx;
  p_apl_tab(l_apl_idx+1).time_day_evt_fk           := p_apl_tab(l_apl_idx).time_day_evt_end_fk + 1;
  p_apl_tab(l_apl_idx+1).time_day_evt_end_fk       := g_end_of_time;
  p_apl_tab(l_apl_idx+1).person_cand_fk            := p_apl_tab(l_apl_idx).person_cand_fk;
  p_apl_tab(l_apl_idx+1).person_mngr_fk            := p_apl_tab(l_apl_idx).person_mngr_fk;
  p_apl_tab(l_apl_idx+1).person_rcrt_fk            := p_apl_tab(l_apl_idx).person_rcrt_fk;
  p_apl_tab(l_apl_idx+1).person_rmgr_fk            := p_apl_tab(l_apl_idx).person_rmgr_fk;
  p_apl_tab(l_apl_idx+1).person_auth_fk            := p_apl_tab(l_apl_idx).person_auth_fk;
  p_apl_tab(l_apl_idx+1).person_refr_fk            := p_apl_tab(l_apl_idx).person_refr_fk;
  p_apl_tab(l_apl_idx+1).person_rsed_fk            := p_apl_tab(l_apl_idx).person_rsed_fk;
  p_apl_tab(l_apl_idx+1).person_mrgd_fk            := p_apl_tab(l_apl_idx).person_mrgd_fk;
  p_apl_tab(l_apl_idx+1).org_organztn_fk           := p_apl_tab(l_apl_idx).org_organztn_fk;
  p_apl_tab(l_apl_idx+1).org_organztn_mrgd_fk      := p_apl_tab(l_apl_idx).org_organztn_mrgd_fk;
  p_apl_tab(l_apl_idx+1).org_organztn_recr_fk      := p_apl_tab(l_apl_idx).org_organztn_recr_fk;
  p_apl_tab(l_apl_idx+1).geo_location_fk           := p_apl_tab(l_apl_idx).geo_location_fk;
  p_apl_tab(l_apl_idx+1).job_job_fk                := p_apl_tab(l_apl_idx).job_job_fk;
  p_apl_tab(l_apl_idx+1).grd_grade_fk              := p_apl_tab(l_apl_idx).grd_grade_fk;
  p_apl_tab(l_apl_idx+1).pos_position_fk           := p_apl_tab(l_apl_idx).pos_position_fk;
  p_apl_tab(l_apl_idx+1).prfm_perfband_fk          := p_apl_tab(l_apl_idx).prfm_perfband_fk;
  p_apl_tab(l_apl_idx+1).rvac_vacncy_fk            := p_apl_tab(l_apl_idx).rvac_vacncy_fk;
  p_apl_tab(l_apl_idx+1).ract_recactvy_fk          := p_apl_tab(l_apl_idx).ract_recactvy_fk;
  p_apl_tab(l_apl_idx+1).rern_recevtrn_fk          := 'NA_EDW';
  p_apl_tab(l_apl_idx+1).tarn_trmaplrn_fk          := p_apl_tab(l_apl_idx).tarn_trmaplrn_fk;
  p_apl_tab(l_apl_idx+1).adt_application_id        := p_apl_tab(l_apl_idx).adt_application_id;
  p_apl_tab(l_apl_idx+1).adt_business_group_id     := p_apl_tab(l_apl_idx).adt_business_group_id;
  p_apl_tab(l_apl_idx+1).event_date                := p_apl_tab(l_apl_idx).time_day_evt_end_fk + 1;
  p_apl_tab(l_apl_idx+1).stage_start_date          := p_apl_tab(l_apl_idx).time_day_evt_end_fk + 1;
  p_apl_tab(l_apl_idx+1).per_system_status         := null;
  p_apl_tab(l_apl_idx+1).user_status               := null;
  p_apl_tab(l_apl_idx+1).assignment_status_type_id := to_number(null);
  p_apl_tab(l_apl_idx+1).headcount                 := p_apl_tab(l_apl_idx).headcount;
  p_apl_tab(l_apl_idx+1).fte                       := p_apl_tab(l_apl_idx).fte;

  -- Get Stage Code
  l_stage_code := 'APPL_TERM_STG';

  -- Get Event Code
  IF p_info_rec.latest_stage = 'INIT_APPL_STG' THEN
    l_event_code := 'APPL_TERM_INIT';
  ELSIF p_info_rec.latest_stage = 'ASMT_STG' THEN
    l_event_code := 'APPL_TERM_ASMT';
  ELSIF p_info_rec.latest_stage = 'OFFR_EXTD_STG' THEN
    l_event_code := 'APPL_TERM_OFFR';
    p_info_rec.offr_rjct_date := p_info_rec.appl_end_date + 1;
    p_ind_rec.offr_rjct_nevnt_ind := 1;
    l_ind_rec.offr_rjct_evnt_ind := 1;
  ELSIF p_info_rec.latest_stage = 'STRT_PNDG_STG' THEN
    l_event_code := 'APPL_TERM_ACPT';
  ELSE
    l_event_code := 'APPL_TERM';
  END IF;

  -- Get vol/invol status
  l_term_type := hri_bpl_rec_pipln.get_appl_term_type
                  (p_appl_term_rsn => p_info_rec.appl_term_rsn);

  -- Set Indicators/Info
  p_info_rec.latest_stage := l_stage_code;
  p_info_rec.appl_term_date := p_info_rec.appl_end_date + 1;
  l_ind_rec.appl_term_evnt_ind := 1;
  p_ind_rec.appl_term_nevnt_ind := 1;
  l_ind_rec.init_appl_stg_ind := 0;
  l_ind_rec.asmt_stg_ind := 0;
  l_ind_rec.offr_extd_stg_ind := 0;
  l_ind_rec.strt_pndg_stg_ind := 0;
  l_ind_rec.hire_stg_ind := 0;

  -- Set vol/invol indicators
  IF l_term_type = 'V' THEN
    l_ind_rec.appl_term_vol_evnt_ind := 1;
    p_ind_rec.appl_term_vol_nevnt_ind := 1;
  ELSE
    l_ind_rec.appl_term_invol_evnt_ind := 1;
    p_ind_rec.appl_term_invol_nevnt_ind := 1;
  END IF;

  -- Add Application Termination Event
  l_event_idx := l_event_idx + 1;
  p_info_rec.event_seq := p_info_rec.event_seq + 1;
  p_master_tab(l_master_idx)(l_event_idx).apl_idx    := l_apl_idx + 1;
  p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
  p_master_tab(l_master_idx)(l_event_idx).event_code := l_event_code;
  p_master_tab(l_master_idx)(l_event_idx).stage_code := l_stage_code;
  p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;
  p_dt_idx_tab(l_master_idx) := l_event_idx;

END add_appl_fail_event;


-- ----------------------------------------------------------------------------
-- Adds hire event
-- ----------------------------------------------------------------------------
PROCEDURE add_hire_event
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_apl_idx         PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;

BEGIN

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set apl idx
  l_apl_idx := p_info_rec.last_apl_idx;

  -- Set info details
  p_info_rec.hire_date := p_apl_tab(l_apl_idx).event_date;
  p_info_rec.latest_stage := 'HIRE_STG';
  IF (p_info_rec.idx_strt_date IS NULL) THEN
    p_info_rec.idx_strt_date := p_info_rec.hire_date;
  END IF;

  -- Set indicators for hire
  l_ind_rec.appl_hire_evnt_ind  := l_ind_rec.appl_ind;
  p_ind_rec.appl_hire_nevnt_ind := l_ind_rec.appl_ind;
  l_ind_rec.hire_evnt_ind       := 1;
  p_ind_rec.hire_nevnt_ind      := 1;
  l_ind_rec.init_appl_stg_ind   := 0;
  p_ind_rec.init_appl_stg_ind   := 0;
  l_ind_rec.asmt_stg_ind        := 0;
  p_ind_rec.asmt_stg_ind        := 0;
  l_ind_rec.offr_extd_stg_ind   := 0;
  p_ind_rec.offr_extd_stg_ind   := 0;
  l_ind_rec.strt_pndg_stg_ind   := 0;
  p_ind_rec.strt_pndg_stg_ind   := 0;
  l_ind_rec.hire_stg_ind        := 1;
  p_ind_rec.hire_stg_ind        := 1;

  -- Set dimension change indicators
  IF l_ind_rec.appl_ind = 1 THEN
    IF p_apl_tab(l_apl_idx).org_organztn_fk <> p_apl_tab(1).org_organztn_fk THEN
      l_ind_rec.hire_org_chng_ind := 1;
    END IF;
    IF p_apl_tab(l_apl_idx).geo_location_fk <> p_apl_tab(1).geo_location_fk THEN
      l_ind_rec.hire_loc_chng_ind := 1;
    END IF;
    IF p_apl_tab(l_apl_idx).job_job_fk <> p_apl_tab(1).job_job_fk THEN
      l_ind_rec.hire_job_chng_ind := 1;
    END IF;
    IF p_apl_tab(l_apl_idx).grd_grade_fk <> p_apl_tab(1).grd_grade_fk THEN
      l_ind_rec.hire_grd_chng_ind := 1;
    END IF;
    IF p_apl_tab(l_apl_idx).pos_position_fk <> p_apl_tab(1).pos_position_fk THEN
      l_ind_rec.hire_pos_chng_ind := 1;
    END IF;
  END IF;

  -- Set master table index
  l_master_idx := p_info_rec.hire_date - p_info_rec.idx_strt_date;

  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Add Hire
  l_event_idx := l_event_idx + 1;
  p_info_rec.event_seq := p_info_rec.event_seq + 1;
  p_master_tab(l_master_idx)(l_event_idx).apl_idx    := l_apl_idx;
  p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
  p_master_tab(l_master_idx)(l_event_idx).event_code := 'EMPL_HIRE';
  p_master_tab(l_master_idx)(l_event_idx).stage_code := 'HIRE_STG';
  p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;
  p_dt_idx_tab(l_master_idx) := l_event_idx;

END add_hire_event;


-- ----------------------------------------------------------------------------
-- Adds POW band 1 event
-- ----------------------------------------------------------------------------
PROCEDURE add_pow1_event
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;
  l_apl_rec         g_apl_event_rec_type;

BEGIN

  -- Create pipeline record
  l_apl_rec := p_apl_tab(p_info_rec.last_apl_idx);
  p_info_rec.last_apl_idx := p_info_rec.last_apl_idx + 1;
  p_apl_tab(p_info_rec.last_apl_idx) := l_apl_rec;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_fk     := p_info_rec.pow1_date;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_end_fk := p_info_rec.pow1_date;
  p_apl_tab(p_info_rec.last_apl_idx).event_date          := p_info_rec.pow1_date;

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set indicators for pow1 end event
  l_ind_rec.hire_stg_ind := 0;
  l_ind_rec.pow1_end_evnt_ind  := 1;
  p_ind_rec.pow1_end_nevnt_ind := 1;

  -- Set master table index
  l_master_idx := p_info_rec.pow1_date - p_info_rec.idx_strt_date;

  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Add LOW1 band end event
  l_event_idx := l_event_idx + 1;
  p_info_rec.event_seq := p_info_rec.event_seq + 1;
  p_master_tab(l_master_idx)(l_event_idx).apl_idx    := p_info_rec.last_apl_idx;
  p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
  p_master_tab(l_master_idx)(l_event_idx).event_code := 'EMPL_LOW1_END';
  p_master_tab(l_master_idx)(l_event_idx).stage_code := 'HIRE_STG';
  p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;
  p_dt_idx_tab(l_master_idx) := l_event_idx;

END add_pow1_event;


-- ----------------------------------------------------------------------------
-- Adds PERF event
-- ----------------------------------------------------------------------------
PROCEDURE add_perf_event
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;
  l_apl_rec         g_apl_event_rec_type;

BEGIN

  -- Create pipeline record
  l_apl_rec := p_apl_tab(p_info_rec.last_apl_idx);
  p_info_rec.last_apl_idx := p_info_rec.last_apl_idx + 1;
  p_apl_tab(p_info_rec.last_apl_idx) := l_apl_rec;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_fk     := p_info_rec.perf_date;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_end_fk := p_info_rec.perf_date;
  p_apl_tab(p_info_rec.last_apl_idx).event_date          := p_info_rec.perf_date;
  p_apl_tab(p_info_rec.last_apl_idx).prfm_perfband_fk    := p_info_rec.perf_band;
  p_apl_tab(p_info_rec.last_apl_idx).perf_norm_rtng      := p_info_rec.perf_norm_rtng;

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set indicators for hire
  l_ind_rec.perf_rtng_evnt_ind  := 1;
  p_ind_rec.perf_rtng_nevnt_ind := 1;

  -- Set master table index
  l_master_idx := p_info_rec.perf_date - p_info_rec.idx_strt_date;

  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Add Performance Review
  l_event_idx := l_event_idx + 1;
  p_info_rec.event_seq := p_info_rec.event_seq + 1;
  p_master_tab(l_master_idx)(l_event_idx).apl_idx    := p_info_rec.last_apl_idx;
  p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
  p_master_tab(l_master_idx)(l_event_idx).event_code := 'EMPL_APR1';
  p_master_tab(l_master_idx)(l_event_idx).stage_code := 'HIRE_STG';
  p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;
  p_dt_idx_tab(l_master_idx) := l_event_idx;

END add_perf_event;


-- ----------------------------------------------------------------------------
-- Adds EMPL_TERM event if employment is ended before first LOW band is reached
-- ----------------------------------------------------------------------------
PROCEDURE add_emp_sprtn_event
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  l_stage_code      VARCHAR2(30);
  l_event_code      VARCHAR2(30);
  l_master_idx      PLS_INTEGER;
  l_event_idx       PLS_INTEGER;
  l_ind_rec         g_ind_rec_type;
  l_apl_rec         g_apl_event_rec_type;

BEGIN

  -- Create pipeline record
  l_apl_rec := p_apl_tab(p_info_rec.last_apl_idx);
  p_info_rec.last_apl_idx := p_info_rec.last_apl_idx + 1;
  p_apl_tab(p_info_rec.last_apl_idx) := l_apl_rec;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_fk     := p_info_rec.emp_sprtn_date;
  p_apl_tab(p_info_rec.last_apl_idx).time_day_evt_end_fk := p_info_rec.emp_sprtn_date;
  p_apl_tab(p_info_rec.last_apl_idx).event_date          := p_info_rec.emp_sprtn_date;

  -- Copy indicator record
  l_ind_rec := p_ind_rec;

  -- Set indicators for separation event
  l_ind_rec.hire_stg_ind := 0;
  l_ind_rec.emp_sprtn_evnt_ind  := 1;
  p_ind_rec.emp_sprtn_nevnt_ind := 1;

  -- Set master table index
  l_master_idx := p_info_rec.emp_sprtn_date - p_info_rec.idx_strt_date;

  l_event_idx := get_event_idx
                  (p_master_tab => p_master_tab,
                   p_master_idx => l_master_idx);

  -- Add Employee Separation
  l_event_idx := l_event_idx + 1;
  p_info_rec.event_seq := p_info_rec.event_seq + 1;
  p_master_tab(l_master_idx)(l_event_idx).apl_idx    := p_info_rec.last_apl_idx;
  p_master_tab(l_master_idx)(l_event_idx).event_seq  := p_info_rec.event_seq;
  p_master_tab(l_master_idx)(l_event_idx).event_code := 'EMPL_TERM';
  p_master_tab(l_master_idx)(l_event_idx).stage_code := 'HIRE_STG';
  p_master_tab(l_master_idx)(l_event_idx).event_ind  := l_ind_rec;
  p_dt_idx_tab(l_master_idx) := l_event_idx;

END add_emp_sprtn_event;


-- ----------------------------------------------------------------------------
-- Merges FKs into a single value for reporting
-- ----------------------------------------------------------------------------
FUNCTION get_merged_person_fk
      (p_vac_manager_irec   IN NUMBER,
       p_vac_recruiter   IN NUMBER,
       p_req_raised_by   IN NUMBER,
       p_vac_org_id      IN NUMBER,
       p_vac_bgr_id      IN NUMBER)
    RETURN NUMBER IS

  l_return_value   NUMBER;

BEGIN

  -- Default the return value
  l_return_value := -1;

  -- Check recruitment manager from iRecruitment
  IF p_vac_manager_irec <> -1 THEN

    l_return_value := p_vac_manager_irec;

  ELSE

    -- If that is not available, use PUI keys if profile enabled
    IF fnd_profile.value('HRI_REC_USE_PUI_MGR_KEYS') = 'Y' THEN

      IF p_vac_recruiter <> -1 THEN
        l_return_value := p_vac_recruiter;
      ELSE
        l_return_value := p_req_raised_by;
      END IF;

    END IF;

    -- If no value has been found then try cost centre managers for vacancy org
    IF l_return_value = -1 AND p_vac_org_id <> -1 THEN
      l_return_value := hri_bpl_ccmgr.get_ccmgr_id
                         (p_organization_id => p_vac_org_id);
    END IF;

    -- ... and vacancy business group as a last resort
    IF l_return_value = -1 THEN
      l_return_value := hri_bpl_ccmgr.get_ccmgr_id
                         (p_organization_id => p_vac_bgr_id);
    END IF;

  END IF;

  RETURN l_return_value;

END get_merged_person_fk;

-- ----------------------------------------------------------------------------
-- Merges FKs into a single value for reporting
-- ----------------------------------------------------------------------------
FUNCTION get_merged_org_fk
      (p_vac_org_id   IN NUMBER,
       p_vac_bgr_id   IN NUMBER)
    RETURN NUMBER IS

BEGIN

  IF p_vac_org_id IS NULL THEN
    RETURN p_vac_bgr_id;
  END IF;

  RETURN p_vac_org_id;

END get_merged_org_fk;

-- ----------------------------------------------------------------------------
-- Builds PL/SQL data structures up with applicant stage information
-- ----------------------------------------------------------------------------
PROCEDURE get_appl_stages
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  -- Get applicant events
  CURSOR appl_stage_csr IS
  SELECT
   asg.effective_start_date              time_day_evt_fk
  ,asg.effective_end_date                time_day_evt_end_fk
  ,asg.person_id                         person_cand_fk
  ,NVL(asg.supervisor_id, -1)            person_mngr_fk
  ,NVL(vac.recruiter_id, -1)             person_rcrt_fk
  ,NVL(vac.manager_id, -1)               person_rmgr_fk
  ,NVL(pra.authorising_person_id, -1)    person_auth_fk
  ,NVL(asg.person_referred_by_id, -1)    person_refr_fk
  ,NVL(prq.person_id, -1)                person_rsed_fk
  ,NVL(vac.organization_id, -1)          org_organztn_fk
  ,vac.business_group_id                 org_organztn_bgrp_fk
  ,NVL(pra.run_by_organization_id, -1)   org_organztn_recr_fk
  ,NVL(vac.location_id, -1)              geo_location_fk
  ,NVL(vac.job_id, -1)                   job_job_fk
  ,NVL(vac.grade_id, -1)                 grd_grade_fk
  ,NVL(vac.position_id, -1)              pos_position_fk
  ,NVL(vac.vacancy_id, -1)               rvac_vacncy_fk
  ,NVL(asg.recruitment_activity_id, -1)  ract_recactvy_fk
  ,NVL(ias.status_change_reason, NVL(asg.change_reason, 'NA_EDW'))
                                         rern_recevtrn_fk
  ,asg.application_id                    adt_application_id
  ,asg.business_group_id                 adt_business_group_id
  ,NVL(TRUNC(ias.status_change_date), asg.effective_start_date)
                                         event_date
  ,NVL(ast_irc.per_system_status, ast.per_system_status)
                                         stage_code
  ,NVL(ast_irc.user_status, ast.user_status)
                                         stage_name
  ,NVL(ast_irc.assignment_status_type_id, ast.assignment_status_type_id)
                                         assignment_status_type_id
  ,NVL(apl.termination_reason, 'NA_EDW') termination_reason
  FROM
   per_all_assignments_f        asg
  ,per_assignment_status_types  ast
  ,per_assignment_status_types  ast_irc
  ,per_all_vacancies            vac
  ,irc_assignment_statuses      ias
  ,per_applications             apl
  ,per_recruitment_activities   pra
  ,per_requisitions             prq
  WHERE asg.assignment_id = p_info_rec.asg_id
  AND apl.application_id = asg.application_id
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ias.assignment_status_type_id = ast_irc.assignment_status_type_id (+)
  AND asg.assignment_type = 'A'
  AND asg.recruitment_activity_id = pra.recruitment_activity_id (+)
  AND asg.vacancy_id = vac.vacancy_id (+)
  AND vac.requisition_id = prq.requisition_id (+)
  AND asg.assignment_id = ias.assignment_id (+)
  AND ias.status_change_date (+) BETWEEN asg.effective_start_date
                                 AND asg.effective_end_date
  AND vac.date_from (+) >= g_dbi_start_date
  AND apl.date_received >= g_dbi_start_date
  AND ast_irc.per_system_status (+) <> 'TERM_APL'
  ORDER BY asg.effective_start_date;

  -- Get person type of applicant on application date
  CURSOR appl_ptyp_csr(v_person_id       IN NUMBER,
                       v_effective_date  IN DATE) IS
  SELECT
   ppt.system_person_type
  FROM
   per_person_type_usages_f  ptu
  ,per_person_types          ppt
  WHERE ptu.person_id = v_person_id
  AND v_effective_date BETWEEN ptu.effective_start_date
                       AND ptu.effective_end_date
  AND ptu.person_type_id = ppt.person_type_id
  AND ppt.system_person_type IN ('EMP','CWK');

  l_time_day_evt_fk            g_date_tab_type;
  l_time_day_evt_end_fk        g_date_tab_type;
  l_person_cand_fk             g_number_tab_type;
  l_person_mngr_fk             g_number_tab_type;
  l_person_rcrt_fk             g_number_tab_type;
  l_person_rmgr_fk             g_number_tab_type;
  l_person_auth_fk             g_number_tab_type;
  l_person_refr_fk             g_number_tab_type;
  l_person_rsed_fk             g_number_tab_type;
  l_org_organztn_fk            g_number_tab_type;
  l_org_organztn_bgrp_fk       g_number_tab_type;
  l_org_organztn_recr_fk       g_number_tab_type;
  l_geo_location_fk            g_number_tab_type;
  l_job_job_fk                 g_number_tab_type;
  l_grd_grade_fk               g_number_tab_type;
  l_pos_position_fk            g_number_tab_type;
  l_rvac_vacncy_fk            g_number_tab_type;
  l_ract_recactvy_fk            g_number_tab_type;
  l_rern_recevtrn_fk            g_varchar2_tab_type;
  l_adt_application_id         g_number_tab_type;
  l_adt_business_group_id      g_number_tab_type;
  l_event_date                 g_date_tab_type;
  l_per_system_status          g_varchar2_tab_type;
  l_user_status                g_varchar2_tab_type;
  l_assignment_status_type_id  g_number_tab_type;
  l_term_rsn                   g_varchar2_tab_type;

BEGIN

  -- Bulk load cursor into PL/SQL tables
  OPEN appl_stage_csr;
  FETCH appl_stage_csr
    BULK COLLECT INTO
     l_time_day_evt_fk,
     l_time_day_evt_end_fk,
     l_person_cand_fk,
     l_person_mngr_fk,
     l_person_rcrt_fk,
     l_person_rmgr_fk,
     l_person_auth_fk,
     l_person_refr_fk,
     l_person_rsed_fk,
     l_org_organztn_fk,
     l_org_organztn_bgrp_fk,
     l_org_organztn_recr_fk,
     l_geo_location_fk,
     l_job_job_fk,
     l_grd_grade_fk,
     l_pos_position_fk,
     l_rvac_vacncy_fk,
     l_ract_recactvy_fk,
     l_rern_recevtrn_fk,
     l_adt_application_id,
     l_adt_business_group_id,
     l_event_date,
     l_per_system_status,
     l_user_status,
     l_assignment_status_type_id,
     l_term_rsn;
  CLOSE appl_stage_csr;

  -- If data is returned, translate to table of records
  IF l_time_day_evt_fk.EXISTS(1) THEN

    -- If data is found record information and indicators
    p_info_rec.idx_strt_date := l_time_day_evt_fk(1);
    p_info_rec.last_apl_idx := l_time_day_evt_fk.LAST;
    p_info_rec.appl_term_rsn := l_term_rsn(1);
    p_ind_rec.appl_ind := 1;
    p_ind_rec.appl_new_ind := 1;

    -- Set applicant person type indicators
    FOR ptyp_rec IN appl_ptyp_csr(l_person_cand_fk(1), l_time_day_evt_fk(1)) LOOP
      IF ptyp_rec.system_person_type = 'EMP' THEN
        p_ind_rec.appl_emp_ind := 1;
        p_ind_rec.appl_new_ind := 0;
      ELSIF ptyp_rec.system_person_type = 'CWK' THEN
        p_ind_rec.appl_cwk_ind := 1;
        p_ind_rec.appl_new_ind := 0;
      END IF;
    END LOOP;

    -- Loop through fetched data and populate table of records
    FOR i IN 1..l_time_day_evt_fk.LAST LOOP

      -- Populate stage table
      p_apl_tab(i).time_day_evt_fk           := l_time_day_evt_fk(i);
      p_apl_tab(i).time_day_evt_end_fk       := l_time_day_evt_end_fk(i);
      p_apl_tab(i).person_cand_fk            := l_person_cand_fk(i);
      p_apl_tab(i).person_mngr_fk            := l_person_mngr_fk(i);
      p_apl_tab(i).person_rcrt_fk            := l_person_rcrt_fk(i);
      p_apl_tab(i).person_rmgr_fk            := l_person_rmgr_fk(i);
      p_apl_tab(i).person_auth_fk            := l_person_auth_fk(i);
      p_apl_tab(i).person_refr_fk            := l_person_refr_fk(i);
      p_apl_tab(i).person_rsed_fk            := l_person_rsed_fk(i);
      p_apl_tab(i).org_organztn_fk           := l_org_organztn_fk(i);
      p_apl_tab(i).org_organztn_recr_fk      := l_org_organztn_recr_fk(i);
      p_apl_tab(i).geo_location_fk           := l_geo_location_fk(i);
      p_apl_tab(i).job_job_fk                := l_job_job_fk(i);
      p_apl_tab(i).grd_grade_fk              := l_grd_grade_fk(i);
      p_apl_tab(i).pos_position_fk           := l_pos_position_fk(i);
      p_apl_tab(i).prfm_perfband_fk          := -5;
      p_apl_tab(i).rvac_vacncy_fk            := l_rvac_vacncy_fk(i);
      p_apl_tab(i).ract_recactvy_fk          := l_ract_recactvy_fk(i);
      p_apl_tab(i).rern_recevtrn_fk          := l_rern_recevtrn_fk(i);
      p_apl_tab(i).tarn_trmaplrn_fk          := l_term_rsn(i);
      p_apl_tab(i).adt_application_id        := l_adt_application_id(i);
      p_apl_tab(i).adt_business_group_id     := l_adt_business_group_id(i);
      p_apl_tab(i).event_date                := l_event_date(i);
      p_apl_tab(i).per_system_status         := l_per_system_status(i);
      p_apl_tab(i).user_status               := l_user_status(i);
      p_apl_tab(i).assignment_status_type_id := l_assignment_status_type_id(i);
      p_apl_tab(i).headcount
          := hri_bpl_abv.calc_abv
              (p_assignment_id     => p_info_rec.asg_id
              ,p_business_group_id => l_adt_business_group_id(i)
              ,p_budget_type       => 'HEAD'
              ,p_effective_date    => l_time_day_evt_fk(i));
      p_apl_tab(i).fte
          := hri_bpl_abv.calc_abv
              (p_assignment_id     => p_info_rec.asg_id
              ,p_business_group_id => l_adt_business_group_id(i)
              ,p_budget_type       => 'FTE'
              ,p_effective_date    => l_time_day_evt_fk(i));
      p_apl_tab(i).person_mrgd_fk
          := get_merged_person_fk
              (p_vac_manager_irec => l_person_rmgr_fk(i),
               p_vac_recruiter => l_person_rcrt_fk(i),
               p_req_raised_by => l_person_rsed_fk(i),
               p_vac_org_id    => l_org_organztn_fk(i),
               p_vac_bgr_id    => l_org_organztn_bgrp_fk(i));
      p_apl_tab(i).org_organztn_mrgd_fk
          := get_merged_org_fk
              (p_vac_org_id => l_org_organztn_fk(i),
               p_vac_bgr_id => l_org_organztn_bgrp_fk(i));

      -- Interpret recruitment event
      interpret_appl_event
       (p_master_tab    => p_master_tab,
        p_apl_tab       => p_apl_tab,
        p_apl_idx       => i,
        p_dt_idx_tab    => p_dt_idx_tab,
        p_info_rec      => p_info_rec,
        p_ind_rec       => p_ind_rec);

      -- Add stage start date
      p_apl_tab(i).stage_start_date := p_info_rec.curr_strt_date;

    END LOOP;

    -- Determine if application is ended
    IF (l_time_day_evt_end_fk(l_time_day_evt_fk.LAST) < g_end_of_time OR
        p_info_rec.latest_stage = 'APPL_TERM_STG') THEN
      p_info_rec.appl_ended_ind := 1;
      p_info_rec.appl_end_date := l_time_day_evt_end_fk(l_time_day_evt_fk.LAST);

      -- If application did not reach ACCEPTED stage then it failed
      IF (p_info_rec.latest_stage = 'OFFR_EXTD_STG' OR
          p_info_rec.latest_stage = 'ASMT_STG' OR
          p_info_rec.latest_stage = 'INIT_APPL_STG') THEN

        -- add rejection stage
        add_appl_fail_event
         (p_master_tab => p_master_tab,
          p_apl_tab    => p_apl_tab,
          p_dt_idx_tab => p_dt_idx_tab,
          p_info_rec   => p_info_rec,
          p_ind_rec    => p_ind_rec);

      END IF;
    ELSE
      p_info_rec.appl_ended_ind := 0;
    END IF;

  ELSE

    -- No applicant data found - assignment is a hire that bypassed the
    -- recruitment process
    p_ind_rec.appl_ind := 0;

  END IF;

END get_appl_stages;


-- ----------------------------------------------------------------------------
-- Builds PL/SQL data structures up with employment stage information
-- ----------------------------------------------------------------------------
PROCEDURE get_empl_stages
    (p_master_tab  IN OUT NOCOPY g_master_tab_type,
     p_apl_tab     IN OUT NOCOPY g_apl_tab_type,
     p_dt_idx_tab  IN OUT NOCOPY g_number_tab_type,
     p_info_rec    IN OUT NOCOPY g_info_rec_type,
     p_ind_rec     IN OUT NOCOPY g_ind_rec_type) IS

  CURSOR emp_appl_details_csr IS
  SELECT
   pos.date_start
  ,pos.actual_termination_date
  ,emp.assignment_id
  ,emp.effective_start_date
  ,emp.effective_end_date
  ,emp.person_id
  ,NVL(emp.supervisor_id, -1)
  ,emp.organization_id
  ,NVL(emp.location_id, -1)
  ,NVL(emp.job_id, -1)
  ,NVL(emp.grade_id, -1)
  ,NVL(emp.position_id, -1)
  ,emp.business_group_id
  FROM
   per_all_assignments_f   emp
  ,per_periods_of_service  pos
  WHERE emp.person_id = p_info_rec.psn_id
  AND emp.assignment_type = 'E'
  AND p_info_rec.appl_end_date + 1 BETWEEN emp.effective_start_date
                                   AND emp.effective_end_date
  AND (emp.assignment_id = p_info_rec.asg_id OR
         (emp.primary_flag = 'Y' and
          emp.effective_start_date = p_info_rec.appl_end_date + 1))
  AND emp.period_of_service_id = pos.period_of_service_id;

  CURSOR emp_details_csr IS
  SELECT
   pos.date_start
  ,pos.actual_termination_date
  ,emp.assignment_id
  ,emp.effective_start_date
  ,emp.effective_end_date
  ,emp.person_id
  ,NVL(emp.supervisor_id, -1)
  ,emp.organization_id
  ,NVL(emp.location_id, -1)
  ,NVL(emp.job_id, -1)
  ,NVL(emp.grade_id, -1)
  ,NVL(emp.position_id, -1)
  ,emp.business_group_id
  FROM
   per_all_assignments_f   emp
  ,per_periods_of_service  pos
  WHERE  emp.assignment_id = p_info_rec.asg_id
  AND emp.effective_start_date = pos.date_start
  AND emp.period_of_service_id = pos.period_of_service_id
  AND emp.effective_start_date >= g_dbi_start_date;

  CURSOR perf_details_csr(v_asg_id     IN NUMBER,
                          v_hire_date  IN DATE) IS
  SELECT
   effective_change_date
  ,perf_nrmlsd_rating
  ,perf_band
  FROM hri_mb_asgn_events_ct  evt
  WHERE assignment_id = v_asg_id
  AND effective_change_date BETWEEN v_hire_date
                            AND add_months(v_hire_date, 24)
  AND perf_rating_change_ind = 1;

  l_hire_date        DATE;
  l_term_date        DATE;
  l_apl_idx          NUMBER;
  l_asg_id           NUMBER;
  l_pow2_start_date  DATE;
  l_perf_event_date  DATE;
  l_perf_rating      NUMBER;
  l_perf_band        NUMBER;

BEGIN

  -- If testing for applicant success use emp_appl cursor
  IF p_ind_rec.appl_ind = 1 THEN

    l_apl_idx := p_info_rec.last_apl_idx + 1;

    OPEN emp_appl_details_csr;
    FETCH emp_appl_details_csr INTO
      l_hire_date,
      l_term_date,
      l_asg_id,
      p_apl_tab(l_apl_idx).time_day_evt_fk,
      p_apl_tab(l_apl_idx).time_day_evt_end_fk,
      p_apl_tab(l_apl_idx).person_cand_fk,
      p_apl_tab(l_apl_idx).person_mngr_fk,
      p_apl_tab(l_apl_idx).org_organztn_fk,
      p_apl_tab(l_apl_idx).geo_location_fk,
      p_apl_tab(l_apl_idx).job_job_fk,
      p_apl_tab(l_apl_idx).grd_grade_fk,
      p_apl_tab(l_apl_idx).pos_position_fk,
      p_apl_tab(l_apl_idx).adt_business_group_id;
    CLOSE emp_appl_details_csr;

    -- If no hire date was found, then application was unsuccessful
    IF l_hire_date IS NULL THEN

      -- add rejection stage
      add_appl_fail_event
       (p_master_tab => p_master_tab,
        p_apl_tab    => p_apl_tab,
        p_dt_idx_tab => p_dt_idx_tab,
        p_info_rec   => p_info_rec,
        p_ind_rec    => p_ind_rec);

    ELSE

      -- Default application details
      p_apl_tab(l_apl_idx).person_rcrt_fk            := p_apl_tab(l_apl_idx-1).person_rcrt_fk;
      p_apl_tab(l_apl_idx).person_rmgr_fk            := p_apl_tab(l_apl_idx-1).person_rmgr_fk;
      p_apl_tab(l_apl_idx).person_auth_fk            := p_apl_tab(l_apl_idx-1).person_auth_fk;
      p_apl_tab(l_apl_idx).person_refr_fk            := p_apl_tab(l_apl_idx-1).person_refr_fk;
      p_apl_tab(l_apl_idx).person_rsed_fk            := p_apl_tab(l_apl_idx-1).person_rsed_fk;
      p_apl_tab(l_apl_idx).person_mrgd_fk            := p_apl_tab(l_apl_idx-1).person_mrgd_fk;
      p_apl_tab(l_apl_idx).org_organztn_mrgd_fk      := p_apl_tab(l_apl_idx-1).org_organztn_mrgd_fk;
      p_apl_tab(l_apl_idx).org_organztn_recr_fk      := p_apl_tab(l_apl_idx-1).org_organztn_recr_fk;
      p_apl_tab(l_apl_idx).prfm_perfband_fk          := p_apl_tab(l_apl_idx-1).prfm_perfband_fk;
      p_apl_tab(l_apl_idx).rvac_vacncy_fk           := p_apl_tab(l_apl_idx-1).rvac_vacncy_fk;
      p_apl_tab(l_apl_idx).ract_recactvy_fk           := p_apl_tab(l_apl_idx-1).ract_recactvy_fk;
      p_apl_tab(l_apl_idx).rern_recevtrn_fk           := 'NA_EDW';
      p_apl_tab(l_apl_idx).tarn_trmaplrn_fk           := 'NA_EDW';
      p_apl_tab(l_apl_idx).adt_application_id        := p_apl_tab(l_apl_idx-1).adt_application_id;
      p_apl_tab(l_apl_idx).per_system_status         := null;
      p_apl_tab(l_apl_idx).user_status               := null;
      p_apl_tab(l_apl_idx).assignment_status_type_id := to_number(null);
      p_info_rec.last_apl_idx := l_apl_idx;

    END IF;

  -- Otherwise use emp cursor
  ELSE

    l_apl_idx := 1;

    OPEN emp_details_csr;
    FETCH emp_details_csr INTO
      l_hire_date,
      l_term_date,
      l_asg_id,
      p_apl_tab(l_apl_idx).time_day_evt_fk,
      p_apl_tab(l_apl_idx).time_day_evt_end_fk,
      p_apl_tab(l_apl_idx).person_cand_fk,
      p_apl_tab(l_apl_idx).person_mngr_fk,
      p_apl_tab(l_apl_idx).org_organztn_fk,
      p_apl_tab(l_apl_idx).geo_location_fk,
      p_apl_tab(l_apl_idx).job_job_fk,
      p_apl_tab(l_apl_idx).grd_grade_fk,
      p_apl_tab(l_apl_idx).pos_position_fk,
      p_apl_tab(l_apl_idx).adt_business_group_id;
    CLOSE emp_details_csr;

    -- Default application details
    p_apl_tab(l_apl_idx).person_rcrt_fk            := -1;
    p_apl_tab(l_apl_idx).person_rmgr_fk            := -1;
    p_apl_tab(l_apl_idx).person_auth_fk            := -1;
    p_apl_tab(l_apl_idx).person_refr_fk            := -1;
    p_apl_tab(l_apl_idx).person_rsed_fk            := -1;
    p_apl_tab(l_apl_idx).person_mrgd_fk            := p_apl_tab(l_apl_idx).person_mngr_fk;
    p_apl_tab(l_apl_idx).org_organztn_mrgd_fk      := p_apl_tab(l_apl_idx).org_organztn_fk;
    p_apl_tab(l_apl_idx).org_organztn_recr_fk      := -1;
    p_apl_tab(l_apl_idx).prfm_perfband_fk          := -5;
    p_apl_tab(l_apl_idx).rvac_vacncy_fk           := -1;
    p_apl_tab(l_apl_idx).ract_recactvy_fk           := -1;
    p_apl_tab(l_apl_idx).rern_recevtrn_fk           := 'NA_EDW';
    p_apl_tab(l_apl_idx).tarn_trmaplrn_fk           := 'NA_EDW';
    p_apl_tab(l_apl_idx).adt_application_id        := to_number(null);
    p_apl_tab(l_apl_idx).per_system_status         := null;
    p_apl_tab(l_apl_idx).user_status               := null;
    p_apl_tab(l_apl_idx).assignment_status_type_id := to_number(null);
    p_info_rec.last_apl_idx := l_apl_idx;

  END IF;

  -- If employment data is found, add a record to the applicant details table
  IF l_hire_date IS NOT NULL THEN

    -- Add in derived values
    p_apl_tab(l_apl_idx).event_date := p_apl_tab(l_apl_idx).time_day_evt_fk;
    p_apl_tab(l_apl_idx).stage_start_date := p_apl_tab(l_apl_idx).time_day_evt_fk;
    p_apl_tab(l_apl_idx).headcount
          := hri_bpl_abv.calc_abv
              (p_assignment_id     => l_asg_id
              ,p_business_group_id => p_apl_tab(l_apl_idx).adt_business_group_id
              ,p_budget_type       => 'HEAD'
              ,p_effective_date    => p_apl_tab(l_apl_idx).time_day_evt_fk);
    p_apl_tab(l_apl_idx).fte
          := hri_bpl_abv.calc_abv
              (p_assignment_id     => l_asg_id
              ,p_business_group_id => p_apl_tab(l_apl_idx).adt_business_group_id
              ,p_budget_type       => 'FTE'
              ,p_effective_date    => p_apl_tab(l_apl_idx).time_day_evt_fk);

    -- add hire stage
    add_hire_event
     (p_master_tab => p_master_tab,
      p_apl_tab    => p_apl_tab,
      p_dt_idx_tab => p_dt_idx_tab,
      p_info_rec   => p_info_rec,
      p_ind_rec    => p_ind_rec);

    -- Set POW2 start date
    IF g_pow1_no_days IS NOT NULL THEN
      l_pow2_start_date := l_hire_date + g_pow1_no_days;
    ELSE
      l_pow2_start_date := ADD_MONTHS(l_hire_date, g_pow1_no_months);
    END IF;

    -- Check if first period of work band is passed
    IF ((l_term_date IS NULL AND
         TRUNC(g_sysdate) >= l_pow2_start_date) OR
        l_term_date >= l_pow2_start_date) THEN

      -- Log event date
      p_info_rec.pow1_date := l_pow2_start_date;

      -- add pow1 event
      add_pow1_event
       (p_master_tab => p_master_tab,
        p_apl_tab    => p_apl_tab,
        p_dt_idx_tab => p_dt_idx_tab,
        p_info_rec   => p_info_rec,
        p_ind_rec    => p_ind_rec);

    ELSIF l_term_date IS NOT NULL THEN

      -- Log event date
      p_info_rec.emp_sprtn_date := l_term_date;

      -- add employee separation before reaching pow1
      add_emp_sprtn_event
       (p_master_tab => p_master_tab,
        p_apl_tab    => p_apl_tab,
        p_dt_idx_tab => p_dt_idx_tab,
        p_info_rec   => p_info_rec,
        p_ind_rec    => p_ind_rec);

    END IF;

    -- Check if performance review has occurred since hire
    OPEN perf_details_csr(l_asg_id, l_hire_date);
    FETCH perf_details_csr INTO l_perf_event_date, l_perf_rating, l_perf_band;
    CLOSE perf_details_csr;

    -- If so add perf event
    IF l_perf_band IS NOT NULL THEN

      -- Log event info
      p_info_rec.perf_date := l_perf_event_date;
      p_info_rec.perf_band := l_perf_band;
      p_info_rec.perf_norm_rtng := l_perf_rating;

      -- add pow1 event
      add_perf_event
       (p_master_tab => p_master_tab,
        p_apl_tab    => p_apl_tab,
        p_dt_idx_tab => p_dt_idx_tab,
        p_info_rec   => p_info_rec,
        p_ind_rec    => p_ind_rec);

    END IF;

    -- If separation is required add that event...
    -- IF l_term_date IS NOT NULL THEN
    --   add_sepn_event
    --   (p_master_tab => p_master_tab,
    --    p_apl_tab    => p_apl_tab,
    --    p_dt_idx_tab => p_dt_idx_tab,
    --    p_info_rec   => p_info_rec,
    --    p_ind_rec    => p_ind_rec);
    -- END IF;

  END IF;

-- get appraisal

END get_empl_stages;


-- ----------------------------------------------------------------------------
-- Processes a single assignment
-- ----------------------------------------------------------------------------
PROCEDURE process_assignment(p_asg_id    IN NUMBER,
                             p_psn_id    IN NUMBER) IS

  l_apl_tab      g_apl_tab_type;
  l_master_tab   g_master_tab_type;
  l_dt_idx_tab   g_number_tab_type;
  l_info_rec     g_info_rec_type;
  l_ind_rec      g_ind_rec_type;

BEGIN

  -- dbg('In process_assignment for:  ' || to_char(p_asg_id));

  -- Initialize data structures
  reset_event_cache;
  l_ind_rec := initialize_indicator_rec;
  l_info_rec.asg_id := p_asg_id;
  l_info_rec.psn_id := p_psn_id;
  l_info_rec.event_seq := 0;
  l_info_rec.perf_band := -5;

  -- Load Recruitment Stages
  get_appl_stages
   (p_master_tab => l_master_tab,
    p_apl_tab    => l_apl_tab,
    p_dt_idx_tab => l_dt_idx_tab,
    p_ind_rec    => l_ind_rec,
    p_info_rec   => l_info_rec);

  -- Don't load employment stages if application is still open
  -- or if application failed
  IF (l_info_rec.appl_ended_ind = 0 OR
      l_info_rec.appl_term_date IS NOT NULL) THEN

    -- Skip
    null;

  ELSE

    -- Load Employment Stages
    get_empl_stages
     (p_master_tab => l_master_tab,
      p_apl_tab    => l_apl_tab,
      p_dt_idx_tab => l_dt_idx_tab,
      p_ind_rec    => l_ind_rec,
      p_info_rec   => l_info_rec);

  END IF;

  -- Load data into PL/SQL tables ready for bulk insert
  merge_and_insert_data
   (p_master_tab => l_master_tab,
    p_apl_tab    => l_apl_tab,
    p_dt_idx_tab => l_dt_idx_tab,
    p_info_rec   => l_info_rec,
    p_ind_rec    => l_ind_rec);

END process_assignment;

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

  CURSOR full_asg_csr IS
  SELECT DISTINCT
   assignment_id
  ,person_id
  FROM per_all_assignments_f
  WHERE assignment_type IN ('E','A')
  AND effective_end_date >= g_dbi_start_date
  AND assignment_id BETWEEN p_start_object_id AND p_end_object_id;

BEGIN

  -- Initialize global data structure
  g_no_rows := 0;

  -- Set the parameters
  set_parameters
   (p_mthd_action_id  => p_mthd_action_id,
    p_mthd_stage_code => 'PROCESS_RANGE');

  -- Set sysdate parameter
  g_sysdate := sysdate;

  -- Process range in corresponding refresh mode
  IF g_full_refresh = 'Y' THEN

    FOR asg_rec IN full_asg_csr LOOP

      process_assignment
       (p_asg_id => asg_rec.assignment_id,
        p_psn_id => asg_rec.person_id);

    END LOOP;

  END IF;

  -- Insert any stored rows
  bulk_insert_rows;

END process_range;


-- ----------------------------------------------------------------------------
-- Adds default records for vacancies
-- ----------------------------------------------------------------------------
PROCEDURE process_vacancies IS

BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  INSERT /*+ APPEND */ INTO hri_mb_rec_cand_pipln_ct
   (time_day_evt_fk,
    time_day_evt_end_fk,
    time_day_stg_evt_eff_end_fk,
    per_person_cand_fk,
    per_person_mngr_fk,
    per_person_rcrt_fk,
    per_person_rmgr_fk,
    per_person_auth_fk,
    per_person_refr_fk,
    per_person_rsed_fk,
    per_person_mrgd_fk,
    org_organztn_fk,
    org_organztn_mrgd_fk,
    org_organztn_recr_fk,
    geo_location_fk,
    job_job_fk,
    grd_grade_fk,
    pos_position_fk,
    prfm_perfband_fk,
    rvac_vacncy_fk,
    ract_recactvy_fk,
    rev_recevent_fk,
    rern_recevtrn_fk,
    tarn_trmaplrn_fk,
    event_seq,
    appl_ind,
    appl_new_ind,
    appl_emp_ind,
    appl_cwk_ind,
    appl_strt_evnt_ind,
    appl_strt_nevnt_ind,
    asmt_strt_evnt_ind,
    asmt_strt_nevnt_ind,
    asmt_end_evnt_ind,
    asmt_end_nevnt_ind,
    offr_extd_evnt_ind,
    offr_extd_nevnt_ind,
    offr_rjct_evnt_ind,
    offr_rjct_nevnt_ind,
    offr_acpt_evnt_ind,
    offr_acpt_nevnt_ind,
    appl_term_evnt_ind,
    appl_term_nevnt_ind,
    appl_term_vol_evnt_ind,
    appl_term_vol_nevnt_ind,
    appl_term_invol_evnt_ind,
    appl_term_invol_nevnt_ind,
    appl_hire_evnt_ind,
    appl_hire_nevnt_ind,
    hire_evnt_ind,
    hire_nevnt_ind,
    post_hire_pow1_end_evnt_ind,
    post_hire_pow1_end_nevnt_ind,
    post_hire_perf_evnt_ind,
    post_hire_perf_nevnt_ind,
    emp_sprtn_evnt_ind,
    emp_sprtn_nevnt_ind,
    hire_org_chng_ind,
    hire_job_chng_ind,
    hire_pos_chng_ind,
    hire_grd_chng_ind,
    hire_loc_chng_ind,
    current_record_ind,
    current_stage_strt_ind,
    init_appl_stg_ind,
    asmt_stg_ind,
    offr_extd_stg_ind,
    strt_pndg_stg_ind,
    hire_stg_ind,
    gen_record_ind,
    adt_assignment_id,
    adt_application_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date)
   SELECT
    date_from
   ,NVL(date_to, g_end_of_time)
   ,to_date(null)
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,-1
   ,NVL(recruiter_id, -1)
   ,NVL(manager_id, -1)
   ,NVL(organization_id, -1)
   ,-1
   ,business_group_id
   ,NVL(location_id, -1)
   ,NVL(job_id, -1)
   ,NVL(grade_id, -1)
   ,NVL(position_id, -1)
   ,-5
   ,vacancy_id
   ,-1
   ,'VAC_OPEN'
   ,'NA_EDW'
   ,'NA_EDW'
   ,-1
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,0
   ,1
   ,-1
   ,-1
   ,g_sysdate
   ,g_user
   ,g_user
   ,g_user
   ,g_sysdate
   FROM per_all_vacancies
   WHERE date_from >= g_dbi_start_date;

  -- Commit
  COMMIT;

END process_vacancies;


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

  -- ********************
  -- Full Refresh Section
  -- ********************
  IF (g_full_refresh = 'Y' OR
      g_mthd_action_array.foundation_hr_flag = 'Y') THEN

    -- Empty out absence dimension table
    l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_MB_REC_CAND_PIPLN_CT';
    EXECUTE IMMEDIATE(l_sql_stmt);

    -- In shared HR mode do not return a SQL statement so that the
    -- process_range and post_process will not be executed
    IF (g_mthd_action_array.foundation_hr_flag = 'Y') THEN

      -- Call post processing API
      post_process
       (p_mthd_action_id => p_mthd_action_id);

    ELSE

      -- Disable WHO trigger
      run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_REC_CAND_PIPLN_CT_WHO DISABLE');

      -- Drop all the indexes on the table
      hri_utl_ddl.log_and_drop_indexes
       (p_application_short_name => 'HRI',
        p_table_name             => 'HRI_MB_REC_CAND_PIPLN_CT',
        p_table_owner            => l_schema);

      -- Set the SQL statement for the entire range
      p_sqlstr :=
       'SELECT DISTINCT
         asg.assignment_id object_id
        FROM
          per_all_assignments_f  asg
        WHERE asg.assignment_type IN (''E'',''A'')
        AND asg.effective_end_date >=
                             hri_bpl_parameter.get_bis_global_start_date
        ORDER BY 1';

    END IF;

  ELSE

    -- Set the SQL statement for the incremental range
      p_sqlstr :=
       'SELECT DISTINCT
         assignment_id object_id
        FROM per_all_assignments_f
        WHERE 1 = 0
        ORDER BY 1';

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
    hri_bpl_conc_log.record_process_start('HRI_MB_REC_CAND_PIPLN_CT');
    hri_bpl_conc_log.log_process_end(
       p_status         => TRUE
      ,p_period_from    => TRUNC(g_refresh_start_date)
      ,p_period_to      => TRUNC(SYSDATE)
      ,p_attribute1     => g_full_refresh);

  END IF;

  -- Get HRI schema name - get_app_info populates l_schema
  IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
    null;
  END IF;

  -- Recreate indexes in full refresh mode
  IF (g_full_refresh = 'Y') THEN

    -- Add in vacancy records
    process_vacancies;

    -- Enable WHO trigger
    run_sql_stmt_noerr('ALTER TRIGGER HRI_MB_REC_CAND_PIPLN_CT_WHO ENABLE');

    hri_utl_ddl.recreate_indexes
     (p_application_short_name => 'HRI',
      p_table_name             => 'HRI_MB_REC_CAND_PIPLN_CT',
      p_table_owner            => l_schema);

  END IF;

  -- Empty out workforce manager summary event queue
  -- l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_EQ_WRKFC_EVT_MGRH';
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
      FROM per_all_assignments_f
      WHERE assignment_type IN ('E','A')
      AND effective_end_date >= g_dbi_start_date
      ORDER BY assignment_id
     )  tab
   )  chunks
  GROUP BY
   chunk_no;

  l_dummy                 VARCHAR2(2000);
  l_errbuf                VARCHAR2(1000);
  l_retcode               VARCHAR2(1000);

BEGIN

  g_full_refresh := p_full_refresh_flag;
  g_refresh_to_date := trunc(sysdate);
  g_sysdate := trunc(sysdate);
  g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;
  g_debug := FALSE;

  pre_process(-1, l_dummy);

  FOR chunk_rec IN chunk_csr LOOP

    process_range
     (l_errbuf, l_retcode, -1, -1, chunk_rec.start_asg_id, chunk_rec.end_asg_id);

  END LOOP;

  post_process(-1);

END single_thread_process;

PROCEDURE process_assignment(p_asg_id  IN NUMBER) IS

  l_psn_id     NUMBER;
  l_dummy      VARCHAR2(2000);

BEGIN

  g_full_refresh := 'Y';
  g_refresh_to_date := trunc(sysdate);
  g_sysdate := trunc(sysdate);
  g_dbi_start_date := hri_bpl_parameter.get_bis_global_start_date;
  g_no_rows := 0;
  g_debug := TRUE;

  SELECT DISTINCT person_id INTO l_psn_id
  FROM per_all_assignments_f
  WHERE assignment_id = p_asg_id;

  DELETE FROM hri_mb_rec_cand_pipln_ct
  WHERE adt_assignment_id = p_asg_id;

  process_assignment(p_asg_id, l_psn_id);

  bulk_insert_rows;

END process_assignment;

END hri_opl_rec_cand_pipln;

/
