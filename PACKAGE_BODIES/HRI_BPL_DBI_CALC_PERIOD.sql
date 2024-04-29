--------------------------------------------------------
--  DDL for Package Body HRI_BPL_DBI_CALC_PERIOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_DBI_CALC_PERIOD" AS
/* $Header: hribdcrp.pkb 120.7 2005/11/10 01:53:49 jrstewar noship $ */

g_rtn  VARCHAR2(5) := '
';
/* Total Absence events for a supervisor in a period  */
/******************************************************/
PROCEDURE calc_sup_absence(p_supervisor_id         IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_abs_drtn_days     OUT NOCOPY NUMBER,
                            p_total_abs_drtn_hrs      OUT NOCOPY NUMBER,
                            p_total_abs_in_period     OUT NOCOPY NUMBER,
                            p_total_abs_ntfctn_period OUT NOCOPY NUMBER) IS

  CURSOR calc_totals_for_sup(v_direct_record_ind IN NUMBER) IS
    SELECT
         SUM(CASE WHEN a.effective_date BETWEEN p_from_date AND p_to_date
                 THEN a.abs_drtn_days
                 ELSE 0
             END)  abs_drtn_days
        ,SUM(CASE WHEN a.effective_date BETWEEN p_from_date AND p_to_date
                 THEN abs_drtn_hrs
                 ELSE 0
             END)  abs_drtn_hrs
        ,SUM(CASE WHEN a.effective_date = p_from_date
                 THEN a.abs_start_blnc + a.abs_nstart_blnc
                  WHEN a.effective_date > p_from_date
                    AND a.effective_date <= p_to_date
                 THEN abs_start_blnc
                 ELSE 0
             END)  abs_in_period
        ,SUM(CASE WHEN a.effective_date = p_from_date
                THEN a.abs_ntfctn_days_start_blnc + a.abs_ntfctn_days_nstart_blnc
                  WHEN a.effective_date > p_from_date
                    AND a.effective_date <= p_to_date
                THEN abs_ntfctn_days_start_blnc
                ELSE 0
             END)  abs_ntfctn_period
  FROM HRI_MDP_SUP_ABSNC_SUP_MV a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date BETWEEN  p_from_date AND p_to_date;


  l_direct_record_ind     NUMBER;
  l_use_snapshot          BOOLEAN;

BEGIN


/* Set record type indicator */
  IF p_total_type = 'ROLLUP' THEN
    l_direct_record_ind := 0;
  ELSE
    l_direct_record_ind := 1;
  END IF;

/* Get WMV Change totals for supervisor from cursor */
  OPEN calc_totals_for_sup(l_direct_record_ind);
  FETCH calc_totals_for_sup INTO p_total_abs_drtn_days,
                                 p_total_abs_drtn_hrs,
                                 p_total_abs_in_period,
                                 p_total_abs_ntfctn_period;
  CLOSE calc_totals_for_sup;


END calc_sup_absence;


/* Total workforce change events for a supervisor in a period */
/**************************************************************/
PROCEDURE calc_sup_wcnt_chg(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_total_gain_hire      OUT NOCOPY NUMBER,
                            p_total_gain_transfer  OUT NOCOPY NUMBER,
                            p_total_loss_term      OUT NOCOPY NUMBER,
                            p_total_loss_transfer  OUT NOCOPY NUMBER) IS

  CURSOR calc_totals_for_sup(v_direct_record_ind IN NUMBER) IS
  SELECT
   NVL(SUM(a.hire_hdc),0)          tot_gain_hire
  ,NVL(SUM(a.transfer_in_hdc),0)   tot_gain_transfer
  ,NVL(SUM(a.termination_hdc),0)   tot_loss_term
  ,NVL(SUM(a.transfer_out_hdc),0)  tot_loss_transfer
  FROM hri_mdp_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date BETWEEN p_from_date
                       AND p_to_date;

  CURSOR calc_totals_for_sup_snp(v_direct_record_ind IN NUMBER) IS
  SELECT /*+ INDEX(a) */
   NVL(SUM(a.hire_hdc),0)          tot_gain_hire
  ,NVL(SUM(a.transfer_in_hdc),0)   tot_gain_transfer
  ,NVL(SUM(a.termination_hdc),0)   tot_loss_term
  ,NVL(SUM(a.transfer_out_hdc),0)  tot_loss_transfer
  FROM hri_mds_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date = p_to_date
  AND a.period_type = p_period_type
  AND a.comparison_type IN (p_comparison_type, 'CURRENT');

  l_direct_record_ind     NUMBER;
  l_use_snapshot          BOOLEAN;

