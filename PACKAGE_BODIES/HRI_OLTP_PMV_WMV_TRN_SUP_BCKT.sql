--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_TRN_SUP_BCKT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_TRN_SUP_BCKT" AS
/* $Header: hrioptrp.pkb 120.3 2005/10/26 07:54:05 jrstewar noship $ */

  g_rtn     VARCHAR2(5) := '
';

/* function to return the sk_fk of the dimension view for the given bucket number */
FUNCTION convert_low_bckt_to_sk_fk (p_bucket_dim        IN VARCHAR2
                                   ,p_bucket_column_id  IN NUMBER -- [1 .. 5]
                                   ,p_wkth_wktyp_sk_fk  IN VARCHAR2 -- ['EMP','CWK']
                                   ) RETURN NUMBER
IS
CURSOR cur_conv_bckt IS
SELECT pow_band_sk_pk
FROM hri_cs_pow_band_ct pow
WHERE pow.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk
AND  pow.band_sequence =p_bucket_column_id;

l_pow_band_sk_pk NUMBER := -1;

BEGIN

    OPEN cur_conv_bckt;
    FETCH cur_conv_bckt INTO l_pow_band_sk_pk;
    CLOSE cur_conv_bckt;

    RETURN l_pow_band_sk_pk;

EXCEPTION WHEN OTHERS THEN
    CLOSE cur_conv_bckt;
    RETURN l_pow_band_sk_pk;

END convert_low_bckt_to_sk_fk;

