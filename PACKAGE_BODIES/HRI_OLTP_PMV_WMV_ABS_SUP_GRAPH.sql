--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH" AS
/* $Header: hriopwabst.pkb 120.1 2005/11/03 06:57 cbridge noship $ */

g_rtn                VARCHAR2(30) := '
';

g_unassigned         VARCHAR2(50) := HRI_OLTP_VIEW_MESSAGE.get_unassigned_msg;

PROCEDURE GET_SQL
  (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql          OUT NOCOPY VARCHAR2,
   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext                 VARCHAR2(32767);
  l_custom_rec              BIS_QUERY_ATTRIBUTES;
  l_security_clause         VARCHAR2(4000);

-- Parameter values
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_abs_category_tab      hri_oltp_pmv_rank_abs.abs_category_tab;

-- Trend Period Parameters
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;
  l_trend_sql           VARCHAR2(10000);
  l_trend_sql_params    hri_oltp_pmv_query_trend.trend_sql_params_type;

-- dyanamic columns
  l_period_abs_drtn_metric1 VARCHAR2(1000);
  l_period_abs_drtn_metric2 VARCHAR2(1000);

  l_drill_url1   VARCHAR2(1000);
  l_drill_url2   VARCHAR2(1000);
  l_drill_url3   VARCHAR2(1000);
  l_drill_url4   VARCHAR2(1000);


BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get bind values for number of time periods */
  hri_oltp_pmv_query_time.get_period_binds
          (p_page_period_type    => l_parameter_rec.page_period_type
          ,p_page_comp_type      => l_parameter_rec.time_comparison_type
          ,o_previous_periods    => l_previous_periods
          ,o_projection_periods  => l_projection_periods);

/* Set the trend sql context for the code centralization call */
  l_trend_sql_params.bind_format := 'PMV';
  l_trend_sql_params.include_hdc := 'Y';
  l_trend_sql_params.include_abs_in_period := 'Y';

/* Set metric base on absence UOM profile option, default to DAYS */
  IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
      l_trend_sql_params.include_abs_drtn_days   := 'Y';

      l_period_abs_drtn_metric1 :=
      'DECODE(qry.period_hdc_abs, 0, to_number(NULL), (qry.period_abs_drtn_days/qry.period_hdc_abs))';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_days';

  ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
      l_trend_sql_params.include_abs_drtn_hrs   := 'Y';
      l_period_abs_drtn_metric1 :=
      'DECODE(qry.period_hdc_abs, 0, to_number(NULL), (qry.period_abs_drtn_hrs/qry.period_hdc_abs))';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_hrs';
  ELSE
      l_trend_sql_params.include_abs_drtn_days   := 'Y';
      l_period_abs_drtn_metric1 :=
      'DECODE(qry.period_hdc_abs, 0, to_number(NULL), (qry.period_abs_drtn_days/qry.period_hdc_abs))';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_days';

  END IF;

/* Call the UI fact code centralization for the Trend */
  l_trend_sql := hri_oltp_pmv_query_trend.get_sql
                  (p_parameter_rec    => l_parameter_rec,
                   p_bind_tab         => l_bind_tab,
                   p_trend_sql_params => l_trend_sql_params,
                   p_calling_module   => 'HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH.GET_SQL');

/* set the dynamic drill urls
l_drill_url1 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR1_GA&' ||
                   'pParamIds=Y';

l_drill_url2 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR1_GA&' ||
                   'pParamIds=Y';

l_drill_url3 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR1_GA&' ||
                   'pParamIds=Y';
l_drill_url4 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR1_GA&' ||
                   'pParamIds=Y';
*/

/* Formulate the PMV final query output for the UI*/
l_sqltext :=
'SELECT -- Employee Absence Trend
 qry.period_as_of_date     VIEWBYID
,qry.period_as_of_date     VIEWBY
,qry.period_order          HRI_P_ORDER_BY_1
,qry.period_as_of_date     HRI_P_GRAPH_X_LABEL_TIME
,'||l_period_abs_drtn_metric1 ||'   HRI_P_MEASURE1
,''' || l_drill_url1 || '''         HRI_P_DRILL_URL1
,'||l_period_abs_drtn_metric2 ||'   HRI_P_MEASURE2
,''' || l_drill_url2 || '''         HRI_P_DRILL_URL2
,qry.period_abs_in_period         HRI_P_MEASURE3
,''' || l_drill_url3 || '''         HRI_P_DRILL_URL3
,qry.period_hdc_abs        HRI_P_MEASURE4
,''' || l_drill_url4 || '''         HRI_P_DRILL_URL4
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')          HRI_P_CHAR1_GA
FROM
 (' || l_trend_sql || ')  qry
WHERE 1=1
'
|| l_security_clause ||
' ORDER BY
  period_order';

  x_custom_sql := l_sqltext;

  l_custom_rec.attribute_name := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value := l_previous_periods;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END GET_SQL ;

END HRI_OLTP_PMV_WMV_ABS_SUP_GRAPH ;

/