BEGIN

/* Check whether a snapshot can be used */
/* Note a snapshot may be used to get the total even if the portlet query */
/* is not able to use snapshots */
  l_use_snapshot := hri_oltp_pmv_util_snpsht.use_wcnt_chg_snpsht_for_mgr
                     (p_supervisor_id => p_supervisor_id,
                      p_effective_date => p_to_date);

/* Set record type indicator */
  IF p_total_type = 'ROLLUP' THEN
    l_direct_record_ind := 0;
  ELSE
    l_direct_record_ind := 1;
  END IF;

/* Open the cursor corresponding to the snapshot flag */
  IF l_use_snapshot THEN

  /* Get WMV Change totals for supervisor from snapshot cursor */
    OPEN calc_totals_for_sup_snp(l_direct_record_ind);
    FETCH calc_totals_for_sup_snp INTO p_total_gain_hire,
                                       p_total_gain_transfer,
                                       p_total_loss_term,
                                       p_total_loss_transfer;
    CLOSE calc_totals_for_sup_snp;

  ELSE

  /* Get WMV Change totals for supervisor from cursor */
    OPEN calc_totals_for_sup(l_direct_record_ind);
    FETCH calc_totals_for_sup INTO p_total_gain_hire,
                                   p_total_gain_transfer,
                                   p_total_loss_term,
                                   p_total_loss_transfer;
    CLOSE calc_totals_for_sup;

  END IF;

END calc_sup_wcnt_chg;

/* Total Employee Or Contingent change events for a supervisor in a period */
/***************************************************************************/
PROCEDURE calc_sup_wcnt_chg(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_gain_hire      OUT NOCOPY NUMBER,
                            p_total_gain_transfer  OUT NOCOPY NUMBER,
                            p_total_loss_term      OUT NOCOPY NUMBER,
                            p_total_loss_transfer  OUT NOCOPY NUMBER) IS

  CURSOR calc_totals_for_sup(v_direct_record_ind IN NUMBER) IS
  SELECT
   NVL(SUM(a.hire_hdc),0)          tot_gain_hire
  ,NVL(SUM(a.transfer_in_hdc),0)   tot_gain_transfer
  ,NVL(SUM(a.termination_hdc),0)   tot_loss_term
  ,NVL(SUM(a.transfer_out_hdc),0)  tot_loss_transfer
  FROM hri_mdp_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date BETWEEN p_from_date
                       AND p_to_date;

  CURSOR calc_totals_for_sup_snp(v_direct_record_ind IN NUMBER) IS
  SELECT /*+ INDEX(a) */
   NVL(SUM(a.hire_hdc),0)          tot_gain_hire
  ,NVL(SUM(a.transfer_in_hdc),0)   tot_gain_transfer
  ,NVL(SUM(a.termination_hdc),0)   tot_loss_term
  ,NVL(SUM(a.transfer_out_hdc),0)  tot_loss_transfer
  FROM hri_mds_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date = p_to_date
  AND a.period_type = p_period_type
  AND a.comparison_type IN (p_comparison_type, 'CURRENT');

  l_direct_record_ind     NUMBER;
  l_use_snapshot          BOOLEAN;

BEGIN

/* Check whether a snapshot can be used */
/* Note a snapshot may be used to get the total even if the portlet query */
/* is not able to use snapshots */
  l_use_snapshot := hri_oltp_pmv_util_snpsht.use_wcnt_chg_snpsht_for_mgr
                     (p_supervisor_id => p_supervisor_id,
                      p_effective_date => p_to_date);

/* Set record type indicator */
  IF p_total_type = 'ROLLUP' THEN
    l_direct_record_ind := 0;
  ELSE
    l_direct_record_ind := 1;
  END IF;

