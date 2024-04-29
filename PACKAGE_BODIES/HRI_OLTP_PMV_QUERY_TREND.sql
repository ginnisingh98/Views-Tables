--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_QUERY_TREND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_QUERY_TREND" AS
/* $Header: hriopqtd.pkb 120.3 2005/09/20 05:02:55 cbridge noship $ */

g_rtn  VARCHAR2(30) := '
';

/******************************************************************************/
/* PROCESS FLOW                                                               */
/* ============                                                               */
/* This process calls a function to get SQL to retrieve the data by trend     */
/* period. The trend period SQL query is also found, and the two merged with  */
/* a UNION ALL / GROUP to replace any periods where there is no data.         */
/*                                                                            */
/* First the decision as to which function to call is made depending on the   */
/* trend parameters passed in.                                                */
/*                                                                            */
/* Second the functions to get the fact sql and trend period sql are called.  */
/* Note the fact sql function also returns a list of the measure columns in   */
/* the select list.                                                           */
/*                                                                            */
/* Third the merged SQL is put together, which looks like:                    */
/*                                                                            */
/*   SELECT                                                                   */
/*    Period Id (Date)                                                        */
/*    Period Order                                                            */
/*    SUM(Measure columns)    (returned from fact sql)                        */
/*   FROM                                                                     */
/*    (Fact SQL                                                               */
/*     UNION ALL                                                              */
/*     SELECT                                                                 */
/*      Period Id (Date)                                                      */
/*      Period Order                                                          */
/*      0 (Measure columns)                                                   */
/*     FROM                                                                   */
/*      Trend Period SQL)                                                     */
/*   GROUP BY                                                                 */
/*    Period Id (Date)                                                        */
/*    Period Order                                                            */
/*                                                                            */
/******************************************************************************/

/* This procedure decides whether to call workforce, terminations or */
/* both (turnover), gets the sql for the accessing the required info */
/* and returns this along with a list of the measure columns used    */
PROCEDURE get_fact_sql
  (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_trend_sql_params  IN hri_oltp_pmv_query_trend.trend_sql_params_type,
   p_fact_sql          OUT NOCOPY VARCHAR2,
   p_measure_columns   OUT NOCOPY trend_measure_cols_type)

IS

  l_query_wrkfc        VARCHAR2(30);
  l_query_absence      VARCHAR2(30);
  l_query_wcnt_chg     VARCHAR2(30);
  l_use_snapshot       BOOLEAN;

BEGIN
  --
  -- Decide which facts to call
  --
  IF (p_trend_sql_params.include_hdc = 'Y' OR
      p_trend_sql_params.include_sal = 'Y') THEN
    l_query_wrkfc := 'Y';
  ELSE
    l_query_wrkfc := 'N';
  END IF;
  IF (p_trend_sql_params.include_sep = 'Y' OR
      p_trend_sql_params.include_sep_inv = 'Y' OR
      p_trend_sql_params.include_sep_vol = 'Y') THEN
    l_query_wcnt_chg := 'Y';
  ELSE
    l_query_wcnt_chg := 'N';
  END IF;

  IF (p_trend_sql_params.include_abs_drtn_days = 'Y' OR
      p_trend_sql_params.include_abs_drtn_hrs  = 'Y' OR
      p_trend_sql_params.include_abs_in_period = 'Y' OR
      p_trend_sql_params.include_abs_ntfctn_period = 'Y' )THEN
     l_query_absence := 'Y';
     l_use_snapshot  := TRUE;
  ELSE
     l_query_absence := 'N';
  END IF;

  --
  -- Depending upon the required measures call the headcount/termination
  -- turnover trend SQL package
  --
  IF (l_query_wrkfc = 'Y' AND
      l_query_wcnt_chg = 'N' AND
      l_query_absence  = 'N') THEN
    --
    hri_bpl_trend_wrkfc_sql.get_sql
     (p_parameter_rec    => p_parameter_rec,
      p_bind_tab         => p_bind_tab,
      p_trend_sql_params => p_trend_sql_params,
      p_date_join_type   => 'PERIOD_END',
      p_fact_sql         => p_fact_sql,
      p_measure_columns  => p_measure_columns,
      p_use_snapshot     => l_use_snapshot);
    --
  ELSIF (l_query_wrkfc = 'N' AND
         l_query_wcnt_chg = 'Y' AND
         l_query_absence  = 'N') THEN
    --
    hri_bpl_trend_trm_sql.get_sql
     (p_parameter_rec    => p_parameter_rec,
      p_bind_tab         => p_bind_tab,
      p_trend_sql_params => p_trend_sql_params,
      p_fact_sql         => p_fact_sql,
      p_measure_columns  => p_measure_columns);
    --
  ELSIF (l_query_wrkfc = 'Y' AND
         l_query_wcnt_chg = 'Y' AND
         l_query_absence  = 'N') THEN
    --
    hri_bpl_trend_trn_sql.get_sql
     (p_parameter_rec    => p_parameter_rec,
      p_bind_tab         => p_bind_tab,
      p_trend_sql_params => p_trend_sql_params,
      p_fact_sql         => p_fact_sql,
      p_measure_columns  => p_measure_columns);
    --

   ELSIF (l_query_absence = 'Y' AND
         l_query_wrkfc = 'N') THEN

    --
    hri_bpl_trend_abs_sql.get_sql
    (p_parameter_rec     => p_parameter_rec,
     p_bind_tab          => p_bind_tab,
     p_trend_sql_params  => p_trend_sql_params,
     p_date_join_type    => 'PERIOD_END',
     p_fact_sql          => p_fact_sql,
     p_measure_columns   => p_measure_columns,
     p_use_snapshot      => l_use_snapshot);
    --
 ELSIF (l_query_absence = 'Y' AND
        l_query_wrkfc = 'Y' ) THEN
   --
    hri_bpl_trend_wrkfc_abs_sql.get_sql
    (p_parameter_rec     => p_parameter_rec,
     p_bind_tab          => p_bind_tab,
     p_trend_sql_params  => p_trend_sql_params,
     p_fact_sql          => p_fact_sql,
     p_measure_columns   => p_measure_columns);
   --
  END IF;
  --
