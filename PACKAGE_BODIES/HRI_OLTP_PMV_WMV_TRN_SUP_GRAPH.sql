--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_TRN_SUP_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_TRN_SUP_GRAPH" AS
/* $Header: hriopwtg.pkb 120.0 2005/05/29 07:39:42 appldev noship $ */

PROCEDURE GET_SQL2(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql       OUT NOCOPY VARCHAR2,
                    x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_custom_rec         BIS_QUERY_ATTRIBUTES;
  l_security_clause    VARCHAR2(4000);
  l_SQLText            VARCHAR2(10000) ;

/* Parameter values */
  l_parameter_rec       hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL */
  l_trend_sql_params    hri_oltp_pmv_query_trend.TREND_SQL_PARAMS_TYPE;
  l_trend_sql           VARCHAR2(10000);

/* Pre-calculations */
  l_anl_factor          NUMBER;
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;

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

/* Get annualization factor */
  l_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                   (p_period_type => l_parameter_rec.page_period_type);

/* Get number of periods to show */
  hri_oltp_pmv_query_time.get_period_binds
   (p_page_period_type   => l_parameter_rec.page_period_type
   ,p_page_comp_type     => l_parameter_rec.time_comparison_type
   ,o_previous_periods   => l_previous_periods
   ,o_projection_periods => l_projection_periods);

/* Set the parameters for getting the inner SQL */
  l_trend_sql_params.bind_format := 'PMV';
  l_trend_sql_params.include_hdc := 'Y';
  l_trend_sql_params.include_sep_inv := 'Y';
  l_trend_sql_params.include_sep_vol := 'Y';

/* Get the inner SQL */
  l_trend_sql :=  hri_oltp_pmv_query_trend.get_sql
    (p_parameter_rec    => l_parameter_rec,
     p_bind_tab         => l_bind_tab,
     p_trend_sql_params => l_trend_sql_params,
     p_calling_module   => 'HRI_OLTP_PMV_WMV_TRN_SUP_GRAPH.GET_SQL2');

l_SQLText := ' -- Annualized Turnover Trend
SELECT
 qry.period_as_of_date      VIEWBYID
,qry.period_as_of_date      VIEWBY
,qry.period_order           HRI_P_ORDER_BY_1
,qry.period_as_of_date      HRI_P_GRAPH_X_LABEL_TIME
,DECODE(qry.period_sep_vol_hdc,
          0, 0,
        ((qry.period_sep_vol_hdc * :ANL_FACTOR /
         DECODE(qry.period_hdc_trn,
                  0, (qry.period_sep_vol_hdc + qry.period_sep_invol_hdc),
                qry.period_hdc_trn)) * 100))
                            HRI_P_WMV_TRN_SEP_VOL_ANL_MV
,DECODE(qry.period_sep_invol_hdc,
          0, 0,
        ((qry.period_sep_invol_hdc * :ANL_FACTOR /
         DECODE(qry.period_hdc_trn,
                  0, (qry.period_sep_vol_hdc + qry.period_sep_invol_hdc),
                qry.period_hdc_trn)) * 100))
                            HRI_P_WMV_TRN_SEP_INV_ANL_MV
,DECODE(qry.period_sep_vol_hdc + qry.period_sep_invol_hdc,
          0, 0,
        (((qry.period_sep_vol_hdc + qry.period_sep_invol_hdc) * :ANL_FACTOR /
          DECODE(qry.period_hdc_trn,
                   0, (qry.period_sep_vol_hdc + qry.period_sep_invol_hdc),
                 qry.period_hdc_trn)) * 100))
                            HRI_P_WMV_TRN_ANL_SUM_MV
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')
                            HRI_P_CHAR1_GA
FROM
 ('|| l_trend_sql || ')  qry
WHERE 1 = 1
' || l_security_clause || '
ORDER BY qry.period_order ASC';

  x_custom_sql := l_sqltext;

  l_custom_rec.attribute_name      := ':TIME_PERIOD_TYPE';
  l_custom_rec.attribute_value     := l_parameter_rec.page_period_type;
  l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1)               := l_custom_rec;

  l_custom_rec.attribute_name      := ':TIME_COMPARISON_TYPE';
  l_custom_rec.attribute_value     := l_parameter_rec.time_comparison_type;
  l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2)               := l_custom_rec;

  l_custom_rec.attribute_name      := ':TIME_PERIOD_NUMBER';
  l_custom_rec.attribute_value     := l_previous_periods;
  l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3)               := l_custom_rec;

  l_custom_rec.attribute_name      := ':ANL_FACTOR';
  l_custom_rec.attribute_value     := l_anl_factor;
  l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4)               := l_custom_rec;

END GET_SQL2 ;

END HRI_OLTP_PMV_WMV_TRN_SUP_GRAPH;

/
