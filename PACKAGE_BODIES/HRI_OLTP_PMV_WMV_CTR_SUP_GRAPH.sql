--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_CTR_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_CTR_SUP_GRAPH" AS
/* $Header: hriopwcg.pkb 120.0 2005/05/29 07:37:57 appldev noship $ */
--
  g_rtn                 VARCHAR2(30) := '
';
--
PROCEDURE get_sql2
    (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql         OUT NOCOPY VARCHAR2,
     x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_custom_rec          BIS_QUERY_ATTRIBUTES;
  l_sqltext             VARCHAR2(10000) ;
  l_security_clause     VARCHAR2(500);
  l_trend_sql             VARCHAR2(32000);

/* Parameter values */
  l_parameter_rec      hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_country_tab         hri_oltp_pmv_rank_ctr.country_tab_type;

/* Pre-calculations */
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;
  l_trend_sql_params    hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE;
--
BEGIN
--
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

/* Populate global table with top 4 country names and codes */
  hri_oltp_pmv_rank_ctr.set_top_countries
   (p_supervisor_id  => l_parameter_rec.peo_supervisor_id,
    p_effective_date => l_parameter_rec.time_curr_end_date,
    p_no_countries   => 4,
    p_country_tab    => l_country_tab);

-- Get FII offset table for alias in main query
  hri_oltp_pmv_query_time.get_period_binds
   (p_page_period_type   => l_parameter_rec.page_period_type
   ,p_page_comp_type     => l_parameter_rec.time_comparison_type
   ,o_previous_periods   => l_previous_periods
   ,o_projection_periods => l_projection_periods);
--
  --
  -- Set the parameters for getting the inner SQL
  --
  l_trend_sql_params.bucket_dim  := 'GEOGRAPHY+COUNTRY';
  l_trend_sql_params.bind_format := 'PMV';
  l_trend_sql_params.include_hdc := 'Y';
  --
  -- Get the inner SQL
  --
  l_trend_sql :=  hri_oltp_pmv_query_trend.get_sql
                 (p_parameter_rec     => l_parameter_rec,
                  p_bind_tab          => l_bind_tab,
                  p_trend_sql_params  => l_trend_sql_params,
                  p_calling_module    => 'HRI_OLTP_PMV_WMV_CTR_SUP_GRAPH.GET_SQL2');

  l_sqltext :=
'SELECT -- Headcount by Country Trend
 qry.period_as_of_date     VIEWBYID
,qry.period_as_of_date     VIEWBY
,qry.period_order          HRI_P_ORDER_BY_1
,qry. period_as_of_date    HRI_P_GRAPH_X_LABEL_TIME
,qry.period_hdc_ctr1       HRI_P_MEASURE1
,qry.period_hdc_ctr2       HRI_P_MEASURE2
,qry.period_hdc_ctr3       HRI_P_MEASURE3
,qry.period_hdc_ctr4       HRI_P_MEASURE4
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')
                           HRI_P_CHAR1_GA
FROM
 (' || l_trend_sql || ') qry
WHERE 1=1
' || l_security_clause || '
ORDER BY qry.period_order';

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

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE1';
  l_custom_rec.attribute_value := l_country_tab(1);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE2';
  l_custom_rec.attribute_value := l_country_tab(2);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE3';
  l_custom_rec.attribute_value := l_country_tab(3);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE4';
  l_custom_rec.attribute_value := l_country_tab(4);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;
END get_sql2;

PROCEDURE get_avg_sal_sql
    (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql         OUT NOCOPY VARCHAR2,
     x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_custom_rec         BIS_QUERY_ATTRIBUTES;
  l_sqltext             VARCHAR2(10000) ;
  l_security_clause     VARCHAR2(500);
  l_trend_sql             VARCHAR2(32000);
  l_trend_sql_params    hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_country_tab         hri_oltp_pmv_rank_ctr.country_tab_type;

/* Pre-calculations */
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;

--
BEGIN
--
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

/* Populate global table with top 4 country names and codes */
  hri_oltp_pmv_rank_ctr.set_top_countries
   (p_supervisor_id => l_parameter_rec.peo_supervisor_id,
    p_effective_date => l_parameter_rec.time_curr_end_date,
    p_no_countries => 4,
    p_country_tab => l_country_tab);

-- Get number of periods to display
  hri_oltp_pmv_query_time.get_period_binds
   (p_page_period_type   => l_parameter_rec.page_period_type
   ,p_page_comp_type     => l_parameter_rec.time_comparison_type
   ,o_previous_periods   => l_previous_periods
   ,o_projection_periods => l_projection_periods);

   l_trend_sql_params.bucket_dim  := 'GEOGRAPHY+COUNTRY';
   l_trend_sql_params.bind_format := 'PMV';
   l_trend_sql_params.include_hdc := 'Y';
   l_trend_sql_params.include_sal := 'Y';
  --
  -- Get the inner SQL
  --
  l_trend_sql :=  hri_oltp_pmv_query_trend.get_sql
                (p_parameter_rec    => l_parameter_rec,
                 p_bind_tab         => l_bind_tab,
                 p_trend_sql_params => l_trend_sql_params,
                 p_calling_module   => 'HRI_OLTP_PMV_WMV_CTR_SUP_GRAPH.GET_AVG_SAL_SQL');

--
  l_sqltext :=
'SELECT -- Average Salary (top 4 countries) Trend
 qry.period_as_of_date     VIEWBYID
,qry.period_as_of_date     VIEWBY
,qry.period_order          HRI_P_ORDER_BY_1
,DECODE(qry.period_hdc_ctr1,
  0, to_number(null),
 qry.period_sal_ctr1/qry.period_hdc_ctr1)
                       HRI_P_MEASURE1
,DECODE(qry.period_hdc_ctr2,
  0, to_number(null),
 qry.period_sal_ctr2/qry.period_hdc_ctr2)
                       HRI_P_MEASURE2
,DECODE(qry.period_hdc_ctr3,
  0, to_number(null),
 qry.period_sal_ctr3/qry.period_hdc_ctr3)
                       HRI_P_MEASURE3
,DECODE(qry.period_hdc_ctr4,
  0, to_number(null),
 qry.period_sal_ctr4/qry.period_hdc_ctr4)
                       HRI_P_MEASURE4
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')
                       HRI_P_CHAR1_GA
FROM
 (' || l_trend_sql || ') qry
WHERE 1=1
' || l_security_clause || '
ORDER BY qry.period_order';

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

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE1';
  l_custom_rec.attribute_value := l_country_tab(1);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE2';
  l_custom_rec.attribute_value := l_country_tab(2);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE3';
  l_custom_rec.attribute_value := l_country_tab(3);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':GEO_COUNTRY_CODE4';
  l_custom_rec.attribute_value := l_country_tab(4);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

END get_avg_sal_sql;

END HRI_OLTP_PMV_WMV_CTR_SUP_GRAPH;
--

/
