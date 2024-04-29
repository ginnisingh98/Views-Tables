--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_TRN_BCKT_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_TRN_BCKT_GRAPH" AS
/* $Header: hrioptbg.pkb 120.1 2005/10/26 07:56:40 jrstewar noship $ */

g_rtn   VARCHAR2(30) := '
';

PROCEDURE get_sql_bckt_perf
       (p_page_parameter_tbl  IN  BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql          OUT NOCOPY VARCHAR2,
        x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_custom_rec         BIS_QUERY_ATTRIBUTES;
  l_security_clause    VARCHAR2(4000);
  l_SQLText            VARCHAR2(4000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Pre-calculations */
  l_trend_table        VARCHAR2(4000);
  l_projection_periods NUMBER;
  l_previous_periods   NUMBER;

/* Dynamic SQL Controls */
  l_trend_sql_params   hri_oltp_pmv_query_trend.trend_sql_params_type;
  l_trend_sql          VARCHAR2(10000);

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

/* Get the number of periods to display */
  hri_oltp_pmv_query_time.get_period_binds
   (p_page_period_type => l_parameter_rec.page_period_type
   ,p_page_comp_type => l_parameter_rec.time_comparison_type
   ,o_previous_periods => l_previous_periods
   ,o_projection_periods => l_projection_periods);

/* Get the trend sql */
  l_trend_sql_params.bind_format  := 'PMV';
  l_trend_sql_params.include_sep  := 'Y';
  l_trend_sql_params.bucket_dim   := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  l_trend_sql := hri_oltp_pmv_query_trend.get_sql
                  (p_parameter_rec => l_parameter_rec,
                   p_bind_tab => l_bind_tab,
                   p_trend_sql_params => l_trend_sql_params,
                   p_calling_module => 'HRI_OLTP_PMV_TRN_BCKT_GRAPH.GET_SQL_BCKT_PERF');

l_SQLText :=
'SELECT -- Turnover with Performance Band Trend
 qry.period_as_of_date  VIEWBYID
,qry.period_as_of_date  VIEWBY
,qry.period_order       HRI_P_ORDER_BY_1
,DECODE(qry.period_sep_hdc, 0, 0,
        (qry.period_sep_hdc_b3/qry.period_sep_hdc)*100)
                        HRI_P_MEASURE1
,DECODE(qry.period_sep_hdc, 0, 0,
        (qry.period_sep_hdc_b2/qry.period_sep_hdc)*100)
                        HRI_P_MEASURE2
,DECODE(qry.period_sep_hdc, 0, 0,
        (qry.period_sep_hdc_b1/qry.period_sep_hdc)*100)
                        HRI_P_MEASURE3
,DECODE(qry.period_sep_hdc, 0, 0,
        (qry.period_sep_hdc_na/qry.period_sep_hdc)*100)
                        HRI_P_MEASURE4
,to_char(qry.period_as_of_date, ''DD/MM/YYYY'')
                        HRI_P_CHAR1_GA
FROM
 (' || l_trend_sql || ')  qry
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

END get_sql_bckt_perf;

PROCEDURE get_sql_rnk_jfn_graph
     (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
      x_custom_sql          OUT NOCOPY VARCHAR2,
      x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText               VARCHAR2(32767) ;
  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_security_clause           VARCHAR2(4000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Drill URLs */
  l_drill_url1           VARCHAR2(1000);

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

/* Setup any drill url[s] */
  l_drill_url1 := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_TRN_BCKT_GRAPH.GET_SQL_RNK_JFN_GRAPH');

/* Return AK Sql To PMV */
 l_SQLText    :=
'SELECT -- Terminations by Job Function (Top 5)
 qry.vby_id                 VIEWBYID
,DECODE(qry.grp_id,
          ''NA_OTHERS'', ''' || hri_oltp_view_message.get_others_msg || ''',
        cl.value)           VIEWBY
,qry.curr_separation_hdc   HRI_P_MEASURE1
,DECODE(qry.grp_id, ''NA_OTHERS'', '''', ''' || l_drill_url1 || ''')
                            HRI_P_DRILL_URL1
,qry.comp_separation_hdc   HRI_P_MEASURE2
,DECODE(qry.comp_separation_hdc, 0, NULL,
        100 * (qry.curr_separation_hdc - qry.comp_separation_hdc) /
         qry.comp_separation_hdc)
                            HRI_P_MEASURE1_MP
FROM
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || ' cl
,(SELECT' || g_rtn ||
/* Bug 4068969 - added grp_id and corrected logic for vby_id and order_by */
'   DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, :HRI_NO_SEGMENTS_TO_SHOW + 1,
          rnk)         order_by
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, ''NA_EDW'',
          rnked_metrics.vby_id)   vby_id
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, ''NA_OTHERS'',
          rnked_metrics.vby_id)   grp_id
  ,SUM(rnked_metrics.curr_separation_hdc)  curr_separation_hdc
  ,SUM(rnked_metrics.comp_separation_hdc)  comp_separation_hdc
  FROM
   (SELECT
     cube.vby_id
    ,cube.curr_separation_hdc
    ,cube.comp_separation_hdc' || g_rtn ||
/* Bug 3068969 - Order by descending terminations (curr and prev) to prevent */
/* outermost filter removing ranked lines and still displaying OTHERS */
'    ,RANK() OVER (ORDER BY cube.curr_separation_hdc  DESC NULLS LAST,
                           cube.comp_separation_hdc  DESC NULLS LAST,
                           cube.vby_id) AS RNK
    FROM
     (' || l_wcnt_chg_fact_sql || ') cube
   ) rnked_metrics
  GROUP BY
   DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, :HRI_NO_SEGMENTS_TO_SHOW + 1,
          rnk)
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, ''NA_EDW'',
          rnked_metrics.vby_id)
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnk),
            -1, ''NA_OTHERS'',
          rnked_metrics.vby_id)
 ) qry
WHERE qry.vby_id = cl.id
AND (qry.curr_separation_hdc + qry.comp_separation_hdc) > 0 ' || g_rtn
|| l_security_clause || g_rtn
|| 'ORDER BY qry.order_by';

 x_custom_sql := l_SQLText;

/* Binds Will be inserted Below */

  l_custom_rec.attribute_name := ':HRI_NO_SEGMENTS_TO_SHOW';
  l_custom_rec.attribute_value := 5;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END get_sql_rnk_jfn_graph;

PROCEDURE get_sql_rnk_rsn_graph
       (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql          OUT NOCOPY VARCHAR2,
        x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText              VARCHAR2(32767) ;
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

  l_security_clause      VARCHAR2(4000);

  l_drill_url1           VARCHAR2(1000);

/* Dynamic SQL Controls */
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

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

/* Hard code voluntary separations only */
  l_bind_tab('HRI_WRKACTVT+HRI_WAC_SEPCAT_X').pmv_bind_string := '''SEP_VOL''';
  l_bind_tab('HRI_WRKACTVT+HRI_WAC_SEPCAT_X').sql_bind_string := '''SEP_VOL''';

/* Setup any drill url[s] */
  l_drill_url1 := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                   'VIEW_BY_NAME=VIEW_BY_ID&' ||
                   'HRI_P_WAC_SEPCAT_CN=SEP_VOL&' ||
                   'pParamIds=Y';

/* Set view by to leaving reason */
  l_parameter_rec.view_by := 'HRI_REASON+HRI_RSN_SEP_X';

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.bucket_dim := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_TRN_BCKT_GRAPH.GET_SQL_RNK_RSN_GRAPH');

/* Return AK Sql To PMV */
 l_SQLText    :=
'SELECT
 -- Terminations by Leaving Reason (Top 5)
 qry.vby_id                VIEWBYID
,DECODE(qry.grp_id,
          ''NA_OTHERS'', ''' || hri_oltp_view_message.get_others_msg || ''',
        cl.value)           VIEWBY
,qry.curr_separation_hdc    HRI_P_MEASURE1
,DECODE(qry.grp_id, ''NA_OTHERS'', '''', ''' || l_drill_url1 ||''')
                            HRI_P_DRILL_URL1
,qry.comp_separation_hdc    HRI_P_MEASURE2
,DECODE(qry.curr_separation_hdc, 0, NULL,
        ((qry.curr_separation_hdc - qry.comp_separation_hdc) /
         qry.curr_separation_hdc) * 100)
                            HRI_P_MEASURE1_MP
FROM
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
       (l_parameter_rec.view_by).viewby_table || '  cl
,(SELECT' || g_rtn ||
/* Bug 4068969 - added grp_id and corrected logic for vby_id and order_by */
'   DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, :HRI_NO_SEGMENTS_TO_SHOW + 1,
          rnk)                              order_by
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, ''NA_EDW'',
          rnked_metrics.vby_id)             vby_id
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, ''NA_OTHERS'',
          rnked_metrics.vby_id)             grp_id
  ,SUM(rnked_metrics.curr_separation_hdc)  curr_separation_hdc
  ,SUM(rnked_metrics.comp_separation_hdc)  comp_separation_hdc
  FROM
   (SELECT
     cube.vby_id
    ,cube.curr_separation_hdc
    ,cube.comp_separation_hdc' || g_rtn ||
/* Bug 3068969 - Order by descending terminations (curr and prev) to prevent */
/* outermost filter removing ranked lines and still displaying OTHERS */
'    ,RANK() OVER (ORDER BY cube.curr_separation_hdc  DESC NULLS LAST,
                           cube.comp_separation_hdc  DESC NULLS LAST,
                           cube.vby_id) AS RNK
    FROM
     (' || l_wcnt_chg_fact_sql || ')  cube
   ) RNKED_METRICS
  GROUP BY
   DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, :HRI_NO_SEGMENTS_TO_SHOW + 1,
          rnk)
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, ''NA_EDW'',
          rnked_metrics.vby_id)
  ,DECODE(SIGN(:HRI_NO_SEGMENTS_TO_SHOW - rnked_metrics.rnk),
            -1, ''NA_OTHERS'',
          rnked_metrics.vby_id)
 ) QRY
WHERE qry.vby_id = cl.id
AND (qry.curr_separation_hdc + qry.comp_separation_hdc) > 0' || g_rtn
|| l_security_clause || g_rtn ||
'ORDER BY qry.order_by';

  x_custom_sql := l_SQLText;

/* Binds Will be inserted Below */

  l_custom_rec.attribute_name := ':HRI_NO_SEGMENTS_TO_SHOW';
  l_custom_rec.attribute_value := 5;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;


END get_sql_rnk_rsn_graph;

END hri_oltp_pmv_trn_bckt_graph;

/
