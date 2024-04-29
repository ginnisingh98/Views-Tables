--------------------------------------------------------
--  DDL for Package Body HRI_BPL_TREND_WRKFC_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_TREND_WRKFC_SQL" AS
/* $Header: hribtwrk.pkb 120.5 2005/06/24 02:30:34 cbridge noship $ */
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
/* A parameter date_join_type controls whether the fact is sampled at the     */
/* start or end of the trend period. This is used for e.g. the headcount for  */
/* turnover calculation which may be a start/end average                      */
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
    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

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
  p_include_hdc      IN VARCHAR2,
  p_include_pasg_cnt IN VARCHAR2,
  p_include_pasg_pow IN VARCHAR2,
  p_include_extn_cnt IN VARCHAR2,
  p_include_extn_pow IN VARCHAR2,
  p_include_hdc_trn  IN VARCHAR2,
  p_include_sal      IN VARCHAR2,
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
  l_measure_hdc       VARCHAR2(1000);
  l_measure_sal       VARCHAR2(1000);

  l_measure_pasg_cnt  VARCHAR2(1000);
  l_measure_pasg_pow  VARCHAR2(1000);
  l_measure_extn_cnt  VARCHAR2(1000);
  l_measure_extn_pow  VARCHAR2(1000);

  l_measure_count     PLS_INTEGER;
  --
BEGIN
-- Initialize measure count and columns
  l_measure_count := 0;
  IF p_use_snapshot THEN
    l_measure_hdc := 'fact.curr_total_hdc_end';

    l_measure_sal := 'hri_oltp_view_currency.convert_currency_amount
(fact.anl_slry_currency,
 :GLOBAL_CURRENCY,
 &BIS_CURRENT_ASOF_DATE,
 fact.curr_total_anl_slry_end,
 :GLOBAL_RATE)';

   l_measure_pasg_cnt := 'fact.curr_total_pasg_cnt_end';
   l_measure_pasg_pow := 'fact.curr_total_pow_end';

   l_measure_extn_cnt := 'fact.curr_extn_asg_cnt_end';
   l_measure_extn_pow := 'fact.curr_total_pow_extn_end';

  ELSE
    l_measure_hdc := 'fact.total_headcount';

    l_measure_sal := 'hri_oltp_view_currency.convert_currency_amount
(fact.anl_slry_currency,
 :GLOBAL_CURRENCY,
 &BIS_CURRENT_ASOF_DATE,
 fact.total_anl_slry,
 :GLOBAL_RATE)';

   l_measure_pasg_cnt := 'fact.total_primary_asg_cnt';
   l_measure_pasg_pow := 'fact.total_primary_asg_pow+' ||
                         '(fact.total_primary_asg_cnt * (tro.period_as_of_date-fact.effective_start_date))';

   l_measure_extn_cnt := 'fact.total_extn_asg_cnt';
   l_measure_extn_pow := 'fact.total_primary_extn_pow+' ||
                         '(fact.total_extn_asg_cnt * (tro.period_as_of_date-fact.effective_start_date))';


  END IF;
