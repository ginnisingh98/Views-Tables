--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TREND_TRM_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TREND_TRM_SQL" AS
/* $Header: hribttrm.pkb 120.3 2005/06/23 05:59:37 cbridge noship $ */
--
--
g_use_snapshot    BOOLEAN;
g_column_select   VARCHAR2(1000);
g_column_bucket   VARCHAR2(1000);
g_rtn             VARCHAR2(30) := '
';
--
--
/******************************************************************************/
/* PROCESS FLOW                                                               */
/* ============                                                               */
/* The main entry point is the get_sql function. The processing is as follows */
/*                                                                            */
/* SELECT                                                                     */
/* ------                                                                     */
/* Templates for the measure columns are set by the set_metadata function.    */
/* Appropriate measures are then added to the select list using the template  */
/* depending on the input trend parameter record                              */
/*                                                                            */
/* A list of all the measure columns added is maintained and returned to the  */
/* calling function so that outer layers of SQL can reference all the columns */
/*                                                                            */
/* FROM                                                                       */
/* ----                                                                       */
/* The set_fact_table function in HRI_BPL_FACT_WRKFC_SQL is used to determine */
/* the appropriate fact object.                                               */
/*                                                                            */
/* WHERE                                                                      */
/* -----                                                                      */
/* set_conditions adds in any extra conditions required e.g. in top 4         */
/* countries a filter on the top 4 country codes is added                     */
/*                                                                            */
/* If the fact object is a snapshot MV then the date join will be an equality */
/* join rather than a between                                                 */
/*                                                                            */
/* SQL RETURNED                                                               */
/* ============                                                               */
/* The SQL is returned along with a list of all the measure columns in the    */
/* SELECT list:                                                               */
/*                                                                            */
/*   SELECT                                                                   */
/*    Period Id (Date)                                                        */
/*    Period Order                                                            */
/*    Measure Columns                                                         */
/*   FROM                                                                     */
/*    Table of periods to plot (sub-query)                                    */
/*    Snapshot/standard fact object                                           */
/*   WHERE                                                                    */
/*    Filter on selected manager                                              */
/*    Date filter (varies with snapshot/standard fact)                        */
/*    Additional filters (e.g. top 4 countries)                               */
/*                                                                            */
/* An outer layer of SQL is added for the TURNOVER calculation.               */
/* An outer layer of SQL is added that brings in periods with no data by      */
/* doing a UNION ALL with the trend periods table.                            */
/*                                                                            */
/******************************************************************************/
--
-- -------------------------------------------------------------------------
-- This procedure sets the select column templates for accessing the
-- turnover fact
-- -------------------------------------------------------------------------
--
PROCEDURE set_metadata IS
  --
BEGIN
  --
g_column_select := 'NVL(SUM(<measure>), 0)';
g_column_bucket :=
'NVL(SUM(CASE WHEN fact.<bucket> = <value>
             THEN <measure>
             ELSE 0
        END), 0)';
--
END set_metadata;
--
--
-- -------------------------------------------------------------------------
-- This procedure is for future use only - applies dimension level parameter
-- conditions. Currently all trend reports are run from the main page which
-- does not have any additional parameters.
-- -------------------------------------------------------------------------
--
PROCEDURE analyze_parameters
 (p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_fact_conditions  OUT NOCOPY VARCHAR2,
  p_parameter_count  OUT NOCOPY PLS_INTEGER) IS

  l_parameter_name   VARCHAR2(100);

BEGIN

/* Initialize parameter count */
  p_parameter_count := 0;

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP
    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X' OR
        l_parameter_name = 'HRI_REASON+HRI_RSN_SEP_X' OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    /* Dynamically set conditions for parameter */
      p_fact_conditions := p_fact_conditions ||
        'AND fact.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                        (l_parameter_name).fact_viewby_col ||
        ' IN (' || p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    /* Keep count of parameters set */
      p_parameter_count := p_parameter_count + 1;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;

END analyze_parameters;
--
-- -------------------------------------------------------------------------
-- This function returns a string which contains the columns in the fact
-- that have to be selected. The columns that are to be selected are
-- added using the column templates.
--
-- The column names of the columns added are stored in the measure column
-- table passed back to the calling package so that the columns can be
-- added to outer layers of SQL
-- -------------------------------------------------------------------------
--
PROCEDURE set_select
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim      IN VARCHAR2,
  p_include_sep     IN VARCHAR2,
  p_include_sep_inv IN VARCHAR2,
  p_include_sep_vol IN VARCHAR2,
  p_select_sql      OUT NOCOPY VARCHAR2,
  p_measure_columns OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type)
