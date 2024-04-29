--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_ABS_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_ABS_CAT" AS
/* $Header: hriopabsct.pkb 120.3 2005/10/26 07:55 jrstewar noship $ */

g_rtn                VARCHAR2(30) := '
';

g_unassigned         VARCHAR2(50) := HRI_OLTP_VIEW_MESSAGE.get_unassigned_msg;

PROCEDURE get_sql_abscat_t4
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
  l_period_abs_drtn_metric3 VARCHAR2(1000);
  l_period_abs_drtn_metric4 VARCHAR2(1000);

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

/* Get the top 4 Absence Categories for selection Mgr on effective date */
  hri_oltp_pmv_rank_abs.set_top_categories
   (p_supervisor_id  => l_parameter_rec.peo_supervisor_id,
    p_effective_from_date => l_parameter_rec.time_curr_start_date,
    p_effective_to_date => l_parameter_rec.time_curr_end_date,
    p_no_categories  => 4,
    p_category_tab   => l_abs_category_tab);

/* Set the trend sql context for the code centralization call */
  l_trend_sql_params.bind_format := 'PMV';

/* Set metric base on absence UOM parameter, default to DAYS */
  IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
      l_trend_sql_params.include_abs_drtn_days   := 'Y';

      l_period_abs_drtn_metric1 := 'qry.period_abs_drtn_days_absCat1';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_days_absCat2';
      l_period_abs_drtn_metric3 := 'qry.period_abs_drtn_days_absCat3';
      l_period_abs_drtn_metric4 := 'qry.period_abs_drtn_days_absCat4';

  ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
      l_trend_sql_params.include_abs_drtn_hrs   := 'Y';
      l_period_abs_drtn_metric1 := 'qry.period_abs_drtn_hrs_absCat1';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_hrs_absCat2';
      l_period_abs_drtn_metric3 := 'qry.period_abs_drtn_hrs_absCat3';
      l_period_abs_drtn_metric4 := 'qry.period_abs_drtn_hrs_absCat4';
  ELSE
      l_trend_sql_params.include_abs_drtn_days   := 'Y';
      l_period_abs_drtn_metric1 := 'qry.period_abs_drtn_days_absCat1';
      l_period_abs_drtn_metric2 := 'qry.period_abs_drtn_days_absCat2';
      l_period_abs_drtn_metric3 := 'qry.period_abs_drtn_days_absCat3';
      l_period_abs_drtn_metric4 := 'qry.period_abs_drtn_days_absCat4';

  END IF;

/* Set to bucket for Absence Category */
  l_trend_sql_params.bucket_dim := 'HRI_ABSNC+HRI_ABSNC_CAT';

/* Call the UI fact code centralization for the Trend */
  l_trend_sql := hri_oltp_pmv_query_trend.get_sql
                  (p_parameter_rec    => l_parameter_rec,
                   p_bind_tab         => l_bind_tab,
                   p_trend_sql_params => l_trend_sql_params,
                   p_calling_module   => 'HRI_OLTP_PMV_ABS_CAT.GET_SQL_ABSCAT_T4');

/* set the dynamic drill urls
   Commented out, as this is not requested in the functional spec.

l_drill_url1 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   'HRI_ABSNC+HRI_ABSNC_CAT='|| hri_oltp_pmv_rank_abs.get_category_code(1)||'&'||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR2_GA&' ||
                   'pParamIds=Y';
l_drill_url2 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   'HRI_ABSNC+HRI_ABSNC_CAT='|| hri_oltp_pmv_rank_abs.get_category_code(2)||'&'||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR2_GA&' ||
                   'pParamIds=Y';
l_drill_url3 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   'HRI_ABSNC+HRI_ABSNC_CAT='|| hri_oltp_pmv_rank_abs.get_category_code(3)||'&'||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR2_GA&' ||
                   'pParamIds=Y';
l_drill_url4 :=
    'pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                   'VIEW_BY=VIEW_BY_NAME&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   'HRI_ABSNC+HRI_ABSNC_CAT='|| hri_oltp_pmv_rank_abs.get_category_code(4)||'&'||
                   ''' || ''' || 'AS_OF_DATE=HRI_P_CHAR2_GA&' ||
                   'pParamIds=Y';
*/

/* Formulate the PMV final query output for the UI*/
l_sqltext :=
'SELECT -- Employee Absence Top 4 Categories Trend
 qry.period_as_of_date     VIEWBYID
