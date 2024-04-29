--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_WF_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_WF_SUP" AS
/* $Header: hriopwfs.pkb 120.1 2005/10/26 07:54:16 jrstewar noship $ */

  g_rtn   VARCHAR2(5) := '
';
--
-- *********************************
-- * AK SQL For Total Workforce KPI*
-- * AK Region : HRI_K_WMV_WF      *
-- *********************************
--
PROCEDURE get_kpi
    (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
     x_custom_sql          OUT NOCOPY VARCHAR2,
     x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Force view by manager */
  l_parameter_rec.view_by := 'HRI_PERSON+HRI_PER_USRDR_H';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.kpi_mode := 'Y';
  l_wrkfc_fact_params.bucket_dim := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_WF_SUP.GET_KPI');

l_SQLText :=
'SELECT -- Total Workforce KPI Report
 vby.id                         VIEWBYID
,vby.value                      VIEWBY
,tab.CURR_HDC_END               HRI_P_MEASURE1
,tab.COMP_HDC_END               HRI_P_MEASURE2
,tab.CURR_HDC_EMP               HRI_P_MEASURE3
,tab.CURR_HDC_EMP               HRI_P_MEASURE4
,tab.CURR_HDC_CWK               HRI_P_MEASURE5
,tab.COMP_HDC_CWK               HRI_P_MEASURE6
,tab.CURR_HDC_END               HRI_P_GRAND_TOTAL1
,tab.COMP_HDC_END               HRI_P_GRAND_TOTAL2
,tab.CURR_HDC_EMP               HRI_P_GRAND_TOTAL3
,tab.CURR_HDC_EMP               HRI_P_GRAND_TOTAL4
,CURR_HDC_CWK                   HRI_P_GRAND_TOTAL5
,COMP_HDC_CWK                   HRI_P_GRAND_TOTAL6
FROM
 hri_dbi_cl_per_n_v  vby
,(' || l_wrkfc_fact_sql || ')  tab
WHERE tab.vby_id = vby.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.effective_start_date
                          AND vby.effective_end_date
' || l_security_clause;

  x_custom_sql := l_SQLText;

END GET_KPI;
--
-- ***************************************************
-- * AK SQL For Workforce Activity By Manager Status *
-- * AK Region : HRI_P_WMV_WF_SUP                    *
-- ***************************************************
--
PROCEDURE get_sql(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_security_clause      VARCHAR2(4000);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Pre-calculations */
  l_tot_gain              NUMBER;
  l_tot_gain_hire         NUMBER;
  l_tot_gain_place        NUMBER;
  l_tot_gain_all          NUMBER;
  l_tot_gain_transfer_emp NUMBER;
  l_tot_gain_transfer_cwk NUMBER;
  l_tot_gain_transfer_all NUMBER;
  l_tot_loss              NUMBER;
  l_tot_loss_term         NUMBER;
  l_tot_loss_place        NUMBER;
  l_tot_loss_all          NUMBER;
  l_tot_loss_transfer_emp NUMBER;
  l_tot_loss_transfer_cwk NUMBER;
  l_tot_loss_transfer_all NUMBER;
  l_tot_net               NUMBER;

/* Direct reports string */
  l_direct_reports_string VARCHAR2(30);

/* To support selective drill across urls */
  l_drill_to_function1    VARCHAR2(300);
  l_drill_to_function2    VARCHAR2(300);
  l_drill_to_function3    VARCHAR2(300);
  l_drill_to_function4    VARCHAR2(300);
  l_drill_to_function5    VARCHAR2(300);
  l_drill_to_function6	  VARCHAR2(300);
  l_drill_url1            VARCHAR2(300);
  l_drill_url2            VARCHAR2(300);
  l_drill_url3            VARCHAR2(300);
  l_drill_url4            VARCHAR2(300);
  l_drill_url5            VARCHAR2(300);
  l_drill_url6            VARCHAR2(300);
  l_drill_url7            VARCHAR2(300);
  l_drill_url8            VARCHAR2(300);

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
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


  /* use selective drill across feature */
  l_drill_url1 := 'pFunctionName=HRI_P_WMV_WF_SUP&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';

  l_drill_url2 := 'pFunctionName=HRI_P_WAC_HIR_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url3 := 'pFunctionName=HRI_P_WAC_C_HIR_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url4 := 'pFunctionName=HRI_P_WAC_WF_IN_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url5 := 'pFunctionName=HRI_P_WAC_SEP_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url6 := 'pFunctionName=HRI_P_WAC_C_SEP_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url7 := 'pFunctionName=HRI_P_WAC_WF_OUT_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url8 := 'pFunctionName=HRI_P_WMV_WF_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Set direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get WMV Change totals for supervisor from cursor */


/* Totals For Employee Columns */
  hri_bpl_dbi_calc_period.calc_sup_wcnt_chg
        (p_supervisor_id        => l_parameter_rec.peo_supervisor_id,
         p_from_date            => l_parameter_rec.time_curr_start_date,
         p_to_date              => l_parameter_rec.time_curr_end_date,
         p_period_type          => l_parameter_rec.page_period_type,
         p_comparison_type      => l_parameter_rec.time_comparison_type,
         p_total_type           => 'ROLLUP',
         p_wkth_wktyp_sk_fk     => 'EMP',
         p_total_gain_hire      => l_tot_gain_hire,
         p_total_gain_transfer  => l_tot_gain_transfer_emp,
         p_total_loss_term      => l_tot_loss_term,
         p_total_loss_transfer  => l_tot_loss_transfer_emp);

/* Totals Contingent Worker Columns */
  hri_bpl_dbi_calc_period.calc_sup_wcnt_chg
        (p_supervisor_id        => l_parameter_rec.peo_supervisor_id,
         p_from_date            => l_parameter_rec.time_curr_start_date,
         p_to_date              => l_parameter_rec.time_curr_end_date,
         p_period_type          => l_parameter_rec.page_period_type,
         p_comparison_type      => l_parameter_rec.time_comparison_type,
         p_total_type           => 'ROLLUP',
         p_wkth_wktyp_sk_fk     => 'CWK',
         p_total_gain_hire      => l_tot_gain_place,
         p_total_gain_transfer  => l_tot_gain_transfer_cwk,
         p_total_loss_term      => l_tot_loss_place,
         p_total_loss_transfer  => l_tot_loss_transfer_cwk);


/* Set WMV Change dependent totals */
  l_tot_gain_transfer_all := l_tot_gain_transfer_emp + l_tot_gain_transfer_cwk;
  l_tot_loss_transfer_all := l_tot_loss_transfer_emp + l_tot_loss_transfer_cwk;
  l_tot_gain_all := l_tot_gain_hire + l_tot_gain_place;
  l_tot_loss_all := l_tot_loss_term + l_tot_loss_place;

  l_tot_gain := l_tot_gain_all + l_tot_gain_transfer_all;
  l_tot_loss := l_tot_loss_all + l_tot_loss_transfer_all;
  l_tot_net := l_tot_gain - l_tot_loss;

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);


/* Currently Using Standalone query */

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_WF_SUP.GET_SQL2');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_hire := 'Y';
  l_wcnt_chg_fact_params.include_trin := 'Y';
  l_wcnt_chg_fact_params.include_trout := 'Y';
  l_wcnt_chg_fact_params.include_term := 'Y';
  l_wcnt_chg_fact_params.bucket_dim := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_WF_SUP.GET_SQL');

/* Build query */
  l_sqltext :='SELECT  -- Workforce Activity by Manager Status
 tots.id                      			VIEWBYID
,tots.value                   			VIEWBY
,tots.current_wmv_start      			HRI_P_MEASURE1
,tots.wmv_gain_hire          			HRI_P_MEASURE2
,'''|| l_drill_url2 ||'''               HRI_P_DRILL_URL2
,tots.wmv_gain_place					HRI_P_MEASURE3
,'''|| l_drill_url3 ||'''               HRI_P_DRILL_URL3
,tots.wmv_gain_transfer   			    HRI_P_MEASURE4
,'''|| l_drill_url4 ||'''               HRI_P_DRILL_URL4
,tots.wmv_loss_term       	            HRI_P_MEASURE5
,'''|| l_drill_url5 ||'''               HRI_P_DRILL_URL5
,tots.wmv_loss_end_place                HRI_P_MEASURE6
,'''|| l_drill_url6 ||'''               HRI_P_DRILL_URL6
,tots.wmv_loss_transfer      			HRI_P_MEASURE7
,'''|| l_drill_url7 ||'''               HRI_P_DRILL_URL7
,tots.current_wmv_end        			HRI_P_MEASURE8
,tots.wmv_net                			HRI_P_MEASURE9
,DECODE(tots.previous_wmv_end,
          0, DECODE(tots.current_wmv_end,0,0,100),
        (tots.current_wmv_end - tots.previous_wmv_end) * 100 /
        tots.previous_wmv_end)          HRI_P_MEASURE10
,tots.curr_total_hdc_start              HRI_P_GRAND_TOTAL1
,:HRI_TOT_GAIN_HIRE                     HRI_P_GRAND_TOTAL2
,:HRI_TOT_GAIN_PLACE                    HRI_P_GRAND_TOTAL3
,:HRI_TOT_GAIN_TRANSFER                 HRI_P_GRAND_TOTAL4
,:HRI_TOT_LOSS_TERM                     HRI_P_GRAND_TOTAL5
,:HRI_TOT_LOSS_PLACE                    HRI_P_GRAND_TOTAL6
,:HRI_TOT_LOSS_TRANSFER                 HRI_P_GRAND_TOTAL7
,tots.curr_total_hdc_end                HRI_P_GRAND_TOTAL8
,:HRI_TOT_NET_GAIN_LOSS                 HRI_P_GRAND_TOTAL9
,DECODE(tots.comp_total_hdc_end,
          0, DECODE(tots.curr_total_hdc_end  , 0, 0, 100),
        (tots.curr_total_hdc_end - tots.comp_total_hdc_end) * 100 /
        tots.comp_total_hdc_end)        HRI_P_GRAND_TOTAL10
,tots.order_by              			HRI_P_ORDER_BY_1
,tots.suph_rollup_flag      			HRI_P_SUPH_RO_CA
,DECODE(tots.suph_rollup_flag,''Y'','''|| l_drill_url1 ||'''
                             ,''N'','''|| l_drill_url8 ||''')
                                        HRI_P_DRILL_URL8
FROM
(SELECT
  per.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         per.value)                 value
 ,to_char(wmv.direct_ind) || per.order_by               order_by
 ,NVL(chg.Curr_hire_hdc + chg.curr_transfer_in_hdc,0)   wmv_gain
 ,NVL(chg.curr_hire_hdc_emp,0)                          wmv_gain_hire
 ,NVL(chg.curr_hire_hdc_cwk,0)                          wmv_gain_place
 ,NVL(chg.curr_transfer_in_hdc,0)                       wmv_gain_transfer
 ,NVL(chg.curr_termination_hdc + curr_transfer_out_hdc,0)
                                                        wmv_loss
 ,NVL(chg.curr_termination_hdc_emp,0)                   wmv_loss_term
 ,NVL(chg.curr_termination_hdc_cwk,0)                   wmv_loss_end_place
 ,NVL(chg.curr_transfer_out_hdc,0)                      wmv_loss_transfer
 ,NVL((chg.curr_hire_hdc + chg.curr_transfer_in_hdc) -
 (chg.curr_termination_hdc + chg.curr_transfer_out_hdc), 0)
                                                        wmv_net
 ,wmv.curr_hdc_start                                    current_wmv_start
 ,wmv.curr_hdc_end                                      current_wmv_end
 ,wmv.comp_hdc_start                                    previous_wmv_start
 ,wmv.comp_hdc_end                                      previous_wmv_end
 ,SUM(wmv.curr_hdc_end) OVER ()                         curr_total_hdc_end
 ,SUM(wmv.curr_total_hdc_start) OVER ()                 curr_total_hdc_start
 ,SUM(wmv.comp_total_hdc_end) OVER ()                   comp_total_hdc_end
 ,DECODE(wmv.direct_ind,
           1, ''N'',
         '''')                                          suph_rollup_flag
 FROM
  hri_dbi_cl_per_n_v      per
 ,('|| l_wrkfc_fact_sql ||') wmv
 ,('|| l_wcnt_chg_fact_sql ||') chg
 WHERE wmv.vby_id = chg.vby_id (+)
 AND wmv.vby_id = per.id
 AND &AS_OF_DATE BETWEEN per.effective_start_date
                            AND per.effective_end_date
 AND (wmv.curr_hdc_end > 0
   OR chg.curr_hire_hdc > 0
   or chg.curr_transfer_in_hdc > 0
   or chg.curr_transfer_out_hdc > 0
   or chg.curr_termination_hdc > 0
   or wmv.direct_ind = 1)
) tots
WHERE 1 = 1
' || l_security_clause || '
ORDER BY ' || l_parameter_rec.order_by;

  x_custom_sql := l_SQLText;

/* Total not yet code for */

  l_custom_rec.attribute_name := ':HRI_TOT_GAIN_HIRE';
  l_custom_rec.attribute_value := l_tot_gain_hire;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_GAIN_PLACE';
  l_custom_rec.attribute_value := l_tot_gain_place;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_GAIN_TRANSFER';
  l_custom_rec.attribute_value := l_tot_gain_transfer_all;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_LOSS_TERM';
  l_custom_rec.attribute_value := l_tot_loss_term;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_LOSS_PLACE';
  l_custom_rec.attribute_value := l_tot_loss_place;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_LOSS_TRANSFER';
  l_custom_rec.attribute_value := l_tot_loss_transfer_all;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_NET_GAIN_LOSS';
  l_custom_rec.attribute_value := l_tot_net;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

END get_sql;

END HRI_OLTP_PMV_WMV_WF_SUP;

/