/* Open the cursor corresponding to the snapshot flag */
  IF l_use_snapshot THEN

  /* Get WMV Change totals for supervisor from snapshot cursor */
    OPEN calc_totals_for_sup_snp(l_direct_record_ind);
    FETCH calc_totals_for_sup_snp INTO p_total_gain_hire,
                                       p_total_gain_transfer,
                                       p_total_loss_term,
                                       p_total_loss_transfer;
    CLOSE calc_totals_for_sup_snp;

  ELSE

  /* Get WMV Change totals for supervisor from cursor */
    OPEN calc_totals_for_sup(l_direct_record_ind);
    FETCH calc_totals_for_sup INTO p_total_gain_hire,
                                   p_total_gain_transfer,
                                   p_total_loss_term,
                                   p_total_loss_transfer;
    CLOSE calc_totals_for_sup;

  END IF;

END calc_sup_wcnt_chg;

/* Total turnover events for a supervisor in a period */
/******************************************************/
PROCEDURE calc_sup_turnover(p_supervisor_id        IN NUMBER,
                            p_from_date            IN DATE,
                            p_to_date              IN DATE,
                            p_period_type          IN VARCHAR2,
                            p_comparison_type      IN VARCHAR2,
                            p_total_type           IN VARCHAR2,
                            p_wkth_wktyp_sk_fk     IN VARCHAR2,
                            p_total_trn_vol        OUT NOCOPY NUMBER,
                            p_total_trn_invol      OUT NOCOPY NUMBER) IS

  CURSOR calc_totals_for_sup(v_direct_record_ind IN NUMBER) IS
  SELECT
   NVL(SUM(a.sep_vol_hdc),0)     total_trn_vol
  ,NVL(SUM(a.sep_invol_hdc),0)   total_trn_invol
  FROM hri_mdp_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date BETWEEN p_from_date AND p_to_date
  AND a.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk;

  CURSOR calc_totals_for_sup_snp(v_direct_record_ind IN NUMBER) IS
  SELECT /*+ INDEX(a) */
   NVL(SUM(a.sep_vol_hdc),0)     total_trn_vol
  ,NVL(SUM(a.sep_invol_hdc),0)   total_trn_invol
  FROM hri_mds_sup_wcnt_chg_mv a
  WHERE a.supervisor_person_id = p_supervisor_id
  AND a.direct_record_ind = v_direct_record_ind
  AND a.effective_date = p_to_date
  AND a.period_type = p_period_type
  AND a.comparison_type IN (p_comparison_type, 'CURRENT')
  AND a.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk;

  l_direct_record_ind     NUMBER;
  l_use_snapshot          BOOLEAN;

BEGIN

/* Check whether a snapshot can be used */
/* Note a snapshot may be used to get the total even if the portlet query */
/* is not able to use snapshots */
  l_use_snapshot := hri_oltp_pmv_util_snpsht.use_wcnt_chg_snpsht_for_mgr
                     (p_supervisor_id => p_supervisor_id,
                      p_effective_date => p_to_date);

/* Set record type indicator */
  IF p_total_type = 'ROLLUP' THEN
    l_direct_record_ind := 0;
  ELSE
    l_direct_record_ind := 1;
  END IF;

/* Open the cursor corresponding to the snapshot flag */
  IF l_use_snapshot THEN

  /* Get WMV Change totals for supervisor from cursor */
    OPEN calc_totals_for_sup_snp(l_direct_record_ind);
    FETCH calc_totals_for_sup_snp INTO p_total_trn_vol,
                                       p_total_trn_invol;
    CLOSE calc_totals_for_sup_snp;

  ELSE

  /* Get WMV Change totals for supervisor from cursor */
    OPEN calc_totals_for_sup(l_direct_record_ind);
    FETCH calc_totals_for_sup INTO p_total_trn_vol,
                                   p_total_trn_invol;
    CLOSE calc_totals_for_sup;

  END IF;

END calc_sup_turnover;

