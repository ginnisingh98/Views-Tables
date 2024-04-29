--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_TRN_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_TRN_SUP" AS
/* $Header: hriopwts.pkb 120.4 2005/12/12 08:11:07 cbridge noship $ */

  g_rtn     VARCHAR2(5) := '
';

/******************************************************************************/
/* Annualized Turnover Portlet                                                */
/******************************************************************************/
PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Variables for SQL returned */
  l_sqltext                   VARCHAR2(30000) ;
  l_security_clause           VARCHAR2(4000);
  l_custom_rec                BIS_QUERY_ATTRIBUTES;
  l_drill_url                 VARCHAR2(500);
  l_drill_url2                VARCHAR2(500);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Pre-calculations */
  l_calc_anl_factor           NUMBER;
  l_curr_term_vol             NUMBER;
  l_curr_term_invol           NUMBER;
  l_comp_term_vol             NUMBER;
  l_comp_term_invol           NUMBER;

/* Columns */
  l_col_curr_trn_hdc          VARCHAR2(100);
  l_col_comp_trn_hdc          VARCHAR2(100);
  l_col_curr_tot_trn_hdc      VARCHAR2(100);
  l_col_comp_tot_trn_hdc      VARCHAR2(100);

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Messages */
  l_direct_reports_string  VARCHAR2(100);

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Drill url creation */
  l_drill_url := 'pFunctionName=HRI_P_WMV_TRN_SUMMARY_PVT&' ||
                 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                 'VIEW_BY_NAME=VIEW_BY_ID&' ||
                 'pParamIds=Y';
  l_drill_url2 := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=N&' ||
                  'pParamIds=Y';

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Turnover calculation method is either start/end average or end value */
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN

  /* Set Column Strings */
    l_col_curr_trn_hdc := '(wmv.curr_hdc_end + wmv.curr_hdc_start) / 2';
    l_col_comp_trn_hdc := '(wmv.comp_hdc_end + wmv.comp_hdc_start) / 2';
    l_col_curr_tot_trn_hdc := '(wmv.curr_hdc_end + wmv.curr_total_hdc_start) / 2';
    l_col_comp_tot_trn_hdc := '(wmv.comp_total_hdc_end + wmv.comp_total_hdc_start) / 2';

  ELSE

  /* Set Column Strings */
    l_col_curr_trn_hdc := 'wmv.curr_hdc_end';
    l_col_comp_trn_hdc := 'wmv.comp_hdc_end';
    l_col_curr_tot_trn_hdc := 'wmv.curr_hdc_end';
    l_col_comp_tot_trn_hdc := 'wmv.comp_total_hdc_end';

  END IF;

/* Get the annualization factor for the different periods */
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                        (p_period_type => l_parameter_rec.page_period_type);

/* Get current period turnover totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_turnover
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_curr_start_date,
         p_to_date          => l_parameter_rec.time_curr_end_date,
         p_period_type      => l_parameter_rec.page_period_type,
         p_comparison_type  => l_parameter_rec.time_comparison_type,
         p_total_type       => 'ROLLUP',
         p_wkth_wktyp_sk_fk => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_trn_vol    => l_curr_term_vol,
         p_total_trn_invol  => l_curr_term_invol);

/* Get previous period turnover totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_turnover
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_comp_start_date,
         p_to_date          => l_parameter_rec.time_comp_end_date,
         p_period_type      => l_parameter_rec.page_period_type,
         p_comparison_type  => l_parameter_rec.time_comparison_type,
         p_total_type       => 'ROLLUP',
         p_wkth_wktyp_sk_fk => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_trn_vol    => l_comp_term_vol,
         p_total_trn_invol  => l_comp_term_invol);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_SQL2');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.include_sep_vol := 'Y';
  l_wcnt_chg_fact_params.include_sep_inv := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_SQL2');

/* Format report query */
l_sqltext :=
'SELECT    -- Turnover Portlet
 a.id                VIEWBYID
,a.value             VIEWBY
,a.value             HRI_P_PER_SUP_LNAME_CN
,a.order_by          HRI_P_ORDER_BY_1
,DECODE(a.direct_ind,
   1, ''' || l_drill_url2 || ''',
 ''' || l_drill_url || ''') HRI_P_DRILL_URL1
,a.anl_factor * 100 * a.curr_term_vol_hdc / a.curr_trn_div
                   HRI_P_WMV_TRN_SEP_VOL_ANL_MV
,a.anl_factor * 100 * a.curr_term_invol_hdc / a.curr_trn_div
                   HRI_P_WMV_TRN_SEP_INV_ANL_MV
,a.anl_factor * 100 * a.curr_termination_hdc / a.curr_trn_div
                   HRI_P_WMV_TRN_ANL_SUM_MV
,a.anl_factor * 100 * a.comp_termination_hdc / a.comp_trn_div
                   HRI_P_WMV_TRN_ANL_SUM_PREV_MV
,a.anl_factor * 100 * a.comp_term_vol_hdc / a.comp_trn_div
                   HRI_P_MEASURE1
,a.anl_factor * 100 * a.comp_term_invol_hdc / a.comp_trn_div
                   HRI_P_MEASURE2
