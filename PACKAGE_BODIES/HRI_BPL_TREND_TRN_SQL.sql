--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TREND_TRN_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TREND_TRN_SQL" AS
/* $Header: hribttrn.pkb 120.0 2005/05/29 07:05:29 appldev noship $ */
--
g_rtn   VARCHAR2(30) := '
';
--
--
/******************************************************************************/
/* PROCESS FLOW                                                               */
/* ============                                                               */
/* This package formulates the fact query for the turnover calculation over   */
/* a set of trend periods. The functions that return the trend SQL for        */
/* headcount and terminations are called and the resulting queries joined     */
/* into a single query. The measure column list is also merged.               */
/*                                                                            */
/* Turnover calculation                                                       */
/* --------------------                                                       */
/* If the turnover calculation uses headcount at the start and end of the     */
/* period then the headcount function is called twice to get the headcount    */
/* total at each end of the period.                                           */
/*                                                                            */
/* The headcount-for-turnover calculation is used and the result put in a     */
/* new column period_hdc_trn.                                                 */
/*                                                                            */
/* Return SQL                                                                 */
/* ----------                                                                 */
/* The resulting SQL returned looks like:                                     */
/*                                                                            */
/*   SELECT                                                                   */
/*    Period Id (Date)                                                        */
/*    Period Order                                                            */
/*    Measure columns (merged)                                                */
/*   FROM                                                                     */
/*    Terminations by Trend Period                                            */
/*    Headcount at Trend Period End                                           */
/*    Headcount at Trend Period Start (if required)                           */
/*   WHERE                                                                    */
/*    Join fact tables on period id                                           */
/*                                                                            */
/*                                                                            */
/******************************************************************************/
--
-- -------------------------------------------------------------------------
-- This procedure returns the trend inner SQL for turnover and the list of
-- measure columns used
-- -------------------------------------------------------------------------
--
PROCEDURE get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE,
  p_fact_sql          OUT NOCOPY VARCHAR2,
  p_measure_columns   OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type)
IS
  --
  -- Stores the trend SQL for termination
  --
  l_termination_sql     VARCHAR2(32767);
  l_trm_measure_cols    hri_oltp_pmv_query_trend.trend_measure_cols_type;
  --
  -- Stores the trend SQL for headcount
  --
  l_headcount_sql       VARCHAR2(32767);
  l_hdc_measure_cols    hri_oltp_pmv_query_trend.trend_measure_cols_type;
  --
  -- Stores the trend SQL for headcount at period start
  -- (if required for turnover calculation)
  --
  l_headcount_start_sql VARCHAR2(32767);
  l_hdc_start_cols      hri_oltp_pmv_query_trend.trend_measure_cols_type;
  --
  -- Stores the turnover SQL
  --
  l_bucket_tab          hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;
  l_sql_select          VARCHAR2(10000);
  --
  l_trend_sql_params    hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE;
  l_index               PLS_INTEGER := 0;
  l_trn_calc_mth        VARCHAR2(30);
  l_use_snapshot        BOOLEAN;
  --