END get_fact_sql;

--
-- -------------------------------------------------------------------------
-- This function returns the SQL required for generating trend reports.
-- INPUT PARAMETERS:
--  p_parameter_rec    : Parameters passed to the report
--  p_bind_tab         : The bind strings for PMV and SQL mode
--  p_trend_sql_params : For passing the tredn parameters
-- -------------------------------------------------------------------------
--
FUNCTION get_sql
 (p_parameter_rec     IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab          IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_trend_sql_params  IN trend_sql_params_type,
  p_calling_module    IN VARCHAR2)
      RETURN VARCHAR2 IS
  --
  l_fact_sql           VARCHAR2(32767);
  l_debug_sql          VARCHAR2(32767);
  l_return_sql         VARCHAR2(32767);
  l_debug              VARCHAR2(30) := 'N';
  l_measure_columns    trend_measure_cols_type;
  l_trend_periods_tbl  VARCHAR2(10000);
  l_fact_select        VARCHAR2(10000);
  l_union_select       VARCHAR2(10000);
  l_group_select       VARCHAR2(10000);
  --
BEGIN
  --
  -- Set the SQL to get the trend periods
  --
  l_trend_periods_tbl := '(' ||
                  HRI_OLTP_PMV_QUERY_TIME.get_time_clause
                   (p_past_trend   => p_trend_sql_params.past_trend,
                    p_future_trend => p_trend_sql_params.future_trend) || ')';
  --
  -- get the sql accessing the fact cubes
  --
  get_fact_sql
   (p_parameter_rec    => p_parameter_rec,
    p_bind_tab         => p_bind_tab,
    p_trend_sql_params => p_trend_sql_params,
    p_fact_sql         => l_fact_sql,
    p_measure_columns  => l_measure_columns);

  --
  -- Build SELECT list for UNION ALL
  --
  FOR i IN l_measure_columns.FIRST..l_measure_columns.LAST LOOP

    l_fact_select := l_fact_select || ',' || l_measure_columns(i) || g_rtn;
    l_union_select := l_union_select || ',0  ' || l_measure_columns(i) || g_rtn;
    l_group_select := l_group_select || ',SUM(' || l_measure_columns(i) || ')  ' ||
                      l_measure_columns(i) || g_rtn;

  END LOOP;

  --
  -- Build return sql stmt
  --
  l_return_sql :=
'SELECT
 grp.period_as_of_date
,grp.period_order' || g_rtn ||
 l_group_select ||
'FROM (' || g_rtn ||
  l_fact_sql || g_rtn ||
'  UNION ALL
  SELECT
   tro.period_as_of_date
  ,tro.period_order'
   || g_rtn ||
  l_union_select ||
'  FROM
   (' || l_trend_periods_tbl || ')  tro
)  grp
GROUP BY
 grp.period_as_of_date
,grp.period_order';

  --
  IF l_debug = 'Y' THEN
    --
    -- build sql with bind_format 'SQL' and log result
    --
    l_debug_sql := l_return_sql;
    hri_oltp_pmv_util_pkg.substitute_bind_values
     (p_bind_tab => p_bind_tab,
      p_bind_format => 'SQL',
      p_sql => l_debug_sql);
    --
    -- log debug sql and calling module
    --
  END IF;
   --
  --
  -- Substitute binds if in SQL mode
  --
  IF (p_trend_sql_params.bind_format = 'SQL') THEN
    hri_oltp_pmv_util_pkg.substitute_bind_values
     (p_bind_tab    => p_bind_tab,
      p_bind_format => 'SQL',
      p_sql         => l_return_sql);
  END IF;
  --
  RETURN l_return_sql;
  --
END get_sql;
--
END hri_oltp_pmv_query_trend;


/