,a.anl_factor * 100 * (a.curr_termination_hdc / a.curr_trn_div -
                       a.comp_termination_hdc / a.comp_trn_div)
                   HRI_P_WMV_CHNG_PCT_SUM_MV' || g_rtn ||
/* Grand total of Annualized Current Period Voluntary turnover */
',a.anl_factor * 100 * a.total_curr_trn_vol / a.total_curr_trn_div
                   HRI_P_GRAND_TOTAL1' || g_rtn ||
/* Grand total of Annualized Current Period Involuntary turnover */
',a.anl_factor * 100 * a.total_curr_trn_inv / a.total_curr_trn_div
                   HRI_P_GRAND_TOTAL2' || g_rtn ||
/* Grand total of Annualized Current Period Total turnover */
',a.anl_factor * 100 * a.total_curr_trn_tot / a.total_curr_trn_div
                   HRI_P_GRAND_TOTAL3' || g_rtn ||
/* Grand total of Annualized Prior Period Total turnover */
',a.anl_factor * 100 * a.total_comp_trn_tot / a.total_comp_trn_div
                   HRI_P_GRAND_TOTAL4' || g_rtn ||
/* Grand total of Annualized Turnover Change Percentage */
',a.anl_factor * 100 * (a.total_curr_trn_tot / total_curr_trn_div -
                        a.total_comp_trn_tot / total_comp_trn_div)
                   HRI_P_GRAND_TOTAL5' || g_rtn ||
/* Grand total of Annualized Prior Period Voluntary turnover */
',a.anl_factor * 100 * a.total_comp_trn_vol / a.total_comp_trn_div
                   HRI_P_GRAND_TOTAL6' || g_rtn ||
/* Grand total of Annualized Prior Period Involuntary turnover */
',a.anl_factor * 100 * a.total_comp_trn_inv / a.total_comp_trn_div
                   HRI_P_GRAND_TOTAL7
FROM
(SELECT
  tots.* ' || g_rtn ||
/* Headcount change */
' ,DECODE(tots.comp_hdc_end,
    0, 0,
  100 * (tots.curr_hdc_end - tots.comp_hdc_end) / tots.comp_hdc_end)
      hdc_change_pct' || g_rtn ||
/* Terminations Factor */
' ,DECODE(tots.curr_hdc_trn,
    0, DECODE(tots.curr_termination_hdc, 0 , 1, tots.curr_termination_hdc),
  tots.curr_hdc_trn)  curr_trn_div
 ,DECODE(tots.comp_hdc_trn,
    0, DECODE(tots.comp_termination_hdc, 0 , 1, tots.comp_termination_hdc),
  tots.comp_hdc_trn)  comp_trn_div
 ,:HRI_ANL_FACTOR  anl_factor' || g_rtn ||
/* Grand Totals - Terminations */
' ,DECODE(tots.total_curr_hdc_trn,
    0, DECODE(tots.total_curr_trn_tot, 0 , 1, tots.total_curr_trn_tot),
  tots.total_curr_hdc_trn)  total_curr_trn_div
 ,DECODE(tots.total_comp_hdc_trn,
    0, DECODE(tots.total_comp_trn_tot, 0 , 1, tots.total_comp_trn_tot),
  tots.total_comp_hdc_trn)  total_comp_trn_div
 FROM
 (SELECT
   vby.id
  ,DECODE(wmv.direct_ind,
            1, ''' || l_direct_reports_string || ''',
          vby.value)  value
  ,to_char(wmv.direct_ind) || vby.order_by  order_by' || g_rtn ||
/* Indicators */
'  ,wmv.direct_ind' || g_rtn ||
/* Headcount */
'  ,wmv.curr_hdc_end
 ,wmv.comp_hdc_end' || g_rtn ||
/* Headcount for turnover calculation */
'  ,' || l_col_curr_trn_hdc || '  curr_hdc_trn
  ,'  || l_col_comp_trn_hdc || '  comp_hdc_trn' || g_rtn ||
/* Turnover */
'  ,NVL(trn.curr_sep_vol_hdc, 0)     curr_term_vol_hdc
  ,NVL(trn.curr_sep_invol_hdc, 0)   curr_term_invol_hdc
  ,NVL(trn.curr_separation_hdc, 0)  curr_termination_hdc
  ,NVL(trn.comp_sep_vol_hdc, 0)     comp_term_vol_hdc
  ,NVL(trn.comp_sep_invol_hdc, 0)   comp_term_invol_hdc
  ,NVL(trn.comp_separation_hdc, 0)  comp_termination_hdc' || g_rtn ||
/* Grand Totals - Headcount */
'  ,SUM(wmv.curr_hdc_end) OVER ()  curr_total_hdc_end
  ,SUM(wmv.comp_total_hdc_end) OVER ()  comp_total_hdc_end' || g_rtn ||
/* Grand Totals - Headcount for turnover calculation */
'  ,SUM(' || l_col_curr_tot_trn_hdc || ') OVER ()  total_curr_hdc_trn
  ,SUM('  || l_col_comp_tot_trn_hdc || ') OVER ()  total_comp_hdc_trn' || g_rtn ||
/* Grand Totals - Turnover */
'  ,:HRI_CURR_TERM_VOL                        total_curr_trn_vol
  ,:HRI_CURR_TERM_INVOL                      total_curr_trn_inv
  ,:HRI_CURR_TERM_INVOL + :HRI_CURR_TERM_VOL total_curr_trn_tot
  ,:HRI_COMP_TERM_VOL                        total_comp_trn_vol
  ,:HRI_COMP_TERM_INVOL                      total_comp_trn_inv
  ,:HRI_COMP_TERM_VOL + :HRI_COMP_TERM_INVOL total_comp_trn_tot
  FROM
   hri_dbi_cl_per_n_v  vby
  ,(' || l_wrkfc_fact_sql    || ')  wmv
  ,(' || l_wcnt_chg_fact_sql || ')  trn
  WHERE wmv.vby_id = trn.vby_id (+)
  AND wmv.vby_id = vby.id
  AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date
 ) tots
 WHERE (tots.curr_hdc_end > 0
     OR tots.comp_termination_hdc > 0
     OR tots.curr_termination_hdc > 0
     OR tots.direct_ind = 1)
) a
WHERE 1 = 1
' || l_security_clause || '
&ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_ANL_FACTOR';
  l_custom_rec.attribute_value := l_calc_anl_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_VOL';
  l_custom_rec.attribute_value := l_curr_term_vol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_INVOL';
  l_custom_rec.attribute_value := l_curr_term_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_VOL';
  l_custom_rec.attribute_value := l_comp_term_vol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TERM_INVOL';
  l_custom_rec.attribute_value := l_comp_term_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END get_sql2;