-- Check whether buckets are used
  IF p_bucket_dim IS NOT NULL THEN

  -- Set the template to use the bucket column
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

  -- Add headcount columns
  IF (p_include_hdc = 'Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', l_measure_hdc) ||
                     '  period_hdc' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_hdc';

    -- Add headcount start column if available (using snapshots) and if it is
    -- required for the turnover calculation
    -- do not add to list of returned measures
    IF (p_use_snapshot AND
        p_include_hdc_trn = 'Y') THEN
      p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                              '<measure>', 'fact.curr_total_hdc_start') ||
                     '  period_hdc_start' || g_rtn;
    END IF;

    -- Loop through buckets to add required columns
    IF p_bucket_dim IS NOT NULL THEN
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
          REPLACE(REPLACE(l_column_bucket,
                            '<measure>', l_measure_hdc),
                  '<value>', l_bucket_tab(i).bucket_id_string) ||
         '  period_hdc_' || l_bucket_tab(i).bucket_name || g_rtn;
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_hdc_' ||
                                              l_bucket_tab(i).bucket_name;
        -- Add headcount start column if available (using snapshots) and if it is
        -- required for the turnover calculation
        -- do not add to list of returned measures
        IF (p_use_snapshot AND
            p_include_hdc_trn = 'Y') THEN
          p_select_sql := p_select_sql || ',' ||
            REPLACE(REPLACE(l_column_bucket,
                              '<measure>', 'fact.curr_total_hdc_start'),
                    '<value>', l_bucket_tab(i).bucket_id_string) ||
                         '  period_hdc_start_' || l_bucket_tab(i).bucket_name || g_rtn;
        END IF;
      END LOOP;
    END IF;

  END IF;

  -- Add salary columns
  IF (p_include_sal = 'Y') THEN
    p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_sal) ||
                     '  period_sal_end' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_sal_end';

    -- Loop through buckets to add required columns
    IF p_bucket_dim IS NOT NULL THEN
      FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP
        p_select_sql := p_select_sql || ',' ||
          REPLACE(REPLACE(l_column_bucket,
                          '<measure>', l_measure_sal),
                  '<value>', l_bucket_tab(i).bucket_id_string) ||
          '  period_sal_' || l_bucket_tab(i).bucket_name || g_rtn;
        l_measure_count := l_measure_count + 1;
        p_measure_columns(l_measure_count) := 'period_sal_' ||
                                              l_bucket_tab(i).bucket_name;
      END LOOP;
    END IF;

  END IF;
  --

  -- Add Primary Assignment Count columns
  IF (p_include_pasg_cnt = 'Y') THEN
   p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_pasg_cnt) ||
                     '  period_pasg_cnt' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_pasg_cnt';
  END IF;

  -- Add Primary Assignment Period of Work columns
  IF (p_include_pasg_pow = 'Y') THEN
   p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_pasg_pow) ||
                     '  period_pasg_pow' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_pasg_pow';
  END IF;

  -- Add Extension Assignment Count columns
  IF (p_include_extn_cnt = 'Y') THEN
   p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_extn_cnt) ||
                     '  period_extn_cnt' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_extn_cnt';
  END IF;

  -- Add Contingent Worker Extension Period of Work columns
  IF (p_include_extn_pow = 'Y') THEN
   p_select_sql := p_select_sql || ',' || REPLACE(g_column_select,
                                            '<measure>', l_measure_extn_pow) ||
                     '  period_extn_pow' || g_rtn;

    l_measure_count := l_measure_count + 1;
    p_measure_columns(l_measure_count) := 'period_extn_pow';
  END IF;

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
-- This function returns the inner SQL that is required for genrating the
-- headcount trend reports
--
-- INPUT PARAMETERS:
--  p_parameter_rec: Parameters passed to the report
--  p_bind_tab: The bind strings for PMV and SQL mode
--  p_bind_format : SQL or PMV format
--  p_include_hdc : Should headcount be included
--  p_include_sal : Should Salary be included
--  p_past_trend: Set if SQL has to be generated for past periods
--  p_future_trend: Set if SQL has to be generated for future periods
-- -------------------------------------------------------------------------
--
PROCEDURE get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN hri_oltp_pmv_query_trend.trend_sql_params_type,
  p_date_join_type    IN VARCHAR2,
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
  l_parameter_rec.view_by := 'HRI_PERSON+HRI_PER_USRDR_H';
  hri_bpl_fact_sup_wrkfc_sql.set_fact_table
   (p_parameter_rec => l_parameter_rec,
    p_bucket_dim => p_trend_sql_params.bucket_dim,
    p_include_sal => p_trend_sql_params.include_sal,
    p_parameter_count => 0,
    p_single_param => NULL,
    p_use_snapshot => l_use_snapshot,
    p_fact_table => l_fact_table);
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
    p_bucket_dim => p_trend_sql_params.bucket_dim,
    p_include_hdc => p_trend_sql_params.include_hdc,
    p_include_pasg_cnt  => p_trend_sql_params.include_pasg_cnt,
    p_include_pasg_pow  => p_trend_sql_params.include_pasg_pow,
    p_include_extn_cnt  => p_trend_sql_params.include_extn_cnt,
    p_include_extn_pow  => p_trend_sql_params.include_extn_pow,
    p_include_hdc_trn => p_trend_sql_params.include_hdc_trn,
    p_include_sal => p_trend_sql_params.include_sal,
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
  -- Set the date join on period start / end
  --
  IF (p_date_join_type = 'PERIOD_START') THEN
    l_date_join := 'AND tro.period_start_date - 1 ';
  ELSE -- 'PERIOD_END'
    l_date_join := 'AND tro.period_as_of_date ';
  END IF;
  --
  -- Finish off the date join depending on whether a snapshot is used
  --
  IF l_use_snapshot THEN
    l_date_join := l_date_join || '= fact.effective_date' || g_rtn;
    l_fact_condition := l_fact_condition ||
'AND fact.period_type = &PERIOD_TYPE
AND fact.comparison_type IN (&TIME_COMPARISON_TYPE, ''TREND'')' || g_rtn;
  ELSE
    l_date_join := l_date_join || 'BETWEEN fact.effective_start_date ' ||
                                  'AND fact.effective_end_date' || g_rtn;
  END IF;

  IF (p_trend_sql_params.include_extn_cnt = 'Y' or p_trend_sql_params.include_extn_pow = 'Y') THEN
     l_fact_condition := l_fact_condition
       || 'AND fact.wkth_wktyp_sk_fk = ''CWK'' '|| g_rtn ;
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

END hri_bpl_trend_wrkfc_sql;

/