/* Total terminations by supervisor and length of service */
/**********************************************************/
PROCEDURE calc_sup_term_low_pvt
    (p_supervisor_id  IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE,
     p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
     p_total_term     OUT NOCOPY NUMBER,
     p_total_term_b1  OUT NOCOPY NUMBER,
     p_total_term_b2  OUT NOCOPY NUMBER,
     p_total_term_b3  OUT NOCOPY NUMBER,
     p_total_term_b4  OUT NOCOPY NUMBER,
     p_total_term_b5  OUT NOCOPY NUMBER) IS

  TYPE term_csr_type IS REF CURSOR;

  term_cv          term_csr_type;
  l_sql_stmt       VARCHAR2(8000);
  l_where_clause   VARCHAR2(4000);
  l_parameter_name VARCHAR2(100);

BEGIN

  l_parameter_name := p_bind_tab.FIRST;

/* Loop through parameters that have been set */
  WHILE l_parameter_name IS NOT NULL LOOP

    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X' OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause || g_rtn ||
          'AND term.' ||
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                 (l_parameter_name).fact_viewby_col ||
          ' IN (' || p_bind_tab(l_parameter_name).sql_bind_string || ')';

    END IF;

    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;


  l_sql_stmt :=
'SELECT
   NVL(SUM(term.separation_hdc), 0) total_term
  ,NVL(SUM(CASE WHEN pow.pow_band = 1
                THEN term.separation_hdc
                ELSE 0
           END), 0)  total_term_pow_band1
  ,NVL(SUM(CASE WHEN pow.pow_band = 2
                THEN term.separation_hdc
                ELSE 0
           END), 0)  total_term_pow_band2
  ,NVL(SUM(CASE WHEN pow.pow_band = 3
                THEN term.separation_hdc
                ELSE 0
           END), 0)  total_term_pow_band3
  ,NVL(SUM(CASE WHEN pow.pow_band = 4
                THEN term.separation_hdc
                ELSE 0
           END), 0)  total_term_pow_band4
  ,NVL(SUM(CASE WHEN pow.pow_band = 5
                THEN term.separation_hdc
                ELSE 0
           END), 0)  total_term_pow_band5
FROM
 hri_mdp_sup_wcnt_term_asg_mv  term
,hri_dbi_cl_pow_all_band_v     pow
WHERE term.supervisor_person_id = :1
AND term.effective_date BETWEEN :2 AND :3
AND term.pow_band_sk_fk = pow.id'
  || l_where_clause;

  OPEN term_cv FOR l_sql_stmt
   USING
    p_supervisor_id,
    p_from_date,
    p_to_date;
  FETCH term_cv INTO
   p_total_term,
   p_total_term_b1,
   p_total_term_b2,
   p_total_term_b3,
   p_total_term_b4,
   p_total_term_b5;
  CLOSE term_cv;

EXCEPTION WHEN OTHERS THEN

  RETURN;

END calc_sup_term_low_pvt;

/* Total terminations by supervisor and performance band */
/*********************************************************/
PROCEDURE calc_sup_term_perf_pvt
    (p_supervisor_id  IN NUMBER,
     p_from_date      IN DATE,
     p_to_date        IN DATE,
     p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
     p_total_term     OUT NOCOPY NUMBER,
     p_total_term_b1  OUT NOCOPY NUMBER,
     p_total_term_b2  OUT NOCOPY NUMBER,
     p_total_term_b3  OUT NOCOPY NUMBER,
     p_total_term_na  OUT NOCOPY NUMBER) IS

  TYPE term_csr_type IS REF CURSOR;

  term_cv          term_csr_type;
  l_sql_stmt       VARCHAR2(8000);
  l_where_clause   VARCHAR2(4000);
  l_parameter_name VARCHAR2(100);

BEGIN

  l_parameter_name := p_bind_tab.FIRST;

/* Loop through parameters that have been set */
  WHILE l_parameter_name IS NOT NULL LOOP

    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X' OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause || g_rtn ||
          'AND term.' ||
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                 (l_parameter_name).fact_viewby_col ||
          ' IN (' || p_bind_tab(l_parameter_name).sql_bind_string || ')';

    END IF;

    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;

  l_sql_stmt :=