/******************************************************************************/
/* Annualized Turnover Status Portlet                                         */
/******************************************************************************/
PROCEDURE get_actual_detail_sql2
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Variables for SQL returned */
  l_sqltext                 VARCHAR2(30000) ;
  l_security_clause         VARCHAR2(4000);
  l_custom_rec              BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Annualization factor for period type parameter */
  l_calc_anl_factor         NUMBER;

/* Pre-calculations */
  l_curr_term_vol             NUMBER;
  l_curr_term_invol           NUMBER;
  l_comp_term_vol             NUMBER;
  l_comp_term_invol           NUMBER;

/* selective drill across urls */
  l_drill_url1            VARCHAR2(300);
  l_drill_url2            VARCHAR2(300);
  l_drill_url3            VARCHAR2(300);
  l_drill_url4            VARCHAR2(300);
  l_drill_url5            VARCHAR2(300);

/* Columns */
  l_col_curr_trn_hdc          VARCHAR2(100);
  l_col_comp_trn_hdc          VARCHAR2(100);
  l_col_curr_tot_trn_hdc      VARCHAR2(100);
  l_col_comp_tot_trn_hdc      VARCHAR2(100);

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Messages */
  l_direct_reports_string  VARCHAR2(100);

BEGIN

/* define the selective drill across urls */
  l_drill_url1 := 'pFunctionName=HRI_P_WMV_TRN_SUP_PVT&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';

  l_drill_url2 := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                  'HRI_WRKACTVT+HRI_WAC_SEPCAT_X=SEP_VOL&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url3 := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                  'HRI_WRKACTVT+HRI_WAC_SEPCAT_X=SEP_INV&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url4 := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                  'HRI_WRKACTVT+HRI_WAC_SEPCAT_X=ALL&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url5 := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Turnover calculation method is either start/end average or end value */
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN

  /* Set Column Strings */
    l_col_curr_trn_hdc := '(wmv.curr_hdc_end + wmv.curr_hdc_start) / 2';
    l_col_curr_tot_trn_hdc := '(wmv.curr_hdc_end + wmv.curr_total_hdc_start) / 2';

  ELSE

  /* Set Column Strings */
    l_col_curr_trn_hdc := 'wmv.curr_hdc_end';
    l_col_curr_tot_trn_hdc := 'wmv.curr_hdc_end';

  END IF;

/* Get the annualization factor for the different periods */
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                        (p_period_type => l_parameter_rec.page_period_type);

/* Get current period turnover totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_turnover
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_curr_start_date,
         p_to_date          => l_parameter_rec.time_curr_end_date,
         p_period_type      => l_parameter_rec.page_period_type,
         p_comparison_type  => l_parameter_rec.time_comparison_type,
         p_total_type       => 'ROLLUP',
         p_wkth_wktyp_sk_fk => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_trn_vol    => l_curr_term_vol,
         p_total_trn_invol  => l_curr_term_invol);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_ACTUAL_DETAIL_SQL2');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.include_sep_vol := 'Y';
  l_wcnt_chg_fact_params.include_sep_inv := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_ACTUAL_DETAIL_SQL2');

/* Set the default order by */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                               (p_order_by_clause => l_parameter_rec.order_by);

/* Build SQL Query */
  l_SQLText :=
'SELECT  -- Turnover Status
 a.id                       VIEWBYID
,a.value                    VIEWBY ' || g_rtn ||
/* Order by default person sort name */
',a.order_by                HRI_P_ORDER_BY_1 ' || g_rtn ||
',a.value                   HRI_P_CHAR1_GA' || g_rtn ||
',DECODE(a.direct_ind,
           1, ''' || l_drill_url5 || ''',
         ''' || l_drill_url1 || ''') HRI_P_DRILL_URL1' || g_rtn ||