BEGIN
  --
  -- Fetch the trend SQL for termination
  --
  hri_bpl_trend_trm_sql.get_sql
   (p_parameter_rec    => p_parameter_rec,
    p_bind_tab         => p_bind_tab,
    p_trend_sql_params => p_trend_sql_params,
    p_fact_sql         => l_termination_sql,
    p_measure_columns  => l_trm_measure_cols);
  --
  -- Fetch the trend SQL for headcount
  --
  -- Set the parameter for including headcount for
  -- turnover calculation
  --
  l_trend_sql_params := p_trend_sql_params;
  l_trend_sql_params.include_hdc_trn := 'Y';
  hri_bpl_trend_wrkfc_sql.get_sql
   (p_parameter_rec    => p_parameter_rec,
    p_bind_tab         => p_bind_tab,
    p_trend_sql_params => l_trend_sql_params,
    p_date_join_type   => 'PERIOD_END',
    p_fact_sql         => l_headcount_sql,
    p_measure_columns  => l_hdc_measure_cols,
    p_use_snapshot     => l_use_snapshot);
  --
  -- Combine the measure columns into a master column list
  -- also adding the turnover columns into the select clause
  --
  l_index := 0;
  FOR i IN l_hdc_measure_cols.FIRST..l_hdc_measure_cols.LAST LOOP
    l_index := l_index + 1;
    --
    -- Relabel headcount measures as headcount for turnover calculation
    --
    p_measure_columns(l_index) := REPLACE(l_hdc_measure_cols(i), 'hdc', 'hdc_trn');
  END LOOP;
  FOR j IN l_trm_measure_cols.FIRST..l_trm_measure_cols.LAST LOOP
    l_index := l_index + 1;
    p_measure_columns(l_index) := l_trm_measure_cols(j);
  /* Add turnover measure columns to select list */
    l_sql_select := l_sql_select || ',sep.' || l_trm_measure_cols(j) || g_rtn;
  END LOOP;
  --
  -- Format the SQL differently depending on the turnover calculation method
  -- and whether or not snapshot MVs are available
  --
  IF ((fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') AND
      NOT l_use_snapshot) THEN

  -- Start/end average required, no snapshots available
  -- SQL returned needs to join to workforce fact twice to get the
  -- headcount at start and end of each period

  /* Get the SQL for headcount at period start */
    hri_bpl_trend_wrkfc_sql.get_sql
     (p_parameter_rec    => p_parameter_rec,
      p_bind_tab         => p_bind_tab,
      p_trend_sql_params => p_trend_sql_params,
      p_date_join_type   => 'PERIOD_START',
      p_fact_sql         => l_headcount_start_sql,
      p_measure_columns  => l_hdc_start_cols,
      p_use_snapshot => l_use_snapshot);

  /* Add the headcount for turnover calculation columns */
    FOR i IN l_hdc_measure_cols.FIRST..l_hdc_measure_cols.LAST LOOP
      -- Replace headcount measure with headcount for turnover calculation
      IF (INSTR(l_hdc_measure_cols(i), 'hdc') > 0) THEN
            l_sql_select := l_sql_select ||
',(wmv.' || l_hdc_measure_cols(i) || ' + ' ||
'NVL(wmv_start.' || l_hdc_measure_cols(i) || ', 0)) / 2  ' ||
 REPLACE(l_hdc_measure_cols(i), 'hdc', 'hdc_trn') || g_rtn;
      -- Add other measures
      ELSE
        l_sql_select := l_sql_select || ',wmv.' || l_hdc_measure_cols(i) || g_rtn;
      END IF;
    END LOOP;

    --
    -- Form the turnover SQL
    --
    p_fact_sql :=
'SELECT
 sep.period_as_of_date
,sep.period_order' || g_rtn ||
 l_sql_select ||
'FROM
 ('||l_termination_sql      ||')  sep
,('||l_headcount_sql        ||')  wmv
,('||l_headcount_start_sql  ||')  wmv_start
WHERE sep.period_as_of_date = wmv.period_as_of_date
AND wmv.period_as_of_date = wmv_start.period_as_of_date (+)';

  ELSE

    IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN

    -- Snapshot fact available
    -- Period Headcount start/end included in single snapshot

    /* Add the headcount for turnover calculation columns */
      FOR i IN l_hdc_measure_cols.FIRST..l_hdc_measure_cols.LAST LOOP
        -- Replace headcount start with headcount for turnover calculation
        IF (INSTR(l_hdc_measure_cols(i), 'hdc') > 0) THEN
          l_sql_select := l_sql_select ||
             ',(wmv.' || l_hdc_measure_cols(i) || ' + wmv.' ||
             REPLACE(l_hdc_measure_cols(i), 'hdc', 'hdc_start') || ') / 2  ' ||
             REPLACE(l_hdc_measure_cols(i), 'hdc', 'hdc_trn') || g_rtn;
        -- Add non-headcount columns
        ELSE
          l_sql_select := l_sql_select || ',wmv.' || l_hdc_measure_cols(i) || g_rtn;
        END IF;
      END LOOP;

    ELSE

    -- Only headcount at period end is required for the turnover calculation
    -- Snapshot/standard MVs have similar SQL format

    /* Add the headcount for turnover calculation columns */
      FOR i IN l_hdc_measure_cols.FIRST..l_hdc_measure_cols.LAST LOOP
        l_sql_select := l_sql_select ||
  ',wmv.' || l_hdc_measure_cols(i) || '  ' ||
             REPLACE(l_hdc_measure_cols(i), 'hdc', 'hdc_trn') || g_rtn;
      END LOOP;
    END IF;

    --
    -- Form the turnover SQL
    --
    p_fact_sql :=
'SELECT
 sep.period_as_of_date
,sep.period_order' || g_rtn ||
 l_sql_select ||
'FROM
 ('||l_termination_sql||')  sep
,('||l_headcount_sql  ||')  wmv
WHERE sep.period_as_of_date = wmv.period_as_of_date';
  --
  END IF;
  --
END get_sql;
--
END hri_bpl_trend_trn_sql;

/
