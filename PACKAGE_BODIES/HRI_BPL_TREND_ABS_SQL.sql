--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TREND_ABS_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TREND_ABS_SQL" AS
/* $Header: hribtabs.pkb 120.0 2005/09/22 07:28 cbridge noship $ */
--
--
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
/* The set_fact_table function in HRI_BPL_FACT_ABS_SQL is used to determine   */
/* the appropriate fact object.                                               */
/*                                                                            */
/* WHERE                                                                      */
/* -----                                                                      */
/* set_conditions adds in any extra conditions required e.g. in top 4         */
/* categories a filter on the top 4 categories codes is added                 */
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
/* An outer layer of SQL is added that brings in periods with no data by      */
/* doing a UNION ALL with the trend periods table.                            */
/*                                                                            */
/* Note: Snapshoting not currently supported in first release of Absences     */
/*                                                                            */
/******************************************************************************/
--
-- Sets select column templates for accessing the workforce fact
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
    IF (l_parameter_name = 'HRI_ABSNC+HRI_ABSNC_CAT' ) THEN

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
-- specified as the metadata.
-- -------------------------------------------------------------------------
--
PROCEDURE set_select
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim       IN VARCHAR2,
  p_include_abs_drtn_days IN VARCHAR2,
  p_include_abs_drtn_hrs  IN VARCHAR2,
  p_include_abs_in_period IN VARCHAR2,
  p_include_abs_ntfctn_period IN VARCHAR2,
  p_use_snapshot     IN BOOLEAN,
  p_select_sql       OUT NOCOPY VARCHAR2,
  p_measure_columns  OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type)
IS

  -- template
  l_column_bucket  VARCHAR2(1000);
  -- table of bucket values
  l_bucket_tab        hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;
  --
  -- For forming the select statement
  --
  l_measure_abs_drtn_days    VARCHAR2(1000);
  l_measure_abs_drtn_hrs     VARCHAR2(1000);
  l_measure_abs_drtn_in_prd  VARCHAR2(1000);
  l_measure_abs_drtn_ntf_prd VARCHAR2(1000);

  l_measure_count     PLS_INTEGER;
  --
BEGIN

-- Initialize measure count and columns
  l_measure_count := 0;
  l_measure_abs_drtn_days := 'fact.abs_drtn_days';
  l_measure_abs_drtn_hrs  := 'fact.abs_drtn_hrs';
  l_measure_abs_drtn_in_prd := 'fact.abs_start_blnc + fact.abs_nstart_blnc';
  l_measure_abs_drtn_ntf_prd := 'fact.abs_ntfctn_days_start_blnc + fact.abs_ntfctn_days_nstart_blnc';

-- Get a pl/sql table containing the buckets for the given bucket dimension
    IF (p_bucket_dim = 'HRI_ABSNC+HRI_ABSNC_CAT') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_abs_category_buckets_tab;
    END IF;

-- Set measure columns for Absence Duration Days
  IF (p_include_abs_drtn_days ='Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', l_measure_abs_drtn_days) ||
                     '  period_abs_drtn_days' || g_rtn;
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_abs_drtn_days';

    IF p_bucket_dim IS NOT NULL THEN

    -- Set the bucket column template to use the bucket column
    l_column_bucket := REPLACE(g_column_bucket, '<bucket>',
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
           (p_bucket_dim).fact_viewby_col);


    /* Loop through bucket ids to add required columns */
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_abs_drtn_days),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
           '  period_abs_drtn_days_' || l_bucket_tab(i).bucket_name || g_rtn;
        -- Add column name to measure table
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_abs_drtn_days_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;
    END IF;
  END IF;
--

-- Set measure columns for Absence Duration Hours
  IF (p_include_abs_drtn_hrs  ='Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', l_measure_abs_drtn_hrs) ||
                     '  period_abs_drtn_hrs' || g_rtn;
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_abs_drtn_hrs';

   IF p_bucket_dim IS NOT NULL THEN

    -- Set the bucket column template to use the bucket column
    l_column_bucket := REPLACE(g_column_bucket, '<bucket>',
          hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
           (p_bucket_dim).fact_viewby_col);

    /* Loop through bucket ids to add required columns */
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_abs_drtn_hrs),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
           '  period_abs_drtn_hrs_' || l_bucket_tab(i).bucket_name || g_rtn;
        -- Add column name to measure table
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_abs_drtn_hrs_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;

    END IF;
  END IF;
--

-- Set measure columns for Absence In Period
  IF (p_include_abs_in_period  ='Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', l_measure_abs_drtn_in_prd) ||
                     '  period_abs_in_period' || g_rtn;
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_abs_in_period';
  END IF;
--

-- Set measure columns for Absence Notification In Period
  IF (p_include_abs_ntfctn_period  ='Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', l_measure_abs_drtn_ntf_prd) ||
                     '  period_abs_ntfctn_period' || g_rtn;
    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_abs_ntfctn_period';
  END IF;
--

END set_select;
--
-- -------------------------------------------------------------------------
-- This procedure returns conditions apart from the common conditions that
-- are present in a typical trend SQL.
-- -------------------------------------------------------------------------
--
PROCEDURE set_conditions(p_bucket_dim           IN VARCHAR2,
                         p_fact_condition       IN OUT NOCOPY VARCHAR2)
IS
  --
  --
BEGIN
  --
  -- Set the country condition only when the bucket dimension is country
  --
  IF p_bucket_dim = 'HRI_ABSNC+HRI_ABSNC_CAT' THEN
    --
    p_fact_condition := p_fact_condition ||