/* WMV value at current period start */
',a.curr_hdc_start          HRI_P_MEASURE1 ' || g_rtn ||
/* WMV value at current period end */
',a.curr_hdc_end            HRI_P_MEASURE2 ' || g_rtn ||
/* Voluntary separations */
',a.curr_term_vol_hdc       HRI_P_MEASURE3 ' || g_rtn ||
','''|| l_drill_url2 || ''' HRI_P_DRILL_URL2' || g_rtn ||
/* Annualized voluntary separations as a percentage of calculated WMV */
',a.anl_factor * 100 * a.curr_term_vol_hdc / a.curr_trn_div
                            HRI_P_MEASURE3_MP ' || g_rtn ||
/* Involuntary separations */
',a.curr_term_invol_hdc     HRI_P_MEASURE4 ' || g_rtn ||
','''|| l_drill_url3 || ''' HRI_P_DRILL_URL3' || g_rtn ||
/* Annualized involuntary separations as a percentage of calculated WMV */
',a.anl_factor * 100 * a.curr_term_invol_hdc / a.curr_trn_div
                            HRI_P_MEASURE4_MP ' || g_rtn ||
/* Total separations */
',a.curr_termination_hdc    HRI_P_MEASURE5 ' || g_rtn ||
','''|| l_drill_url4 || ''' HRI_P_DRILL_URL4' || g_rtn ||
/* Total annualized separations as a percentage of calculated WMV */
',a.anl_factor * 100 * a.curr_termination_hdc / a.curr_trn_div
                            HRI_P_MEASURE5_MP ' || g_rtn ||
/* Grand total of Start Headcount as of start date for a top supervisor_id */
',a.curr_total_hdc_start    HRI_P_GRAND_TOTAL1 ' || g_rtn ||
/* Grand total of End Headcount as of end date for a top supervisor_id */
',a.curr_total_hdc_end      HRI_P_GRAND_TOTAL2 ' || g_rtn ||
/* Grand total of Vol Headcount as of end date for a top supervisor_id  */
',a.total_curr_trn_vol      HRI_P_GRAND_TOTAL3 ' || g_rtn ||
/* Grand total of Vol Headcount Percent as of end date for a top supervisor_id  */
',a.anl_factor * 100 * a.total_curr_trn_vol / a.total_curr_trn_div
                            HRI_P_GRAND_TOTAL4 ' || g_rtn ||
/* Grand total of Invol Headcount as of end date for a top supervisor_id  */
',a.total_curr_trn_inv      HRI_P_GRAND_TOTAL5 ' || g_rtn ||
/* Grand total of Invol Headcount Percent as of end date for a top supervisor_id  */
',a.anl_factor * 100 * a.total_curr_trn_inv / a.total_curr_trn_div
                            HRI_P_GRAND_TOTAL6 ' || g_rtn ||
/* Grand total of vol and invol Headcount as of end date for a top supervisor_id  */
',a.total_curr_trn_tot      HRI_P_GRAND_TOTAL7 ' || g_rtn ||
/* Grand total of vol and Invol Headcount Percent as of end date for a top supervisor_id  */
',a.anl_factor * 100 * a.total_curr_trn_tot / a.total_curr_trn_div
                            HRI_P_GRAND_TOTAL8 ' || g_rtn ||
/* Whether the row is a rolled up supervisor (Y) or direct report (N) */
',DECODE(a.direct_ind,
           1, ''N'',
         '''')             HRI_P_SUPH_RO_CA
FROM
(SELECT
  tots.* ' || g_rtn ||
/* Terminations Factor */
' ,DECODE(tots.curr_hdc_trn,
    0, DECODE(tots.curr_termination_hdc, 0 , 1, tots.curr_termination_hdc),
  tots.curr_hdc_trn)  curr_trn_div
 ,:HRI_ANL_FACTOR  anl_factor' || g_rtn ||
/* Grand Totals - Terminations */
' ,DECODE(tots.total_curr_hdc_trn,
    0, DECODE(tots.total_curr_trn_tot, 0 , 1, tots.total_curr_trn_tot),
  tots.total_curr_hdc_trn)  total_curr_trn_div
 FROM
 (SELECT
   vby.id
  ,DECODE(wmv.direct_ind,
            1, ''' || l_direct_reports_string || ''',
          vby.value)  value
  ,to_char(wmv.direct_ind) || vby.order_by  order_by' || g_rtn ||
/* Indicators */
'  ,wmv.direct_ind' || g_rtn ||
/* Headcount */
'  ,wmv.curr_hdc_end
   ,wmv.curr_hdc_start' || g_rtn ||
/* Headcount for turnover calculation */
'  ,' || l_col_curr_trn_hdc || '  curr_hdc_trn' || g_rtn ||
/* Turnover */
'  ,NVL(trn.curr_sep_vol_hdc, 0)     curr_term_vol_hdc
  ,NVL(trn.curr_sep_invol_hdc, 0)   curr_term_invol_hdc
  ,NVL(trn.curr_separation_hdc, 0)  curr_termination_hdc' || g_rtn ||
/* Grand Totals - Headcount */
'  ,SUM(wmv.curr_hdc_end)   OVER ()  curr_total_hdc_end
  ,SUM(wmv.curr_total_hdc_start) OVER ()  curr_total_hdc_start' || g_rtn ||
/* Grand Totals - Headcount for turnover calculation */
'  ,SUM(' || l_col_curr_tot_trn_hdc || ') OVER ()  total_curr_hdc_trn' || g_rtn ||
/* Grand Totals - Turnover */
'  ,:HRI_CURR_TERM_VOL                        total_curr_trn_vol
  ,:HRI_CURR_TERM_INVOL                      total_curr_trn_inv
  ,:HRI_CURR_TERM_INVOL + :HRI_CURR_TERM_VOL total_curr_trn_tot
  FROM
   hri_dbi_cl_per_n_v  vby
  ,(' || l_wrkfc_fact_sql    || ')  wmv
  ,(' || l_wcnt_chg_fact_sql || ')  trn
  WHERE wmv.vby_id = trn.vby_id (+)
  AND wmv.vby_id = vby.id
  AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date
 ) tots
 WHERE (tots.curr_hdc_end > 0
     OR tots.curr_hdc_start > 0
     OR tots.curr_term_vol_hdc > 0
     OR tots.curr_term_invol_hdc > 0
     OR tots.direct_ind = 1)
) a
WHERE 1 = 1
' || l_security_clause || '
ORDER BY ' || l_parameter_rec.order_by;

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_ANL_FACTOR';
  l_custom_rec.attribute_value := l_calc_anl_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_VOL';
  l_custom_rec.attribute_value := l_curr_term_vol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TERM_INVOL';
  l_custom_rec.attribute_value := l_curr_term_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END get_actual_detail_sql2;

