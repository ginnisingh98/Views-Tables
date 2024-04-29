--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_C_EXTN_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_C_EXTN_GRAPH" AS
/* $Header: hriopcetg.pkb 120.1 2005/07/19 03:47 cbridge noship $ */

  g_rtn                VARCHAR2(30) := '
';


PROCEDURE GET_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql       OUT NOCOPY VARCHAR2,
                    x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_security_clause     VARCHAR2(4000);
  l_SQLText             VARCHAR2(32000);
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
  l_trend_sql_params.include_pasg_cnt := 'Y';
  l_trend_sql_params.include_pasg_pow := 'Y';
  l_trend_sql_params.include_extn_cnt := 'Y';
  l_trend_sql_params.include_extn_pow := 'Y';

  l_trend_sql :=  hri_oltp_pmv_query_trend.get_sql
                   (p_parameter_rec    => l_parameter_rec,
	                p_bind_tab         => l_bind_tab,
                    p_trend_sql_params => l_trend_sql_params,
                    p_calling_module   => 'HRI_OLTP_PMV_WMV_C_EXTN_GRAPH.get_sql');

l_sqltext :=
-- l_parameter_rec.debug_header || g_rtn ||
'SELECT -- Contingent Worker Placement (with Extension) Trend
 qry.period_as_of_date        VIEWBYID
,qry.period_as_of_date        VIEWBY
,qry.period_order             HRI_P_ORDER_BY_1
,qry.period_as_of_date        HRI_P_GRAPH_X_LABEL_TIME
,DECODE(qry.period_pasg_cnt
          ,0,0
          ,((qry.period_pasg_pow - qry.period_extn_pow)
            /(qry.period_pasg_cnt*:MONTHS_MULTIPLIER))
        )                     HRI_P_MEASURE1
,DECODE(qry.period_pasg_cnt
          ,0,0
          ,((qry.period_extn_pow)/(period_pasg_cnt*:MONTHS_MULTIPLIER))
        )                     HRI_P_MEASURE2
,DECODE(qry.period_pasg_cnt
          ,0,0
          ,((qry.period_pasg_pow)/(period_pasg_cnt*:MONTHS_MULTIPLIER))
        )                     HRI_P_MEASURE3
,qry.period_pasg_cnt      HRI_P_MEASURE4
,((qry.period_pasg_pow)/:MONTHS_MULTIPLIER)
                              HRI_P_MEASURE5
,qry.period_extn_cnt      HRI_P_MEASURE6
,((qry.period_extn_pow)/:MONTHS_MULTIPLIER)
                              HRI_P_MEASURE7
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

  l_custom_rec.attribute_name := ':MONTHS_MULTIPLIER';
  l_custom_rec.attribute_value := 30.42;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;


END GET_SQL;

END HRI_OLTP_PMV_WMV_C_EXTN_GRAPH;

/