PROCEDURE get_sql_bkct_perf
  (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql          OUT NOCOPY VARCHAR2,
   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


  l_SQLText               VARCHAR2(32767) ;
  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_security_clause       VARCHAR2(4000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* drill urls */
  l_drill_url1              VARCHAR2(1000);
  l_drill_url2              VARCHAR2(1000);
  l_drill_url3              VARCHAR2(1000);
  l_drill_url5              VARCHAR2(1000);
  l_drill_url6              VARCHAR2(1000);

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Dynamic strings */
  l_direct_reports_string   VARCHAR2(1000);
  l_display_row_condition   VARCHAR2(1000);
  l_view_by_filter            VARCHAR2(1000);
  l_wmv_outer_join          VARCHAR2(30);

/* Grand totals for terminations */
  l_curr_term_hdc          NUMBER;
  l_curr_term_hdc_b1       NUMBER;
  l_curr_term_hdc_b2       NUMBER;
  l_curr_term_hdc_b3       NUMBER;
  l_curr_term_hdc_na       NUMBER;
  l_comp_term_hdc          NUMBER;
  l_comp_term_hdc_b1       NUMBER;
  l_comp_term_hdc_b2       NUMBER;
  l_comp_term_hdc_b3       NUMBER;
  l_comp_term_hdc_na       NUMBER;

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

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Swap the viewby column for the default sort order */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
   (p_order_by_clause => l_parameter_rec.order_by);

/* Get termination grand totals */
  hri_bpl_dbi_calc_period.calc_sup_term_perf_pvt
        (p_supervisor_id => l_parameter_rec.peo_supervisor_id,
         p_from_date     => l_parameter_rec.time_curr_start_date,
         p_to_date       => l_parameter_rec.time_curr_end_date,
         p_bind_tab      => l_bind_tab,
         p_total_term    => l_curr_term_hdc,
         p_total_term_b1 => l_curr_term_hdc_b1,
         p_total_term_b2 => l_curr_term_hdc_b2,
         p_total_term_b3 => l_curr_term_hdc_b3,
         p_total_term_na => l_curr_term_hdc_na);

  hri_bpl_dbi_calc_period.calc_sup_term_perf_pvt
        (p_supervisor_id => l_parameter_rec.peo_supervisor_id,
         p_from_date     => l_parameter_rec.time_comp_start_date,
         p_to_date       => l_parameter_rec.time_comp_end_date,
         p_bind_tab      => l_bind_tab,
         p_total_term    => l_comp_term_hdc,
         p_total_term_b1 => l_comp_term_hdc_b1,
         p_total_term_b2 => l_comp_term_hdc_b2,
         p_total_term_b3 => l_comp_term_hdc_b3,
         p_total_term_na => l_comp_term_hdc_na);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_TRN_SUP_BCKT.GET_SQL_BKCT_PERF');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.bucket_dim := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_SUP_BCKT.GET_SQL_BKCT_PERF');

/* Set the display row conditions */
  IF (l_parameter_rec.view_by = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
      l_parameter_rec.view_by = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' OR
      l_parameter_rec.view_by = 'HRI_LOW+HRI_LOW_BAND_X') THEN
  /* Outer join to facts, display all rows */
    l_wmv_outer_join := ' (+)';
  /* Set the view by filter */
    l_view_by_filter := hri_oltp_pmv_util_pkg.set_viewby_filter
            (p_parameter_rec => l_parameter_rec,
             p_bind_tab => l_bind_tab,
             p_view_by_alias => 'cl');
  ELSE
  /* Only display directs row or rows with activity */
    l_display_row_condition :=
' AND (qry.curr_hdc > 0
 OR qry.curr_termination_hdc > 0
 OR qry.direct_ind = 1)' || g_rtn;
  END IF;

 /* bug 4202907 append cl start AND end_date filter if viewby manager */
 IF (l_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    l_view_by_filter := l_view_by_filter ||
        'AND &BIS_CURRENT_ASOF_DATE BETWEEN cl.start_date AND cl.end_date';
 END IF;

/* Setup any drill url[s] */
  l_drill_url1 :=
  'DECODE(qry.direct_ind
    ,1 ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
         'VIEW_BY_NAME=VIEW_BY_ID&' ||
         'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=1&' ||
         'HRI_P_SUPH_RO_CA=N&' ||
         'pParamIds=Y''
    ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
      'VIEW_BY_NAME=VIEW_BY_ID&' ||
      'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=1&' ||
      'pParamIds=Y'')';

  l_drill_url2 :=
  'DECODE(qry.direct_ind
    ,1 ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
         'VIEW_BY_NAME=VIEW_BY_ID&' ||
         'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=2&' ||
         'HRI_P_SUPH_RO_CA=N&' ||
         'pParamIds=Y''
    ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
      'VIEW_BY_NAME=VIEW_BY_ID&' ||
      'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=2&' ||
      'pParamIds=Y'')';

  l_drill_url3 :=
  'DECODE(qry.direct_ind
    ,1 ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
         'VIEW_BY_NAME=VIEW_BY_ID&' ||
         'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=3&' ||
         'HRI_P_SUPH_RO_CA=N&' ||
         'pParamIds=Y''
    ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
      'VIEW_BY_NAME=VIEW_BY_ID&' ||
      'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=3&' ||
      'pParamIds=Y'')';

  l_drill_url5 :=
  'DECODE(qry.direct_ind
    ,1 ,''pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
         'VIEW_BY_NAME=VIEW_BY_ID&' ||
         'HRI_P_SUPH_RO_CA=N&' ||
         'pParamIds=Y''
    ,''pFunctionName=HRI_P_WMV_TRN_BCKT_PERF_PVT&' ||
      'VIEW_BY_NAME=VIEW_BY_ID&' ||
      'pParamIds=Y'')';

  l_drill_url6 :=
  'DECODE(qry.direct_ind
    ,1 ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
         'VIEW_BY_NAME=VIEW_BY_ID&' ||
         'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=-5&' ||
         'HRI_P_SUPH_RO_CA=N&' ||
         'pParamIds=Y''
    ,''pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
      'VIEW_BY_NAME=VIEW_BY_ID&' ||
      'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X=-5&' ||
      'pParamIds=Y'')';

/* Return AK Sql To PMV */
 l_SQLText    :=
'SELECT -- Terminations with Performance Bands
 qry.order_by                 HRI_P_ORDER_BY_1
,qry.vby_id                   VIEWBYID
,qry.value                    VIEWBY
,DECODE(qry.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB' || g_rtn ||
/* high performers current metrics */
',qry.curr_termination_hdc_b3  HRI_P_MEASURE3
,DECODE(qry.curr_termination_hdc,
          0, 0,
        (qry.curr_termination_hdc_b3 / qry.curr_termination_hdc) * 100)
                              HRI_P_MEASURE3_MP
,' || l_drill_url3 || '       HRI_P_DRILL_URL3' || g_rtn ||
/* high performers comparison metrics */
',qry.comp_termination_hdc_b3  HRI_P_MEASURE8
,DECODE(qry.comp_termination_hdc,
          0, 0,
        (qry.comp_termination_hdc_b3 / qry.comp_termination_hdc) * 100)
                              HRI_P_MEASURE8_MP' || g_rtn ||
/* average performers current metrics */
',qry.curr_termination_hdc_b2  HRI_P_MEASURE2
,DECODE(qry.curr_termination_hdc,
          0, 0,
        (qry.curr_termination_hdc_b2 / qry.curr_termination_hdc) * 100)
                              HRI_P_MEASURE2_MP
,' || l_drill_url2 || '       HRI_P_DRILL_URL2' || g_rtn ||
/* average performers comparison metrics */
',qry.comp_termination_hdc_b2  HRI_P_MEASURE9
,DECODE(qry.comp_termination_hdc,
          0, 0,
        (qry.comp_termination_hdc_b2 / qry.comp_termination_hdc) * 100)
                              HRI_P_MEASURE9_MP' || g_rtn ||
/* low performers current metrics */
',qry.curr_termination_hdc_b1  HRI_P_MEASURE1
,DECODE(qry.curr_termination_hdc,
          0, 0,
        (qry.curr_termination_hdc_b1 / qry.curr_termination_hdc) * 100)
                              HRI_P_MEASURE1_MP
,' || l_drill_url1 || '       HRI_P_DRILL_URL1' || g_rtn ||
/* low performers comparison metrics */
',qry.comp_termination_hdc_b1  HRI_P_MEASURE10
,DECODE(qry.comp_termination_hdc,
          0, 0,
        (qry.comp_termination_hdc_b1 / qry.comp_termination_hdc) * 100)
                              HRI_P_MEASURE10_MP' || g_rtn ||
/* unassigned performers current metrics */
',qry.curr_termination_hdc_na  HRI_P_MEASURE6
,DECODE(qry.curr_termination_hdc,
          0, 0,
        (qry.curr_termination_hdc_na / qry.curr_termination_hdc) * 100)
                              HRI_P_MEASURE6_MP
,' || l_drill_url6 || '       HRI_P_DRILL_URL6' || g_rtn ||
/* unassigned performers comparison metrics */
',qry.comp_termination_hdc_na  HRI_P_MEASURE11
,DECODE(qry.comp_termination_hdc,
          0, 0,
        (qry.comp_termination_hdc_na / qry.comp_termination_hdc) * 100)
                              HRI_P_MEASURE11_MP
,qry.curr_termination_hdc     HRI_P_MEASURE7
,qry.comp_termination_hdc     HRI_P_MEASURE16
,DECODE(qry.comp_termination_hdc,
          0, NULL,
        ((qry.curr_termination_hdc - qry.comp_termination_hdc) /
          qry.comp_termination_hdc) * 100)
                              HRI_P_MEASURE7_MP
,qry.curr_total_term_hdc_b3   HRI_P_GRAND_TOTAL1
,DECODE(qry.curr_total_term_hdc,
          0, 0,
        (qry.curr_total_term_hdc_b3 / qry.curr_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL2
,qry.comp_total_term_hdc_b3   HRI_P_GRAND_TOTAL3
,DECODE(qry.comp_total_term_hdc,
          0, 0,
        (qry.comp_total_term_hdc_b3 / qry.comp_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL4
,qry.curr_total_term_hdc_b2   HRI_P_GRAND_TOTAL5
,DECODE(qry.curr_total_term_hdc,
          0, 0,
        (qry.curr_total_term_hdc_b2 / qry.curr_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL6
,qry.comp_total_term_hdc_b2   HRI_P_GRAND_TOTAL7
,DECODE(qry.comp_total_term_hdc,
          0, 0,
        (qry.comp_total_term_hdc_b2 / qry.comp_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL8
,qry.curr_total_term_hdc_b1   HRI_P_GRAND_TOTAL9
,DECODE(qry.curr_total_term_hdc,
          0, 0,
        (qry.curr_total_term_hdc_b1 / qry.curr_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL10
,qry.comp_total_term_hdc_b1   HRI_P_GRAND_TOTAL11
,DECODE(qry.comp_total_term_hdc,
          0, 0,
        (qry.comp_total_term_hdc_b1 / qry.comp_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL12
,qry.curr_total_term_hdc_na   HRI_P_GRAND_TOTAL13
,DECODE(qry.curr_total_term_hdc,
          0, 0,
        (qry.curr_total_term_hdc_na / qry.curr_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL14
,qry.comp_total_term_hdc_na   HRI_P_GRAND_TOTAL15
,DECODE(qry.comp_total_term_hdc,
          0, 0,
        (qry.comp_total_term_hdc_na / qry.comp_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL16
,qry.curr_total_term_hdc      HRI_P_GRAND_TOTAL17
,qry.comp_total_term_hdc      HRI_P_GRAND_TOTAL18
,DECODE(qry.comp_total_term_hdc,
          0, 0,
        ((qry.curr_total_term_hdc - qry.comp_total_term_hdc) /
          qry.comp_total_term_hdc) * 100)
                              HRI_P_GRAND_TOTAL17_MP' || g_rtn ||
/* HRI_P_DRILL_URL5 used as drill url when viewby manager only */
', '|| l_drill_url5 || '      HRI_P_DRILL_URL5
FROM
(SELECT
  cl.id  vby_id
 ,NVL(wmv.direct_ind, 0)  direct_ind
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         cl.value)  value
 ,to_char(NVL(wmv.direct_ind, 0)) || cl.order_by  order_by
 ,NVL(wmv.curr_hdc_end, 0)  curr_hdc
 ,NVL(SUM(wmv.curr_hdc_end) OVER (), 0)  curr_total_hdc
 ,NVL(trn.curr_separation_hdc_b3, 0)  curr_termination_hdc_b3
 ,NVL(trn.curr_separation_hdc_b2, 0)  curr_termination_hdc_b2
 ,NVL(trn.curr_separation_hdc_b1, 0)  curr_termination_hdc_b1
 ,NVL(trn.curr_separation_hdc_na, 0)  curr_termination_hdc_na
 ,NVL(trn.curr_separation_hdc, 0)     curr_termination_hdc
 ,NVL(trn.comp_separation_hdc_b3, 0)  comp_termination_hdc_b3
 ,NVL(trn.comp_separation_hdc_b2, 0)  comp_termination_hdc_b2
 ,NVL(trn.comp_separation_hdc_b1, 0)  comp_termination_hdc_b1
 ,NVL(trn.comp_separation_hdc_na, 0)  comp_termination_hdc_na
 ,NVL(trn.comp_separation_hdc, 0)     comp_termination_hdc
 ,:HRI_CURR_TERM_HDC_B3  curr_total_term_hdc_b3
 ,:HRI_COMP_TERM_HDC_B3  comp_total_term_hdc_b3
 ,:HRI_CURR_TERM_HDC_B2  curr_total_term_hdc_b2
 ,:HRI_COMP_TERM_HDC_B2  comp_total_term_hdc_b2
 ,:HRI_CURR_TERM_HDC_B1  curr_total_term_hdc_b1
 ,:HRI_COMP_TERM_HDC_B1  comp_total_term_hdc_b1
 ,:HRI_CURR_TERM_HDC_NA  curr_total_term_hdc_na
 ,:HRI_COMP_TERM_HDC_NA  comp_total_term_hdc_na
 ,:HRI_CURR_TERM_HDC     curr_total_term_hdc
 ,:HRI_COMP_TERM_HDC     comp_total_term_hdc
 FROM
  ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || '  cl
,(' || l_wrkfc_fact_sql || ')  wmv
,(' || l_wcnt_chg_fact_sql || ')  trn
 WHERE wmv.vby_id = trn.vby_id (+)
 AND cl.id = wmv.vby_id' || l_wmv_outer_join || g_rtn ||
  l_view_by_filter ||
' ) QRY
WHERE 1 = 1
' || l_security_clause || g_rtn ||
 l_display_row_condition ||
'ORDER BY ' || l_parameter_rec.order_by;

 x_custom_sql := l_SQLText;

/* Binds Will be inserted Below */
  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC';
  l_custom_rec.attribute_value := l_curr_term_hdc;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC_B1';
  l_custom_rec.attribute_value := l_curr_term_hdc_b1;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC_B2';
  l_custom_rec.attribute_value := l_curr_term_hdc_b2;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC_B3';
  l_custom_rec.attribute_value := l_curr_term_hdc_b3;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC_NA';
  l_custom_rec.attribute_value := l_curr_term_hdc_na;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_HDC';
  l_custom_rec.attribute_value := l_comp_term_hdc;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_HDC_B1';
  l_custom_rec.attribute_value := l_comp_term_hdc_b1;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_HDC_B2';
  l_custom_rec.attribute_value := l_comp_term_hdc_b2;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_HDC_B3';
  l_custom_rec.attribute_value := l_comp_term_hdc_b3;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_HDC_NA';
  l_custom_rec.attribute_value := l_comp_term_hdc_na;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(10) := l_custom_rec;

END GET_SQL_BKCT_PERF;


/******************************************************************************/
/* Termination by Length of service
/******************************************************************************/
PROCEDURE GET_TRN_POW_SQL
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_security_clause      VARCHAR2(4000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Dynamic strings */
  l_direct_reports_string   VARCHAR2(1000);
  l_wmv_outer_join          VARCHAR2(30);
  l_display_row_condition   VARCHAR2(1000);
  l_view_by_filter            VARCHAR2(1000);

/* Drill URLs */
  l_drill_mgr_sup        VARCHAR2(500);
  l_drill_mgr_dir        VARCHAR2(500);
  l_drill_trn_bn1_dtl    VARCHAR2(500);
  l_drill_trn_bn2_dtl    VARCHAR2(500);
  l_drill_trn_bn3_dtl    VARCHAR2(500);
  l_drill_trn_bn4_dtl    VARCHAR2(500);
  l_drill_trn_bn5_dtl    VARCHAR2(500);

/* Grand totals for terminations */
  l_term_hdc             NUMBER;
  l_term_hdc_b1          NUMBER;
  l_term_hdc_b2          NUMBER;
  l_term_hdc_b3          NUMBER;
  l_term_hdc_b4          NUMBER;
  l_term_hdc_b5          NUMBER;

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

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Precalculate grand totals */
  -- bug 4317575
  hri_bpl_dbi_calc_period.calc_sup_term_low_pvt
       (p_supervisor_id  => l_parameter_rec.peo_supervisor_id,
        p_from_date      => l_parameter_rec.time_curr_start_date,
        p_to_date        => l_parameter_rec.time_curr_end_date,
        p_bind_tab       => l_bind_tab,
        p_total_term     => l_term_hdc,
        p_total_term_b1  => l_term_hdc_b1,
        p_total_term_b2  => l_term_hdc_b2,
        p_total_term_b3  => l_term_hdc_b3,
        p_total_term_b4  => l_term_hdc_b4,
        p_total_term_b5  => l_term_hdc_b5);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_TRN_SUP_BCKT.GET_SQL_BKCT_LOW');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.bucket_dim := 'HRI_LOW+HRI_LOW_BAND_X';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_SUP_BCKT.GET_SQL_BKCT_LOW');

/* Set drill URLs for constant drills */
  l_drill_trn_bn1_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                         'VIEW_BY_NAME=VIEW_BY_ID&' ||
                          'HRI_P_LOW_BAND_CN=' ||
                          convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                   ,1  -- bucket
                                                   ,l_parameter_rec.wkth_wktyp_sk_fk)||
                         '&' ||
                         'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                         'pParamIds=Y';

  l_drill_trn_bn2_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                         'VIEW_BY_NAME=VIEW_BY_ID&' ||
                          'HRI_P_LOW_BAND_CN=' ||
                          convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                   ,2  -- bucket
                                                   ,l_parameter_rec.wkth_wktyp_sk_fk)||
                         '&' ||
                         'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                         'pParamIds=Y';

  l_drill_trn_bn3_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                         'VIEW_BY_NAME=VIEW_BY_ID&' ||
                          'HRI_P_LOW_BAND_CN=' ||
                          convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                   ,3  -- bucket
                                                   ,l_parameter_rec.wkth_wktyp_sk_fk)||
                         '&' ||
                         'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                         'pParamIds=Y';

  l_drill_trn_bn4_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                         'VIEW_BY_NAME=VIEW_BY_ID&' ||
                          'HRI_P_LOW_BAND_CN=' ||
                          convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                   ,4  -- bucket
                                                   ,l_parameter_rec.wkth_wktyp_sk_fk)||
                         '&' ||
                         'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                         'pParamIds=Y';

  l_drill_trn_bn5_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                         'VIEW_BY_NAME=VIEW_BY_ID&' ||
                          'HRI_P_LOW_BAND_CN=' ||
                          convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                   ,5  -- bucket
                                                   ,l_parameter_rec.wkth_wktyp_sk_fk)||
                         '&' ||
                         'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                         'pParamIds=Y';

/* Set view by manager drill URLs */
  IF (l_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    l_drill_mgr_sup := 'pFunctionName=HRI_P_WMV_TRN_BCKT_POW_PVT&' ||
                       'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                       'VIEW_BY_NAME=VIEW_BY_ID&' ||
                       'pParamIds=Y';
    l_drill_mgr_dir := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                       'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                       'VIEW_BY_NAME=VIEW_BY_ID&' ||
                       'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                       'pParamIds=Y';
  END IF;

/* Set the display row conditions */
  IF (l_parameter_rec.view_by = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
      l_parameter_rec.view_by = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' OR
      l_parameter_rec.view_by = 'HRI_LOW+HRI_LOW_BAND_X') THEN
  /* Outer join to facts, display all rows */
    l_wmv_outer_join := ' (+)';
  /* Set the view by filter */
    l_view_by_filter := hri_oltp_pmv_util_pkg.set_viewby_filter
            (p_parameter_rec => l_parameter_rec,
             p_bind_tab => l_bind_tab,
             p_view_by_alias => 'cl');
  ELSE
  /* Only display directs row or rows with activity */
    l_display_row_condition :=
' AND (a.curr_hdc_end > 0
 OR a.curr_trn_tot > 0
 OR a.direct_ind = 1)' || g_rtn;
  END IF;

 /* bug 4202907 append cl start AND end_date filter if viewby manager */
 IF (l_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    l_view_by_filter := l_view_by_filter ||
        'AND &BIS_CURRENT_ASOF_DATE BETWEEN cl.start_date AND cl.end_date';
 END IF;

/* Swap the viewby column for the default sort order */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
   (p_order_by_clause => l_parameter_rec.order_by);

  l_sqltext :=
'SELECT  --  Terminations with Length of Service Portlet
 a.id                               VIEWBYID
,a.value                            VIEWBY
,DECODE(a.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB ' || g_rtn ||
/* Title - Band One - under 1 year */'
,a.curr_trn_bn1                     HRI_P_MEASURE1
,DECODE(a.curr_trn_tot,0,0
       ,DECODE(a.curr_trn_bn1,0,0
              ,(a.curr_trn_bn1 / a.curr_trn_tot) * 100)
        )                           HRI_P_MEASURE1_MP' || g_rtn ||
/* Title - Band Two - 1-3 years */'
,a.curr_trn_bn2                     HRI_P_MEASURE2
,DECODE(a.curr_trn_tot,0,0
       ,DECODE(a.curr_trn_bn2,0,0
              ,(a.curr_trn_bn2 / a.curr_trn_tot) * 100)
        )                           HRI_P_MEASURE2_MP' || g_rtn ||
/* Title - Band Three - 3-5 years */'
,a.curr_trn_bn3                     HRI_P_MEASURE3
,DECODE(a.curr_trn_tot,0,0
       ,DECODE(a.curr_trn_bn3,0,0
              ,(a.curr_trn_bn3 / a.curr_trn_tot) * 100)
        )                           HRI_P_MEASURE3_MP ' || g_rtn ||
/* Title - Band Four - 5-10 years */'
,a.curr_trn_bn4                     HRI_P_MEASURE4
,DECODE(a.curr_trn_tot,0,0
       ,DECODE(a.curr_trn_bn4,0,0
              ,(a.curr_trn_bn4 / a.curr_trn_tot) * 100)
        )                           HRI_P_MEASURE4_MP ' || g_rtn ||
/* Title - Band Five - over 10 years */'
,a.curr_trn_bn5                     HRI_P_MEASURE5
,DECODE(a.curr_trn_tot,0,0
       ,DECODE(a.curr_trn_bn5,0,0
              ,(a.curr_trn_bn5 / a.curr_trn_tot) * 100)
        )                           HRI_P_MEASURE5_MP  ' || g_rtn ||
/* Total Terminations */'
,a.curr_trn_tot                     HRI_P_MEASURE6 ' || g_rtn ||
/* Grand Total - Band One - under 1 year */'
,a.tot_curr_trn_bn1                 HRI_P_GRAND_TOTAL1
,DECODE(a.tot_curr_trn_tot,0,0
       ,DECODE(a.tot_curr_trn_bn1,0,0
              ,(a.tot_curr_trn_bn1 / a.tot_curr_trn_tot) * 100)
       )                            HRI_P_GRAND_TOTAL1_MP' || g_rtn ||
/* Title - Band Two - 1-3 years */'
,a.tot_curr_trn_bn2                 HRI_P_GRAND_TOTAL2
,DECODE(a.tot_curr_trn_tot,0,0
       ,DECODE(a.tot_curr_trn_bn2,0,0
              ,(a.tot_curr_trn_bn2 / a.tot_curr_trn_tot) * 100)
       )                            HRI_P_GRAND_TOTAL2_MP' || g_rtn ||
/* Title - Band Three - 3-5 years */'
,a.tot_curr_trn_bn3                 HRI_P_GRAND_TOTAL3
,DECODE(a.tot_curr_trn_tot,0,0
       ,DECODE(a.tot_curr_trn_bn3,0,0
              ,(a.tot_curr_trn_bn3 / a.tot_curr_trn_tot) * 100)
       )                            HRI_P_GRAND_TOTAL3_MP' || g_rtn ||
/* Title - Band Four - 5-10 years */'
,a.tot_curr_trn_bn4                 HRI_P_GRAND_TOTAL4
,DECODE(a.tot_curr_trn_tot,0,0
       ,DECODE(a.tot_curr_trn_bn4,0,0
              ,(a.tot_curr_trn_bn4 / a.tot_curr_trn_tot) * 100)
       )                            HRI_P_GRAND_TOTAL4_MP' || g_rtn ||
/* Title - Band Four - over 10 years */'
,a.tot_curr_trn_bn5                 HRI_P_GRAND_TOTAL5
,DECODE(a.tot_curr_trn_tot,0,0
       ,DECODE(a.tot_curr_trn_bn5,0,0
              ,(a.tot_curr_trn_bn5 / a.tot_curr_trn_tot) * 100)
       )                            HRI_P_GRAND_TOTAL5_MP' || g_rtn ||
/* Total Terminations */'
,a.tot_curr_trn_tot                 HRI_P_GRAND_TOTAL6 ' || g_rtn ||
/* Order by person name default sort order */
',a.order_by                        HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Whether the row is a supervisor rollup row */
',DECODE(a.direct_ind , 0, '''', ''N'')
                                    HRI_P_SUPH_RO_CA' || g_rtn ||
/* Drill URLs */
',DECODE(a.direct_ind,
           0, ''' || l_drill_mgr_sup  || ''',
         ''' || l_drill_mgr_dir  || ''')
                                    HRI_P_DRILL_URL1
,'''||l_drill_trn_bn1_dtl ||'''     HRI_P_DRILL_URL2
,'''||l_drill_trn_bn2_dtl ||'''     HRI_P_DRILL_URL3
,'''||l_drill_trn_bn3_dtl ||'''     HRI_P_DRILL_URL4
,'''||l_drill_trn_bn4_dtl ||'''     HRI_P_DRILL_URL5
,'''||l_drill_trn_bn5_dtl ||'''     HRI_P_DRILL_URL6
FROM
(SELECT
  cl.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         cl.value)  value
 ,to_char(NVL(wmv.direct_ind, 0)) || cl.order_by  order_by
 ,NVL(wmv.direct_ind, 0)  direct_ind' || g_rtn ||
/* Headcount */
' ,NVL(wmv.curr_hdc_end, 0)  curr_hdc_end' || g_rtn ||
/* Turnover */
' ,NVL(trn.curr_separation_hdc_b1, 0)  curr_trn_bn1
 ,NVL(trn.curr_separation_hdc_b2, 0)  curr_trn_bn2
 ,NVL(trn.curr_separation_hdc_b3, 0)  curr_trn_bn3
 ,NVL(trn.curr_separation_hdc_b4, 0)  curr_trn_bn4
 ,NVL(trn.curr_separation_hdc_b5, 0)  curr_trn_bn5
 ,NVL(trn.curr_separation_hdc, 0)     curr_trn_tot' || g_rtn ||
/* Grand Totals - Turnover */
' ,:HRI_TOT_TERM_HDC_B1                  tot_curr_trn_bn1
 ,:HRI_TOT_TERM_HDC_B2                   tot_curr_trn_bn2
 ,:HRI_TOT_TERM_HDC_B3                   tot_curr_trn_bn3
 ,:HRI_TOT_TERM_HDC_B4                   tot_curr_trn_bn4
 ,:HRI_TOT_TERM_HDC_B5                   tot_curr_trn_bn5
 ,:HRI_TOT_TERM_HDC                      tot_curr_trn_tot
 FROM
  ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || '  cl
 ,(' || l_wrkfc_fact_sql || ')  wmv
 ,(' || l_wcnt_chg_fact_sql || ')  trn
 WHERE wmv.vby_id = trn.vby_id (+)
 AND cl.id = wmv.vby_id ' || l_wmv_outer_join || g_rtn ||
  l_view_by_filter ||
' ) a
WHERE 1 = 1' || g_rtn ||
  l_display_row_condition || g_rtn ||
  l_security_clause || '
ORDER BY ' || l_parameter_rec.order_by;

  x_custom_sql := l_SQLText;
  --l_parameter_rec.debug_header || l_SQLText;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC';
  l_custom_rec.attribute_value := l_term_hdc;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC_B1';
  l_custom_rec.attribute_value := l_term_hdc_b1;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC_B2';
  l_custom_rec.attribute_value := l_term_hdc_b2;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC_B3';
  l_custom_rec.attribute_value := l_term_hdc_b3;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC_B4';
  l_custom_rec.attribute_value := l_term_hdc_b4;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_TERM_HDC_B5';
  l_custom_rec.attribute_value := l_term_hdc_b5;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

END GET_TRN_POW_SQL;
--
-- ----------------------------------------------------------------------
-- Procedure to fetch the termination ratio by performance KPI
-- It fetched the values for the following KPIs
--  1. Termination ratio for High Band
--  2. Termination ratio for High Band
--  3. Termination ratio for Mid Band
--  4. Termination ratio for Mid Band
--  5. Termination ratio for Low Band
--  6. Termination ratio for Low Band
--  7. Termination ratio for NA Band
--  8. Termination ratio for NA Band
-- ----------------------------------------------------------------------
--
PROCEDURE get_trn_perf_kpi
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  --
  -- The security clause
  --
  l_security_clause      VARCHAR2(4000);
  --
  -- Page parameters
  --
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  --
  -- Bind values for SQL and PMV mode
  --
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  --
  -- Parameter values for getting the inner SQL
  --
  l_wcnt_chg_params         hri_bpl_fact_sup_wcnt_chg_sql.WCNT_CHG_FACT_PARAM_TYPE;
  --
  -- Inner SQL
  --
  l_inn_sql              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  --
BEGIN
  --
  x_custom_output   := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec      := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');
  --
  -- Get the parameter information from the page parameter table
  --
  hri_oltp_pmv_util_param.get_parameters_from_table
            (p_page_parameter_tbl  => p_page_parameter_tbl,
             p_parameter_rec       => l_parameter_rec,
             p_bind_tab            => l_bind_tab);
  --
  -- Set the parameters for getting the inner SQL
  --
  l_wcnt_chg_params.bind_format   := 'PMV';
  l_wcnt_chg_params.include_comp  := 'Y';
  l_wcnt_chg_params.include_sep   := 'Y';
  l_wcnt_chg_params.kpi_mode      := 'Y';
  l_wcnt_chg_params.bucket_dim    := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  --
  -- Get the inner SQL
  --
  l_inn_sql := HRI_OLTP_PMV_QUERY_WCNT_CHG.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wcnt_chg_params  => l_wcnt_chg_params,
                  p_calling_module   => 'hri_oltp_pmv_wmv_trn_sup_bckt.get_trn_perf_kpi');
  --
  -- Form the SQL
  --
  x_custom_sql :=
'SELECT --Termination by Performance
 qry.vby_id               VIEWBYID
,qry.vby_id               VIEWBY
,curr_separation_hdc_b3/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_MEASURE1
,comp_separation_hdc_b3/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_MEASURE2
,curr_separation_hdc_b2/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_MEASURE4
,comp_separation_hdc_b2/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_MEASURE5
,curr_separation_hdc_b1/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_MEASURE7
,comp_separation_hdc_b1/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_MEASURE8
,curr_separation_hdc_na/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_MEASURE10
,comp_separation_hdc_na/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_MEASURE11
,curr_separation_hdc_b3/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL1
,comp_separation_hdc_b3/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL2
,curr_separation_hdc_b2/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL4
,comp_separation_hdc_b2/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL5
,curr_separation_hdc_b1/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL7
,comp_separation_hdc_b1/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL8
,curr_separation_hdc_na/decode(curr_separation_hdc,0,1,curr_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL10
,comp_separation_hdc_na/decode(comp_separation_hdc,0,1,comp_separation_hdc)* 100
                          HRI_P_GRAND_TOTAL11
FROM
('||l_inn_sql||') qry
WHERE 1=1
' || l_security_clause;
  --
END get_trn_perf_kpi;

END hri_oltp_pmv_wmv_trn_sup_bckt;

/