PROCEDURE GET_SQL_TRN_PVT(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql          OUT NOCOPY VARCHAR2,
                  x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText               VARCHAR2(32767) ;
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL */
  l_security_clause           VARCHAR2(4000);
  l_termination_count_filter  VARCHAR2(100);
  l_view_by_filter            VARCHAR2(1000);
  l_outer_join                VARCHAR2(30);

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Messages */
  l_direct_reports_string   VARCHAR2(100);

/* Drill URLs */
  l_sup_drill_url           VARCHAR2(1000);
  l_dir_drill_url           VARCHAR2(1000);
  l_vb_sup_drill_url        VARCHAR2(1000);
  l_vb_drill_mgr_dir        VARCHAR2(1000);

/* Pre-calculations for turnover total */
  l_curr_trn_vol         NUMBER;
  l_curr_trn_invol       NUMBER;
  l_comp_trn_vol         NUMBER;
  l_comp_trn_invol       NUMBER;
  l_dummy1               NUMBER;

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

/* Get current period turnover totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_term_pvt
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_curr_start_date,
         p_to_date          => l_parameter_rec.time_curr_end_date,
         p_bind_tab         => l_bind_tab,
         p_total_term_vol   => l_curr_trn_vol,
         p_total_term_invol => l_curr_trn_invol,
         p_total_term       => l_dummy1);

/* Get previous period turnover totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_term_pvt
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_comp_start_date,
         p_to_date          => l_parameter_rec.time_comp_end_date,
         p_bind_tab         => l_bind_tab,
         p_total_term_vol   => l_comp_trn_vol,
         p_total_term_invol => l_comp_trn_invol,
         p_total_term       => l_dummy1);

/* Setup any drill urls */
  l_sup_drill_url := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'pParamIds=Y';
  l_dir_drill_url := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'HRI_P_SUPH_RO_CA=N&'  ||
                     'pParamIds=Y';

-- ----------------------
-- View by Person, enable different drill urls on viewby
-- ----------------------
  IF (l_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
     l_vb_sup_drill_url := 'pFunctionName=HRI_P_WMV_TRN_PVT&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'pParamIds=Y';

     l_vb_drill_mgr_dir := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'HRI_P_SUPH_RO_CA=N&' ||
                                  'pParamIds=Y';
  END IF;

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_SQL_PVT');

/* Check the view by for a terminations only report */
/* If the viewby is NOT terminations only then join to workforce */
  IF (l_parameter_rec.view_by <> 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' AND
      l_parameter_rec.view_by <> 'HRI_REASON+HRI_RSN_SEP_X') THEN

  /* Get SQL for workforce fact */
    l_wrkfc_fact_params.bind_format := 'PMV';
    l_wrkfc_fact_params.include_hdc := 'Y';
    l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
     (p_parameter_rec  => l_parameter_rec,
      p_bind_tab       => l_bind_tab,
      p_wrkfc_params   => l_wrkfc_fact_params,
      p_calling_module => 'HRI_OLTP_PMV_WMV_TRN_SUP.GET_SQL_PVT');

  /* Set the display row conditions */
    IF (l_parameter_rec.view_by = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_rec.view_by = 'HRI_LOW+HRI_LOW_BAND_X') THEN
      l_outer_join := ' (+)';
    /* Set the view by filter */
      l_view_by_filter := hri_oltp_pmv_util_pkg.set_viewby_filter
              (p_parameter_rec => l_parameter_rec,
               p_bind_tab => l_bind_tab,
               p_view_by_alias => 'cl');
    ELSE
    /* Only display rows with current headcount */
      l_termination_count_filter :=
  'AND (a.curr_termination_hdc > 0
    OR a.curr_hdc_end > 0
    OR a.direct_ind = 1)' || g_rtn;
    END IF;

/* Else if the view by is a terminations only report, set the outer */
/* join for the separation category view by */
  ELSIF (l_parameter_rec.view_by = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    l_outer_join := ' (+)';
   l_termination_count_filter :=
  'AND a.vby_id IN (''SEP_VOL'',''SEP_INV'')' || g_rtn;

  /* Set the view by filter */
    l_view_by_filter := hri_oltp_pmv_util_pkg.set_viewby_filter
            (p_parameter_rec => l_parameter_rec,
             p_bind_tab => l_bind_tab,
             p_view_by_alias => 'cl');

/* Else set the filter for a terminations only report */
  ELSE
    l_termination_count_filter :=
  'AND (a.curr_termination_hdc > 0
    OR a.comp_termination_hdc > 0)' || g_rtn;

  END IF;

 /* Set any additional viewby conditions */
  IF (l_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    l_view_by_filter :=
 'AND &BIS_CURRENT_ASOF_DATE BETWEEN cl.start_date AND cl.end_date' || g_rtn;
  END IF;

/* Return AK Sql To PMV */
 l_SQLText    :=
'SELECT -- Terminations Status
 a.order_by        HRI_P_ORDER_BY_1
,a.vby_id          VIEWBYID
,DECODE(a.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB
,DECODE(a.direct_ind,
          1, ''' || l_vb_drill_mgr_dir || ''',
        ''' || l_vb_sup_drill_url || ''')  HRI_P_DRILL_URL2
,a.vby_value       VIEWBY
,a.curr_termination_hdc         HRI_P_MEASURE1
,DECODE(a.direct_ind,
          1, ''' || l_dir_drill_url || ''',
        ''' || l_sup_drill_url || ''')  HRI_P_DRILL_URL1
,a.comp_termination_hdc         HRI_P_MEASURE2
,DECODE(a.comp_termination_hdc,
          0, DECODE(a.curr_termination_hdc, 0, 0, 100),
        (a.curr_termination_hdc - a.comp_termination_hdc) * 100 /
        a.comp_termination_hdc)  HRI_P_MEASURE1_MP
,a.curr_total_term_hdc     HRI_P_GRAND_TOTAL1
,a.comp_total_term_hdc     HRI_P_GRAND_TOTAL2
,DECODE(a.comp_total_term_hdc,
          0, DECODE(a.curr_total_term_hdc, 0, 0, 100),
        (a.curr_total_term_hdc - a.comp_total_term_hdc) * 100 /
         a.comp_total_term_hdc)  HRI_P_GRAND_TOTAL1_MP
FROM' || g_rtn;

/* Check the view by for a terminations only report */
/* If the view by is NOT terminations only join to workforce */
  IF (l_parameter_rec.view_by <> 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' AND
      l_parameter_rec.view_by <> 'HRI_REASON+HRI_RSN_SEP_X') THEN

    l_sqltext := l_sqltext ||
'(SELECT
  cl.id  vby_id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         cl.value)  vby_value
 ,NVL(wmv.direct_ind, 0)  direct_ind
 ,to_char(NVL(wmv.direct_ind, 0)) || cl.order_by  order_by
 ,NVL(wmv.curr_hdc_end, 0)  curr_hdc_end
 ,NVL(trn.curr_separation_hdc, 0)  curr_termination_hdc
 ,NVL(trn.comp_separation_hdc, 0)  comp_termination_hdc
 ,:HRI_CURR_TERM_HDC     curr_total_term_hdc
 ,:HRI_PREV_TERM_HDC     comp_total_term_hdc
 FROM
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
       (l_parameter_rec.view_by).viewby_table || '  cl
 ,(' || l_wcnt_chg_fact_sql || ')  trn
 ,(' || l_wrkfc_fact_sql || ')  wmv
 WHERE cl.id = wmv.vby_id' || l_outer_join || '
 AND wmv.vby_id = trn.vby_id (+) ' || g_rtn ||
 l_view_by_filter ||
') a
WHERE 1 = 1
' || l_security_clause || g_rtn ||
 l_termination_count_filter ||
'ORDER BY ' || l_parameter_rec.order_by;

/* Otherwise get terminations data only */
  ELSE
    l_sqltext := l_sqltext ||
'(SELECT
  cl.id  vby_id
 ,DECODE(trn.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         cl.value)  vby_value
 ,NVL(trn.direct_ind, 0)  direct_ind
 ,to_char(NVL(trn.direct_ind, 0)) || cl.order_by  order_by
 ,NVL(trn.curr_separation_hdc, 0)  curr_termination_hdc
 ,NVL(trn.comp_separation_hdc, 0)  comp_termination_hdc
 ,:HRI_CURR_TERM_HDC     curr_total_term_hdc
 ,:HRI_PREV_TERM_HDC     comp_total_term_hdc
 FROM
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
       (l_parameter_rec.view_by).viewby_table || '  cl
 ,(' || l_wcnt_chg_fact_sql || ')  trn
 WHERE cl.id = trn.vby_id ' || l_outer_join || g_rtn ||
 l_view_by_filter ||
') a
WHERE 1 = 1
' || l_security_clause || g_rtn ||
 l_termination_count_filter ||
'ORDER BY ' || l_parameter_rec.order_by;

  END IF;

 x_custom_sql := l_SQLText;

/* Binds Will be inserted Below */
  l_custom_rec.attribute_name := ':HRI_CURR_TERM_HDC';
  l_custom_rec.attribute_value := l_curr_trn_vol + l_curr_trn_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_PREV_TERM_HDC';
  l_custom_rec.attribute_value := l_comp_trn_vol + l_comp_trn_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END GET_SQL_TRN_PVT;

--
-- ----------------------------------------------------------------------
-- Procedure to fetch the termination KPI
-- It fetched the values for the following KPIs
--  1. Current Terminations
--  2. Previous Terminations
--  3. Current average length of service
--  4. Previous average length of service
-- -----------------------------------------------------------------------
--
PROCEDURE get_trn_los_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  --
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  --
  -- The security clause
  --
  l_security_clause      VARCHAR2(4000);
  --
  -- Inner SQL
  --
  l_inn_sql              VARCHAR2(32767);
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

BEGIN
  --
  x_custom_output   := BIS_QUERY_ATTRIBUTES_TBL();
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');
  --
  -- Get the parameter information from the page parameter table
  --
  hri_oltp_pmv_util_param.get_parameters_from_table
            (p_page_parameter_tbl  => p_page_parameter_tbl,
             p_parameter_rec       => l_parameter_rec,
            p_bind_tab             => l_bind_tab);
  --
  -- Set the parameters for getting the inner SQL
  --
  l_wcnt_chg_params.bind_format   := 'PMV';
  l_wcnt_chg_params.include_comp  := 'Y';
  l_wcnt_chg_params.include_sep   := 'Y';
  l_wcnt_chg_params.include_low   := 'Y';
  l_wcnt_chg_params.kpi_mode      := 'Y';
  --
  -- Get the inner SQL
  --
  l_inn_sql := HRI_OLTP_PMV_QUERY_WCNT_CHG.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wcnt_chg_params  => l_wcnt_chg_params,
                  p_calling_module   => 'get_trn_kpi');
  --
  -- Form the SQL
  --
  x_custom_sql :='
SELECT -- Terminations KPI
 qry.vby_id        VIEWBYID
,qry.vby_id        VIEWBY
,qry.curr_separation_hdc   HRI_P_MEASURE1
,qry.comp_separation_hdc   HRI_P_MEASURE2
,DECODE(qry.curr_separation_hdc,
          0, 0,
        qry.curr_low_months / (12 * qry.curr_separation_hdc))
                   HRI_P_MEASURE4
,DECODE(qry.comp_separation_hdc,
          0, 0,
        qry.comp_low_months / (12 * qry.comp_separation_hdc))
                   HRI_P_MEASURE5
,qry.curr_separation_hdc  HRI_P_GRAND_TOTAL1
,qry.comp_separation_hdc  HRI_P_GRAND_TOTAL2
,DECODE(qry.curr_separation_hdc,
          0, 0,
        qry.curr_low_months / (12 * qry.curr_separation_hdc))
                   HRI_P_GRAND_TOTAL4
,DECODE(qry.comp_separation_hdc,
          0, 0,
        qry.comp_low_months / (12 * qry.comp_separation_hdc))
                   HRI_P_GRAND_TOTAL5
FROM
 ('||l_inn_sql||') qry
WHERE 1=1
' || l_security_clause;
  --
END get_trn_los_kpi;
--
-- ----------------------------------------------------------------------
-- Procedure to fetch the termination by separation type KPI
-- It fetched the values for the following KPIs
--  1. Total Terminations
--  2. Voluntary Terminations
--  3. Involuntary terminations
-- -----------------------------------------------------------------------
--
PROCEDURE get_wmv_trn_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql         OUT NOCOPY VARCHAR2,
                          x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
  --
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  --
  -- The security clause
  --
  l_security_clause      VARCHAR2(4000);
  l_calc_anl_factor      NUMBER;
  --
  -- Inner SQL for termination
  --
  l_trn_sql              VARCHAR2(32767);
  --
  -- Inner SQL for headcount
  --
  l_hdc_sql              VARCHAR2(32767);
  --
  -- Page parameters
  --
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  --
  -- Bind values for SQL and PMV mode
  --
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  --
  -- Parameter values for getting the inner SQL for termination
  --
  l_wcnt_chg_params         hri_bpl_fact_sup_wcnt_chg_sql.WCNT_CHG_FACT_PARAM_TYPE;
  --
  -- Parameter values for getting the inner SQL for headcount
  --
  l_wrkfc_params         hri_bpl_fact_sup_wrkfc_sql.WRKFC_FACT_PARAM_TYPE;
  --

  l_curr_hdc_end_col VARCHAR2(100);
  l_comp_hdc_end_col VARCHAR2(100);

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
  -- Get the annualization factor
  --
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                        (p_period_type => l_parameter_rec.page_period_type);
  --
  -- Set the parameters for getting the inner SQL for termination
  --
  l_wcnt_chg_params.bind_format     := 'PMV';
  l_wcnt_chg_params.include_comp    := 'Y';
  l_wcnt_chg_params.include_sep     := 'Y';
  l_wcnt_chg_params.include_sep_inv := 'Y';
  l_wcnt_chg_params.include_sep_vol := 'Y';
  l_wcnt_chg_params.kpi_mode        := 'Y';

  -- bug 4294146
  -- Check the Turnover Profile option and change dynamic calculations
  -- columns in the report SQL statement
  --
  IF fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG' THEN
    -- use average turnover headcount calculation method
    l_curr_hdc_end_col := '((hdc.curr_hdc_start+hdc.curr_hdc_end)/2)';
    l_comp_hdc_end_col := '((hdc.comp_hdc_start+hdc.comp_hdc_end)/2)';

  ELSE
    -- use end headcount turnover calculation method
    l_curr_hdc_end_col := 'hdc.curr_hdc_end';
    l_comp_hdc_end_col := 'hdc.comp_hdc_end';

  END IF;


  --
  -- Get the inner SQL for termination
  --
  l_trn_sql := HRI_OLTP_PMV_QUERY_WCNT_CHG.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wcnt_chg_params  => l_wcnt_chg_params,
                  p_calling_module   => 'hri_oltp_pmv_wmv_trn_sup.get_wmv_trn_kpi');
  --
  -- Set the parameters for getting the inner SQL for headcount
  --
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_comp  := 'Y';
  l_wrkfc_params.include_start := 'Y';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.include_sal   := 'N';
  l_wrkfc_params.include_low   := 'N';
  l_wrkfc_params.kpi_mode      := 'Y';
  l_wrkfc_params.bucket_dim    := '';
  --
  -- Get the inner SQL for headcount
  --
  l_hdc_sql := HRI_OLTP_PMV_QUERY_WRKFC.get_sql
                     (p_parameter_rec    => l_parameter_rec,
                      p_bind_tab         => l_bind_tab,
                      p_wrkfc_params     => l_wrkfc_params,
                      p_calling_module   => 'hri_oltp_pmv_wmv_trn_sup.get_wmv_trn_kpi');
 --
 -- Form the SQL
 --
 x_custom_sql := '