,qry.period_as_of_date     VIEWBY
,qry.period_order          HRI_P_ORDER_BY_1
,'||l_period_abs_drtn_metric1 ||'   HRI_P_MEASURE1
,''' || l_drill_url1 || '''         HRI_P_DRILL_URL1
,'||l_period_abs_drtn_metric2 ||'   HRI_P_MEASURE2
,''' || l_drill_url2 || '''         HRI_P_DRILL_URL2
,'||l_period_abs_drtn_metric3 ||'   HRI_P_MEASURE3
,''' || l_drill_url3 || '''         HRI_P_DRILL_URL3
,'||l_period_abs_drtn_metric4 ||'   HRI_P_MEASURE4
,''' || l_drill_url4 || '''         HRI_P_DRILL_URL4
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')   HRI_P_CHAR2_GA
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

  l_custom_rec.attribute_name := ':ABS_CATEGORY_CODE1';
  l_custom_rec.attribute_value := l_abs_category_tab(1);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ABS_CATEGORY_CODE2';
  l_custom_rec.attribute_value := l_abs_category_tab(2);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':ABS_CATEGORY_CODE3';
  l_custom_rec.attribute_value := l_abs_category_tab(3);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ABS_CATEGORY_CODE4';
  l_custom_rec.attribute_value := l_abs_category_tab(4);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;


END get_sql_abscat_t4 ;

PROCEDURE 	GET_SQL_TN(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                 ,x_custom_sql  OUT NOCOPY VARCHAR2
                 ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
       IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_abs_fact_params       hri_bpl_fact_abs_sql.abs_fact_param_type;
  l_abs_fact_sql          VARCHAR2(10000);
  l_parameter_name        VARCHAR2(100);
  l_dynmc_drtn_curr       VARCHAR2(100) DEFAULT 'curr_abs_drtn_days';
  l_dynmc_tot_drtn_curr   VARCHAR2(100) DEFAULT 'tot_abs_drtn_days_curr';
  l_drill_abs_detail      VARCHAR2(1000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header          VARCHAR(550);

BEGIN
/* Initialize out parameters */
  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Drill URL's for Manager and Direct Reports */
  l_drill_abs_detail :='pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                     'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'pParamIds=Y';

/* Set order by */
  l_parameter_rec.order_by :=  hri_oltp_pmv_util_pkg.set_default_order_by
                                (p_order_by_clause => l_parameter_rec.order_by);

  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure paramter selection  Default Days                */

     IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
      ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_hrs';
        l_abs_fact_params.include_abs_drtn_hrs  := 'Y';
      ELSE -- functional decision (JC) default to days
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
      END IF;

/* Get SQL for workforce fact */
  l_abs_fact_params.bind_format := 'PMV';
  l_abs_fact_params.include_abs_in_period := 'N';
  l_abs_fact_params.include_abs_ntfctn_period := 'N';
  l_abs_fact_params.include_comp := 'N';
  l_abs_fact_params.kpi_mode := 'N';
  l_abs_fact_sql := hri_bpl_fact_abs_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_abs_params     => l_abs_fact_params,
    p_calling_module => 'HRI_P_ABS_CAT_TN_GRAPH');

l_SQLText :=
    ' -- Employee Absence by Category Graph Pie
SELECT
 babs.vby_id											VIEWBYID
,babs.value												VIEWBY'|| g_rtn
/* Absence  */ || g_rtn ||'
,NVL(babs.curr_abs_drtn,to_number(NULL))                HRI_P_MEASURE1 '|| g_rtn
/* Total Absence  */ || g_rtn ||'
,NVL(babs.curr_tot_abs_drtn,to_number(NULL))   		    HRI_P_GRAND_TOTAL1'|| g_rtn
/* Drill URLs */ || g_rtn ||'
,'''|| l_drill_abs_detail ||'''	                        HRI_P_DRILL_URL1
FROM
(
SELECT
/* Base Measures */
 vby.id                   				          vby_id
,vby.value                                        value
,vby.order_by                                     order_by
,NVL(afact.'|| l_dynmc_drtn_curr ||',0)           curr_abs_drtn
,SUM(afact.'|| l_dynmc_drtn_curr ||') OVER()      curr_tot_abs_drtn

FROM
 hri_cl_absnc_cat_v  vby
,('|| l_abs_fact_sql ||') afact
WHERE
   vby.id = afact.vby_id
 ' || l_security_clause || ') babs' || g_rtn ||
'&ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText ;

END GET_SQL_TN ;


END HRI_OLTP_PMV_ABS_CAT ;

/