IS
  --
  -- template for bucket column
  --
  l_column_bucket  VARCHAR2(1000);
  --
  -- table of bucket values
  --
  l_bucket_tab        hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;
  --
  -- For forming the select statement
  --
  l_measure_trm   VARCHAR2(1000);
  l_measure_inv   VARCHAR2(1000);
  l_measure_vol   VARCHAR2(1000);
  l_measure_count PLS_INTEGER;
  --
BEGIN
-- Initialize measure count
  l_measure_count := 0;
-- Check whether buckets are used
  IF p_bucket_dim IS NOT NULL THEN

  -- Set the bucket column template to use the bucket column
    l_column_bucket := REPLACE(g_column_bucket, '<bucket>',
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
           (p_bucket_dim).fact_viewby_col);

  -- Get a pl/sql table containing the buckets for the given bucket dimension
    IF (p_bucket_dim = 'HRI_LOW+HRI_LOW_BAND_X') THEN
      hri_mtdt_dim_lvl.set_low_band_buckets(p_parameter_rec.wkth_wktyp_sk_fk);
      l_bucket_tab := hri_mtdt_dim_lvl.g_low_band_buckets_tab;
    ELSIF (p_bucket_dim = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_prfmnc_band_buckets_tab;
    ELSIF (p_bucket_dim = 'GEOGRAPHY+COUNTRY') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_country_buckets_tab;
    ELSIF (p_bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_wkth_wktyp_tab;
    END IF;
  END IF;

  -- Add termination columns
  IF (p_include_sep = 'Y') THEN
    l_measure_trm := 'fact.separation_hdc';

    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_trm) ||
                     '  period_sep_hdc' || g_rtn;

    -- Add column name to measure table
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_sep_hdc';

    -- Loop through buckets to add required columns
    IF p_bucket_dim IS NOT NULL THEN
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_trm),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
           '  period_sep_hdc_' || l_bucket_tab(i).bucket_name || g_rtn;
        -- Add column name to measure table
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_sep_hdc_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;
    END IF;

  END IF;
  --
  -- Add Involuntary Termination columns
  --
  IF (p_include_sep_inv = 'Y') THEN
    l_measure_inv := 'fact.sep_invol_hdc';

    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_inv) ||
                     '  period_sep_invol_hdc' || g_rtn;

    -- Add column name to measure table
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_sep_invol_hdc';

    IF p_bucket_dim IS NOT NULL THEN

    /* Loop through bucket ids to add required columns */
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_inv),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
           '  period_sep_invol_hdc_' || l_bucket_tab(i).bucket_name || g_rtn;

        -- Add column name to measure table
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_sep_invol_hdc_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;

    END IF;

  END IF;
  --
  -- Add Voluntary Termination columns
  --
  IF (p_include_sep_vol = 'Y') THEN
    l_measure_vol := 'fact.sep_vol_hdc';

    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_vol) ||
                     '  period_sep_vol_hdc' || g_rtn;

    -- Add column name to measure table
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_sep_vol_hdc';

    IF p_bucket_dim IS NOT NULL THEN

    /* Loop through bucket ids to add required columns */
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_vol),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
           '  period_sep_vol_hdc_' || l_bucket_tab(i).bucket_name || g_rtn;
        -- Add column name to measure table
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_sep_vol_hdc_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;

    END IF;

  END IF;
  --
END set_select;

--
-- -------------------------------------------------------------------------
-- This procedure returns conditions apart from the common conditions that
-- are present in a typical trend SQL.
-- -------------------------------------------------------------------------
--
PROCEDURE set_conditions(p_bucket_dim      IN VARCHAR2,
                         p_fact_condition  IN OUT NOCOPY VARCHAR2)
IS
  --
  --
BEGIN
  --
  IF p_bucket_dim = 'GEOGRAPHY+COUNTRY' THEN
    --
    p_fact_condition := p_fact_condition ||
'AND fact.geo_country_code IN
   (:GEO_COUNTRY_CODE1,
    :GEO_COUNTRY_CODE2,
    :GEO_COUNTRY_CODE3,
    :GEO_COUNTRY_CODE4)' || g_rtn;
    --
  END IF;
  --
END set_conditions;
--
-- -------------------------------------------------------------------------
-- This function returns the inner SQL that is required for generating the
-- headcount trend reports
-- -------------------------------------------------------------------------
--
PROCEDURE get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN hri_oltp_pmv_query_trend.trend_sql_params_type,
  p_fact_sql          OUT NOCOPY VARCHAR2,
  p_measure_columns   OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type)