'AND fact.absence_category_code IN
   (:ABS_CATEGORY_CODE1,
    :ABS_CATEGORY_CODE2,
    :ABS_CATEGORY_CODE3,
    :ABS_CATEGORY_CODE4)' || g_rtn;
    --
  END IF;
  --
END set_conditions;

--
-- -------------------------------------------------------------------------
-- This function returns the inner SQL that is required for genrating the
-- headcount trend reports
--
-- INPUT PARAMETERS:
--  p_parameter_rec: Parameters passed to the report
--  p_bind_tab: The bind strings for PMV and SQL mode
--  p_bind_format : SQL or PMV format
--  p_past_trend: Set if SQL has to be generated for past periods
--  p_future_trend: Set if SQL has to be generated for future periods
-- -------------------------------------------------------------------------
--
PROCEDURE get_sql
 (p_parameter_rec     IN  hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN  hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN  hri_oltp_pmv_query_trend.trend_sql_params_type,
  p_date_join_type    IN  VARCHAR2,
  p_fact_sql          OUT NOCOPY VARCHAR2,
  p_measure_columns   OUT NOCOPY hri_oltp_pmv_query_trend.trend_measure_cols_type,
  p_use_snapshot      OUT NOCOPY BOOLEAN)
IS
  --
  l_trend_periods_tbl    VARCHAR2(32767);
  l_select_sql           VARCHAR2(32767);
  l_fact_table           VARCHAR2(100);
  l_date_join            VARCHAR2(1000);
  l_fact_condition       VARCHAR2(1000);
  l_use_snapshot         BOOLEAN;
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_param_conditions     VARCHAR2(1000);
  l_parameter_count      PLS_INTEGER;
  --
BEGIN
  -- -----------------------------------------------------------------------
  -- FROM CLAUSE
  -- -----------------------------------------------------------------------
  analyze_parameters
   (p_bind_tab         => p_bind_tab,
    p_fact_conditions  => l_param_conditions,
    p_parameter_count  => l_parameter_count);
  --
  -- Fetch the SQL for the table of periods
  --
  l_trend_periods_tbl := '(' ||
                  HRI_OLTP_PMV_QUERY_TIME.get_time_clause
                   (p_past_trend   => p_trend_sql_params.past_trend,
                    p_future_trend => p_trend_sql_params.future_trend) || ')';
  --
  -- Set the fact table
  --
  l_parameter_rec := p_parameter_rec;
  l_parameter_rec.view_by := 'HRI_ABSNC+HRI_ABSNC_CAT';

  hri_bpl_fact_abs_sql.set_fact_table
   (p_parameter_rec     => l_parameter_rec,
    p_bucket_dim        => p_trend_sql_params.bucket_dim,
    p_abs_drtn_days     => p_trend_sql_params.include_abs_drtn_days,
    p_abs_drtn_hrs      => p_trend_sql_params.include_abs_drtn_hrs,
    p_abs_in_period     => p_trend_sql_params.include_abs_in_period,
    p_abs_ntfctn_period => p_trend_sql_params.include_abs_ntfctn_period,
    p_parameter_count   => 0,
    p_single_param      => NULL,
    p_use_snapshot      => l_use_snapshot,
    p_fact_table        => l_fact_table);
  --
  -- -----------------------------------------------------------------------
  -- SELECT CLAUSE
  -- -----------------------------------------------------------------------
  --
  -- Set the select column templates
  --
  set_metadata;
  --
  --
  -- Fetches the column in the select clause. If p_group_by is true then
  -- all the columns will be summed up. Common columns included in all
  -- trend reports will not be fetched
  --
  set_select
   (p_parameter_rec => l_parameter_rec,
    p_bucket_dim        => p_trend_sql_params.bucket_dim,
    p_include_abs_drtn_days     => p_trend_sql_params.include_abs_drtn_days,
    p_include_abs_drtn_hrs      => p_trend_sql_params.include_abs_drtn_hrs,
    p_include_abs_in_period     => p_trend_sql_params.include_abs_in_period,
    p_include_abs_ntfctn_period => p_trend_sql_params.include_abs_ntfctn_period,
    p_use_snapshot => l_use_snapshot,
    p_select_sql => l_select_sql,
    p_measure_columns => p_measure_columns);
  --
  --
  -- -----------------------------------------------------------------------
  -- WHERE CLAUSE
  -- -----------------------------------------------------------------------
  --
  -- Get the conditions for the where clause. Common conditions included in all
  -- trend reports will not be fetched
  --
  set_conditions
   (p_bucket_dim          => p_trend_sql_params.bucket_dim,
    p_fact_condition      => l_fact_condition);
  --

  -- Add direct record condition for old style fact tables
  --
  IF (upper(l_fact_table) = 'HRI_MDP_SUP_ABSNC_CAT_MV' ) THEN
    l_fact_condition := l_fact_condition ||
  'AND fact.direct_record_ind = 0' || g_rtn;
  END IF;


  -- Date join is equality if using snapshots
  --
  IF (p_use_snapshot) THEN
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
 ' || l_trend_periods_tbl || '  tro
,' || l_fact_table || '  fact
WHERE fact.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H' || g_rtn ||
 l_date_join ||
 l_fact_condition ||
 l_param_conditions ||
'GROUP BY
 tro.period_order
,tro.period_as_of_date';

  p_use_snapshot := l_use_snapshot;

END get_sql;

END hri_bpl_trend_abs_sql;

/