'SELECT
   NVL(SUM(separation_hdc), 0)
  ,NVL(SUM(CASE WHEN perf_band = 1
                THEN separation_hdc
                ELSE 0
           END), 0)  total_term_perf_band1
  ,NVL(SUM(CASE WHEN perf_band = 2
                THEN separation_hdc
                ELSE 0
           END), 0)  total_term_perf_band2
  ,NVL(SUM(CASE WHEN perf_band = 3
                THEN separation_hdc
                ELSE 0
           END), 0)  total_term_perf_band3
  ,NVL(SUM(CASE WHEN perf_band = -5
                THEN separation_hdc
                ELSE 0
           END), 0)  total_term_perf_bandna
FROM
 hri_mdp_sup_wcnt_term_asg_mv  term
WHERE term.supervisor_person_id = :1
AND term.effective_date BETWEEN :2 AND :3'
  || l_where_clause;

  OPEN term_cv FOR l_sql_stmt
   USING
    p_supervisor_id,
    p_from_date,
    p_to_date;
  FETCH term_cv INTO
   p_total_term,
   p_total_term_b1,
   p_total_term_b2,
   p_total_term_b3,
   p_total_term_na;
  CLOSE term_cv;

EXCEPTION WHEN OTHERS THEN

  RETURN;

END calc_sup_term_perf_pvt;

/* Total terminations by supervisor pivot */
/******************************************/
PROCEDURE calc_sup_term_pvt
      (p_supervisor_id     IN NUMBER,
       p_from_date         IN DATE,
       p_to_date           IN DATE,
       p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
       p_total_term_vol    OUT NOCOPY NUMBER,
       p_total_term_invol  OUT NOCOPY NUMBER,
       p_total_term        OUT NOCOPY NUMBER) IS

  TYPE term_csr_type IS REF CURSOR;

  term_cv          term_csr_type;
  l_sql_stmt       VARCHAR2(8000);
  l_where_clause   VARCHAR2(4000);
  l_parameter_name VARCHAR2(100);

BEGIN

  l_parameter_name := p_bind_tab.FIRST;

/* Loop through parameters that have been set */
  WHILE l_parameter_name IS NOT NULL LOOP

    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X' OR
        l_parameter_name = 'HRI_REASON+HRI_RSN_SEP_X'  OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause || g_rtn ||
          'AND term.' ||
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                 (l_parameter_name).fact_viewby_col ||
          ' IN (' || p_bind_tab(l_parameter_name).sql_bind_string || ')';

    END IF;

    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;

  l_sql_stmt :=
'SELECT
 NVL(SUM(CASE WHEN separation_category = ''SEP_INV''
              THEN term.separation_hdc
         ELSE 0
         END), 0)
,NVL(SUM(CASE WHEN separation_category = ''SEP_VOL''
              THEN term.separation_hdc
         ELSE 0
         END), 0)
,NVL(SUM(term.separation_hdc), 0)
FROM
 hri_mdp_sup_wcnt_term_asg_mv  term
WHERE term.supervisor_person_id = :1
AND term.effective_date BETWEEN :2 AND :3'
  || l_where_clause;

  OPEN term_cv FOR l_sql_stmt USING p_supervisor_id, p_from_date, p_to_date;
  FETCH term_cv INTO p_total_term_invol, p_total_term_vol, p_total_term;
  CLOSE term_cv;

EXCEPTION WHEN OTHERS THEN

  RETURN;

END calc_sup_term_pvt;

/******************************************************************************/
/* Returns worker Termination Date                                            */
/******************************************************************************/
FUNCTION get_term_date (p_assignment_id  IN NUMBER
                       ,p_person_id      IN NUMBER)

            RETURN DATE IS
 l_end_place_date DATE;
BEGIN

  SELECT effective_change_end_date  INTO l_end_place_date
  FROM hri_mb_asgn_events_ct asgn
  WHERE
       asgn.person_id = p_person_id
  AND  asgn.assignment_id = p_assignment_id
  and  asgn.worker_term_nxt_ind = 1 ;

  RETURN l_end_place_date ;

EXCEPTION WHEN OTHERS THEN
  RETURN null;

END get_term_date;


END hri_bpl_dbi_calc_period;

/