IS
  --
  l_trend_periods_tbl VARCHAR2(32767);
  l_select_sql        VARCHAR2(32767);
  l_fact_table        VARCHAR2(50);
  l_fact_condition    VARCHAR2(1000);
  l_param_conditions  VARCHAR2(1000);
  l_parameter_count   PLS_INTEGER;
  l_parameter_rec     hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  --
BEGIN
  --
  -- Check whether a snapshot is available
  --
  g_use_snapshot := hri_oltp_pmv_util_snpsht.use_wcnt_chg_snpsht_for_mgr
                     (p_supervisor_id => p_parameter_rec.peo_supervisor_id,
                      p_effective_date => p_parameter_rec.time_curr_end_date);
  --
  -- -----------------------------------------------------------------------
  -- SELECT CLAUSE
  -- -----------------------------------------------------------------------
  --
  -- Set the column templates
  --
  set_metadata;
  --
  analyze_parameters
   (p_bind_tab         => p_bind_tab,
    p_fact_conditions  => l_param_conditions,
    p_parameter_count  => l_parameter_count);
  --
  -- Add the columns required from the fact to the select clause
  --
  set_select
   (p_parameter_rec => p_parameter_rec,
    p_bucket_dim => p_trend_sql_params.bucket_dim,
    p_include_sep => p_trend_sql_params.include_sep,
    p_include_sep_vol => p_trend_sql_params.include_sep_vol,
    p_include_sep_inv => p_trend_sql_params.include_sep_inv,
    p_select_sql  => l_select_sql,
    p_measure_columns => p_measure_columns);
  --
  -- -----------------------------------------------------------------------
  -- FROM CLAUSE
  -- -----------------------------------------------------------------------
  --
  -- Fetch the SQL for the table of periods
  --
  l_trend_periods_tbl :=
'(' || hri_oltp_pmv_query_time.get_time_clause
        (p_past_trend   => p_trend_sql_params.past_trend,
         p_future_trend => p_trend_sql_params.future_trend) || ')';
  --
  -- Set the fact table
  --
  l_parameter_rec := p_parameter_rec;
  l_parameter_rec.view_by := 'HRI_PERSON+HRI_PER_USRDR_H';
  hri_bpl_fact_sup_wcnt_chg_sql.set_fact_table
   (p_parameter_rec => l_parameter_rec,
    p_bucket_dim => p_trend_sql_params.bucket_dim,
    p_include_hire => 'N',
    p_include_trin => 'N',
    p_include_trout => 'N',
    p_include_term => 'N',
    p_include_low => 'N',
    p_parameter_count => 0,
    p_single_param => NULL,
    p_use_snapshot => g_use_snapshot,
    p_fact_table => l_fact_table);
  --
  -- -----------------------------------------------------------------------
  -- WHERE CLAUSE
  -- -----------------------------------------------------------------------
  --
  -- Add direct record condition for old style fact tables
  --
  IF (l_fact_table = 'hri_mdp_sup_wcnt_chg_mv' OR
      l_fact_table = 'hri_mds_sup_wcnt_chg_mv') THEN
    l_fact_condition := l_fact_condition ||
  'AND fact.direct_record_ind = 0' || g_rtn;
  END IF;

  --
  -- Set date join as equality if using snapshots
  --
  IF (g_use_snapshot) THEN
    l_fact_condition := l_fact_condition ||
'AND fact.effective_date = tro.period_end_date
AND fact.comparison_type IN (''CURRENT'', ''SEQUENTIAL'', ''TREND'')
AND fact.period_type = &PERIOD_TYPE' || g_rtn;
  ELSE
    l_fact_condition := l_fact_condition ||
'AND fact.effective_date BETWEEN tro.period_start_date ' ||
                        'AND tro.period_end_date' || g_rtn;
  END IF;
  --
  -- Get the conditions for the where clause. Common conditions included in all
  -- trend reports will not be fetched
  --
  set_conditions(p_bucket_dim     => p_trend_sql_params.bucket_dim,
                 p_fact_condition => l_fact_condition);
  --
  -- -----------------------------------------------------------------------
  -- BUILD THE SQL
  -- -----------------------------------------------------------------------
  --
  p_fact_sql :=
'SELECT /*+ LEADING(tro) INDEX(fact) */
 tro.period_as_of_date
,tro.period_order' || g_rtn ||
 l_select_sql ||
'FROM
 '||l_trend_periods_tbl||'  tro
,'||l_fact_table|| ' fact
WHERE fact.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H' || g_rtn ||
 l_fact_condition ||
 l_param_conditions ||
'GROUP BY
 tro.period_order
,tro.period_as_of_date';
  --
END get_sql;

END hri_bpl_trend_trm_sql;

/
