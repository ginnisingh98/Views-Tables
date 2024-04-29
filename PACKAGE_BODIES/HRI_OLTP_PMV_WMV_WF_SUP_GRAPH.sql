--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_WF_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_WF_SUP_GRAPH" AS
/* $Header: hriopwfsg.pkb 120.1 2005/10/26 07:54 jrstewar noship $ */

  g_rtn                VARCHAR2(30) := '
';


PROCEDURE GET_SQL2(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql       OUT NOCOPY VARCHAR2,
                    x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_security_clause     VARCHAR2(4000);
  l_SQLText             VARCHAR2(4000);
  l_trend_sql_params    hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE;

/* Parameter values */
  l_parameter_rec       hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header        VARCHAR(550);
  l_trend_sql           VARCHAR2(32000);

/* Pre-calculations */
  l_trend_table         VARCHAR2(4000);
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;

  l_drill_url1            VARCHAR2(300);
  l_drill_url2            VARCHAR2(300);
  l_drill_url3            VARCHAR2(300);

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get common parameter values */
 hri_oltp_pmv_util_param.get_parameters_from_table
           (p_page_parameter_tbl  => p_page_parameter_tbl,
            p_parameter_rec       => l_parameter_rec,
            p_bind_tab            => l_bind_tab);

/* Get number of periods to use */
  hri_oltp_pmv_query_time.get_period_binds
   (p_page_period_type   => l_parameter_rec.page_period_type
   ,p_page_comp_type     => l_parameter_rec.time_comparison_type
   ,o_previous_periods   => l_previous_periods
   ,o_projection_periods => l_projection_periods);

/* Get the trend sql */
  l_trend_sql_params.bind_format := 'PMV';
  l_trend_sql_params.include_hdc := 'Y';
  l_trend_sql_params.bucket_dim    := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';

  l_trend_sql :=  hri_oltp_pmv_query_trend.get_sql
                   (p_parameter_rec    => l_parameter_rec,
	                p_bind_tab         => l_bind_tab,
                    p_trend_sql_params => l_trend_sql_params,
                    p_calling_module   => 'HRI_OLTP_PMV_WMV_WF_SUP_GRAPH.get_sql2');

  /* use selective drill across feature */
  -- drill to employee detail report
  l_drill_url2 := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';
  -- drill to worker detail report
  l_drill_url3 := 'pFunctionName=HRI_P_WMV_WF_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_PRSNTYP_WKTYP_CN=CWK'||
                  'pParamIds=Y';

/* */
l_sqltext :=
-- l_parameter_rec.debug_header || g_rtn ||
'SELECT -- Workforce Ratio Trend
 qry.period_as_of_date        VIEWBYID
,qry.period_as_of_date        VIEWBY
,qry.period_order             HRI_P_ORDER_BY_1
,qry.period_as_of_date        HRI_P_GRAPH_X_LABEL_TIME
,qry.period_hdc               HRI_P_MEASURE1
,qry.period_hdc_emp           HRI_P_MEASURE2
,'''|| l_drill_url2 ||'''     HRI_P_DRILL_URL2
,qry.period_hdc_cwk           HRI_P_MEASURE3
,'''|| l_drill_url3 ||'''     HRI_P_DRILL_URL3
,DECODE(qry.period_hdc, 0, 0,
        (qry.period_hdc_emp/qry.period_hdc)*100)
                              HRI_P_MEASURE2_MP
,DECODE(qry.period_hdc, 0, 0,
        (qry.period_hdc_cwk/qry.period_hdc)*100)
                              HRI_P_MEASURE3_MP
,to_char(qry.period_as_of_date  ,''DD/MM/YYYY'')
                              HRI_P_CHAR1_GA
FROM
 (' || l_trend_sql || ') qry
WHERE 1=1
'||l_security_clause||'
ORDER BY qry.period_order ASC ';

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

END GET_SQL2;

END HRI_OLTP_PMV_WMV_WF_SUP_GRAPH;

/