SELECT -- Terminations by Separation KPI
 a.vby_id   VIEWBYID
,a.vby_id   VIEWBY
,a.anl_factor * 100 * a.curr_separation_hdc / a.curr_trn_div  HRI_P_MEASURE1
,a.anl_factor * 100 * a.comp_separation_hdc / a.comp_trn_div  HRI_P_MEASURE2
,a.anl_factor * 100 * a.curr_sep_vol_hdc / a.curr_trn_div     HRI_P_MEASURE4
,a.anl_factor * 100 * a.comp_sep_vol_hdc / a.comp_trn_div     HRI_P_MEASURE5
,a.anl_factor * 100 * a.curr_sep_invol_hdc / a.curr_trn_div   HRI_P_MEASURE7
,a.anl_factor * 100 * a.comp_sep_invol_hdc / a.comp_trn_div   HRI_P_MEASURE8
,a.anl_factor * 100 * a.curr_separation_hdc / a.curr_trn_div  HRI_P_GRAND_TOTAL1
,a.anl_factor * 100 * a.comp_separation_hdc / a.comp_trn_div  HRI_P_GRAND_TOTAL2
,a.anl_factor * 100 * a.curr_sep_vol_hdc / a.curr_trn_div     HRI_P_GRAND_TOTAL4
,a.anl_factor * 100 * a.comp_sep_vol_hdc / a.comp_trn_div     HRI_P_GRAND_TOTAL5
,a.anl_factor * 100 * a.curr_sep_invol_hdc / a.curr_trn_div   HRI_P_GRAND_TOTAL7
,a.anl_factor * 100 * a.comp_sep_invol_hdc / a.comp_trn_div   HRI_P_GRAND_TOTAL8
FROM
 (SELECT
   hdc.vby_id
  ,NVL(trn.curr_separation_hdc, 0)  curr_separation_hdc
  ,NVL(trn.curr_sep_invol_hdc, 0)   curr_sep_invol_hdc
  ,NVL(trn.curr_sep_vol_hdc, 0)     curr_sep_vol_hdc
  ,NVL(trn.comp_separation_hdc, 0)  comp_separation_hdc
  ,NVL(trn.comp_sep_invol_hdc, 0)   comp_sep_invol_hdc
  ,NVL(trn.comp_sep_vol_hdc, 0)     comp_sep_vol_hdc
  ,DECODE(' || l_curr_hdc_end_col || ',
    0, DECODE(trn.curr_separation_hdc, 0 , 1, trn.curr_separation_hdc),
  ' || l_curr_hdc_end_col || ')     curr_trn_div
  ,DECODE(' || l_comp_hdc_end_col || ',
    0, DECODE(trn.comp_separation_hdc, 0 , 1, trn.comp_separation_hdc),
  ' || l_comp_hdc_end_col || ')     comp_trn_div
  ,:HRI_ANL_FACTOR                  anl_factor
  FROM
   ('||l_trn_sql||') trn
  ,('||l_hdc_sql||') hdc
  WHERE hdc.vby_id = trn.vby_id (+)
 ) a
WHERE 1 = 1
' || l_security_clause;
  --
  -- Set the annualization factor
  --
  l_custom_rec.attribute_name      := ':HRI_ANL_FACTOR';
  l_custom_rec.attribute_value     := l_calc_anl_factor;
  l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1)               := l_custom_rec;
  --
END get_wmv_trn_kpi;

END hri_oltp_pmv_wmv_trn_sup;

/
