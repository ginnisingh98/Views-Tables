--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WRKFC_TRN_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WRKFC_TRN_SUMMARY" AS
/* $Header: hriopwsm.pkb 120.5 2005/10/26 07:54:31 jrstewar noship $ */

  g_rtn   VARCHAR2(5) := '
';

TYPE dynamic_sql_rec_type IS RECORD
 (
  viewby_condition       VARCHAR2(100),
  wrkfc_outer_join       VARCHAR2(5),
-- Turnover Headcount calculation
  hdc_trn_col_curr       VARCHAR2(1000),
  hdc_trn_col_comp       VARCHAR2(1000),
  hdc_trn_col_curr_tot   VARCHAR2(1000),
  hdc_trn_col_comp_tot   VARCHAR2(1000),

-- Drill URLs
  drill_mgr_sup          VARCHAR2(1000),
  drill_to_detail          VARCHAR2(1000),
  drill_trn_pvt          VARCHAR2(1000),
  drill_total_sal        VARCHAR2(1000),
-- Display row condition
  display_row_condition  VARCHAR2(1000),
-- Order by
  order_by               VARCHAR2(1000)
 );

/* Dynamically changes report SQL depending on parameters */
PROCEDURE set_dynamic_sql
      (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
       p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
       p_dynsql_rec     OUT NOCOPY dynamic_sql_rec_type) IS

BEGIN

/* Set the order by */
  p_dynsql_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                            (p_order_by_clause => p_parameter_rec.order_by);

/* Get the profile value for the turnover calculation */
  IF fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG' THEN
  /* Turnover lines are start/end headcount average */
    p_dynsql_rec.hdc_trn_col_curr :=
'NVL((wmv.curr_hdc_end + wmv.curr_hdc_start) / 2, 0)';
    p_dynsql_rec.hdc_trn_col_comp :=
'NVL((wmv.comp_hdc_end + wmv.comp_hdc_start) / 2, 0)';
    p_dynsql_rec.hdc_trn_col_curr_tot :=
'(wmv.curr_hdc_end + wmv.curr_total_hdc_start) / 2';
    p_dynsql_rec.hdc_trn_col_comp_tot :=
'(wmv.comp_total_hdc_end + wmv.comp_total_hdc_start) / 2';
  ELSE
    p_dynsql_rec.hdc_trn_col_curr := 'NVL(wmv.curr_hdc_end, 0)';
    p_dynsql_rec.hdc_trn_col_comp := 'NVL(wmv.comp_hdc_end, 0)';
    p_dynsql_rec.hdc_trn_col_curr_tot := 'wmv.curr_hdc_end';
    p_dynsql_rec.hdc_trn_col_comp_tot := 'wmv.comp_total_hdc_end';
  END IF;


/* Set drill URLs */
  p_dynsql_rec.drill_trn_pvt := 'pFunctionName=HRI_P_WAC_TRN_PVT&' ||
                                'VIEW_BY=VIEW_BY_NAME&' ||
                                'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                'pParamIds=Y';

  p_dynsql_rec.drill_to_detail := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                                  'pParamIds=Y';

  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    p_dynsql_rec.drill_mgr_sup := 'pFunctionName=HRI_P_WRKFC_TRN_SUMMARY_PVT&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'pParamIds=Y';
    p_dynsql_rec.drill_total_sal := 'pFunctionName=HRI_P_WMV_SAL_JFM_SUP&' ||
                                    'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                    'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                    'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                                    'pParamIds=Y';
  END IF;

/* Set the display row conditions */
  IF (p_parameter_rec.view_by = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
      p_parameter_rec.view_by = 'HRI_LOW+HRI_LOW_BAND_X') THEN

  /* If view by is performance or length of work display all cl view rows */
  /* regardless of whether there is any headcount or turnover */
    p_dynsql_rec.wrkfc_outer_join := '(+)';

  /* Filter if a view by parameter is set */
    p_dynsql_rec.viewby_condition := hri_oltp_pmv_util_pkg.set_viewby_filter
              (p_parameter_rec => p_parameter_rec,
               p_bind_tab => p_bind_tab,
               p_view_by_alias => 'vby');

  ELSE

  /* If Staff Summary by Manager */
    IF (p_parameter_rec.bis_region_code = 'HRI_P_WRKFC_TRN_SUMMARY') THEN

  /* Only display rows with headcount, salary or turnover current */
      p_dynsql_rec.display_row_condition :=
'AND (a.curr_hdc_end > 0
  OR a.curr_sal_end > 0
  OR a.curr_trn_vol > 0
  OR a.curr_trn_inv > 0
  OR a.direct_ind = 1)' || g_rtn;

  /* Staff Summary Status */
    ELSE

  /* Only display rows with headcount, salary or turnover current or change */
      p_dynsql_rec.display_row_condition :=
'AND (a.curr_hdc_end > 0
  OR a.curr_sal_end > 0
  OR a.comp_hdc_end > 0
  OR a.comp_sal_end > 0
  OR a.curr_trn_vol > 0
  OR a.curr_trn_inv > 0
  OR a.comp_trn_vol > 0
  OR a.comp_trn_inv > 0
  OR a.direct_ind = 1)' || g_rtn;

    END IF;

  END IF;

/* Set any additional viewby conditions */
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    p_dynsql_rec.viewby_condition :=
'AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date' || g_rtn;
  END IF;

END set_dynamic_sql;


/* Entry point for staff summary pivot report SQL */
PROCEDURE get_sql_pvt
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_security_clause      VARCHAR2(4000);
  l_direct_reports_string  VARCHAR2(100);

/* Dynamic SQL support */
  l_dynsql_rec           dynamic_sql_rec_type;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Annualization factor for period type parameter */
  l_calc_anl_factor      NUMBER;

/* Pre-calculations for turnover total */
  l_curr_term_vol        NUMBER;
  l_curr_term_invol      NUMBER;
  l_curr_term            NUMBER;
  l_comp_term_vol        NUMBER;
  l_comp_term_invol      NUMBER;
  l_comp_term            NUMBER;

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Get the annualization factor for the different periods */
  l_calc_anl_factor :=  hri_oltp_pmv_util_pkg.calc_anl_factor
    (p_period_type  => l_parameter_rec.page_period_type);

/* Set the dynamic sql portion */
  set_dynamic_sql(p_parameter_rec => l_parameter_rec,
                  p_bind_tab      => l_bind_tab,
                  p_dynsql_rec    => l_dynsql_rec);

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get the turnover total by calling the supervisor-only total function */
/* for the portlet or the all-parameter-pivot total function for the */
/* pivot report - bug 4211177 */
  IF (l_parameter_rec.bis_region_code = 'HRI_P_WRKFC_TRN_SUMMARY') THEN

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

  ELSE

  /* Get current period turnover totals for supervisor from cursor */
    hri_bpl_dbi_calc_period.calc_sup_term_pvt
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_curr_start_date,
         p_to_date          => l_parameter_rec.time_curr_end_date,
         p_bind_tab         => l_bind_tab,
         p_total_term_vol   => l_curr_term_vol,
         p_total_term_invol => l_curr_term_invol,
         p_total_term       => l_curr_term);

  /* Get previous period turnover totals for supervisor from cursor */
    hri_bpl_dbi_calc_period.calc_sup_term_pvt
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_comp_start_date,
         p_to_date          => l_parameter_rec.time_comp_end_date,
         p_bind_tab         => l_bind_tab,
         p_total_term_vol   => l_comp_term_vol,
         p_total_term_invol => l_comp_term_invol,
         p_total_term       => l_comp_term);

  END IF;

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_params.bucket_dim := '';
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN
    l_wrkfc_fact_params.include_start := 'Y';
  END IF;
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WRKFC_TRN_SUMMARY.GET_SQL_PVT');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_sep := 'Y';
  l_wcnt_chg_fact_params.include_sep_inv := 'Y';
  l_wcnt_chg_fact_params.include_sep_vol := 'Y';
  l_wcnt_chg_fact_params.bucket_dim := '';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WRKFC_TRN_SUMMARY.GET_SQL_PVT');

  l_sqltext :=
'SELECT  -- Workforce Summary Portlet (Gen)
 a.id               VIEWBYID
,a.value            VIEWBY
,DECODE(a.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB
,a.curr_hdc_end     HRI_P_MEASURE1
,a.hdc_change_pct   HRI_P_MEASURE1_MP
,DECODE(a.curr_total_hdc_end, 0, 0,
        (100 * a.curr_hdc_end) / a.curr_total_hdc_end)  ' ||
                   'HRI_P_MEASURE2
,a.comp_hdc_end     HRI_P_MEASURE3
,a.curr_sal_end     HRI_P_MEASURE4
,a.sal_change_pct   HRI_P_MEASURE4_MP
,DECODE(a.curr_total_sal_end, 0, 0,
 100 * a.curr_sal_end / a.curr_total_sal_end) HRI_P_MEASURE5
,a.comp_sal_end     HRI_P_MEASURE6
,a.curr_avg_sal     HRI_P_MEASURE7
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'a.comp_avg_sal',
        p_current_col  => 'a.curr_avg_sal') || '
                    HRI_P_MEASURE7_MP
,a.comp_avg_sal     HRI_P_MEASURE8
,a.anl_factor * 100 * a.curr_trn_vol / a.curr_trn_div  HRI_P_MEASURE9
,a.anl_factor * 100 * a.curr_trn_inv / a.curr_trn_div  HRI_P_MEASURE10
,a.anl_factor * 100 * a.curr_trn_tot / a.curr_trn_div  HRI_P_MEASURE11
,a.anl_factor * 100 * (a.curr_trn_tot / a.curr_trn_div -
 a.comp_trn_tot / a.comp_trn_div)  HRI_P_MEASURE11_MP
,a.curr_trn_vol     HRI_P_MEASURE12
,a.curr_trn_inv     HRI_P_MEASURE13
,a.curr_trn_tot     HRI_P_MEASURE14
,DECODE(a.curr_total_trn_tot, 0, 0,
 100 * a.curr_trn_tot / a.curr_total_trn_tot) HRI_P_MEASURE15
,a.curr_total_hdc_end  HRI_P_GRAND_TOTAL1
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'a.comp_total_hdc_end',
        p_current_col  => 'a.curr_total_hdc_end') || '
                       HRI_P_GRAND_TOTAL1_MP
,100                   HRI_P_GRAND_TOTAL2
,a.comp_total_hdc_end  HRI_P_GRAND_TOTAL3
,a.curr_total_sal_end  HRI_P_GRAND_TOTAL4
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'a.comp_total_sal_end',
        p_current_col  => 'a.curr_total_sal_end') || '
                       HRI_P_GRAND_TOTAL4_MP
,100                   HRI_P_GRAND_TOTAL5
,a.comp_total_sal_end  HRI_P_GRAND_TOTAL6
,a.curr_total_avg_sal  HRI_P_GRAND_TOTAL7
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'a.comp_total_avg_sal',
        p_current_col  => 'a.curr_total_avg_sal') || '
                       HRI_P_GRAND_TOTAL7_MP
,a.comp_total_avg_sal  HRI_P_GRAND_TOTAL8
,a.anl_factor * 100 * a.curr_total_trn_vol / curr_total_trn_div HRI_P_GRAND_TOTAL9
,a.anl_factor * 100 * a.curr_total_trn_inv / curr_total_trn_div HRI_P_GRAND_TOTAL10
,a.anl_factor * 100 * a.curr_total_trn_tot / curr_total_trn_div HRI_P_GRAND_TOTAL11
,a.anl_factor * 100 * (a.curr_total_trn_tot / curr_total_trn_div -
 a.comp_total_trn_tot / comp_total_trn_div) HRI_P_GRAND_TOTAL11_MP' || g_rtn ||
/* Order by person name default sort order */
',a.order_by  HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Whether the row is a supervisor rollup row */
',DECODE(a.direct_ind , 0, '''', ''N'')  HRI_P_SUPH_RO_CA' || g_rtn ||
/* Drill URLs */
',DECODE(a.direct_ind,
    0, ''' || l_dynsql_rec.drill_mgr_sup  || ''',
    1, ''' || l_dynsql_rec.drill_to_detail  || ''',
  '''')  HRI_P_DRILL_URL1
FROM
(SELECT
  tots.* ' || g_rtn ||
/* Headcount */
' ,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'tots.comp_hdc_end',
          p_current_col  => 'tots.curr_hdc_end') || '
     hdc_change_pct' || g_rtn ||
/* Salary */
' ,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'tots.comp_sal_end',
          p_current_col  => 'tots.curr_sal_end') || '
     sal_change_pct' || g_rtn ||
/* Average Salary */
' ,DECODE(tots.curr_hdc_end,
     0, to_number(null),
   tots.curr_sal_end / tots.curr_hdc_end)  curr_avg_sal
 ,DECODE(tots.comp_hdc_end,
    0, to_number(null),
  tots.comp_sal_end / tots.comp_hdc_end)  comp_avg_sal
 ,DECODE(tots.curr_hdc_trn,
    0, DECODE(tots.curr_trn_tot, 0 , 1, tots.curr_trn_tot),
  tots.curr_hdc_trn)  curr_trn_div
 ,DECODE(tots.comp_hdc_trn,
    0, DECODE(tots.comp_trn_tot, 0 , 1, tots.comp_trn_tot),
  tots.comp_hdc_trn)  comp_trn_div
 ,:HRI_ANL_FACTOR  anl_factor' || g_rtn ||
/* Grand Totals - Average Salary */
',DECODE(tots.curr_total_hdc_end,
    0, to_number(null),
  tots.curr_total_sal_end / tots.curr_total_hdc_end)  curr_total_avg_sal
 ,DECODE(tots.comp_total_hdc_end,
    0, to_number(null),
  tots.comp_total_sal_end / tots.comp_total_hdc_end)  comp_total_avg_sal
 ,DECODE(tots.curr_total_hdc_trn,
    0, DECODE(tots.curr_total_trn_tot, 0 , 1, tots.curr_total_trn_tot),
  tots.curr_total_hdc_trn)  curr_total_trn_div
 ,DECODE(tots.comp_total_hdc_trn,
    0, DECODE(tots.comp_total_trn_tot, 0 , 1, tots.comp_total_trn_tot),
  tots.comp_total_hdc_trn)  comp_total_trn_div
 FROM
 (SELECT
/* View by */
  vby.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         vby.value)  value
 ,to_char(NVL(wmv.direct_ind, 0)) || vby.order_by  order_by' || g_rtn ||
/* Indicators */
' ,NVL(wmv.direct_ind, 0)  direct_ind' || g_rtn ||
/* Headcount */
' ,NVL(wmv.curr_hdc_end, 0)  curr_hdc_end
 ,NVL(wmv.comp_hdc_end, 0)  comp_hdc_end' || g_rtn ||
/* Salary */
' ,NVL(wmv.curr_sal_end, 0)  curr_sal_end
 ,NVL(wmv.comp_sal_end, 0)  comp_sal_end' || g_rtn ||
/* Headcount for turnover calculation */
'  ,' || l_dynsql_rec.hdc_trn_col_curr ||
                     '      curr_hdc_trn
  ,' || l_dynsql_rec.hdc_trn_col_comp ||
                     '       comp_hdc_trn' || g_rtn ||
/* Turnover */
' ,NVL(trn.curr_sep_vol_hdc, 0)  curr_trn_vol
 ,NVL(trn.curr_sep_invol_hdc, 0)  curr_trn_inv
 ,NVL(trn.curr_separation_hdc, 0)  curr_trn_tot
 ,NVL(trn.comp_sep_vol_hdc, 0)  comp_trn_vol
 ,NVL(trn.comp_sep_invol_hdc, 0)  comp_trn_inv
 ,NVL(trn.comp_separation_hdc, 0)  comp_trn_tot' || g_rtn ||
/* Grand Totals - Headcount */
' ,NVL(SUM(wmv.curr_hdc_end) OVER (), 0)  curr_total_hdc_end
 ,NVL(SUM(wmv.comp_total_hdc_end) OVER (), 0)  comp_total_hdc_end' || g_rtn ||
/* Grand Totals - Salary */
' ,NVL(SUM(wmv.curr_sal_end) OVER (), 0)  curr_total_sal_end
 ,NVL(SUM(wmv.comp_total_sal_end) OVER (), 0)  comp_total_sal_end' || g_rtn ||
/* Grand Totals - Headcount for turnover calculation */
'  ,NVL(SUM(' || l_dynsql_rec.hdc_trn_col_curr_tot ||
                 ') OVER (), 0)  curr_total_hdc_trn
  ,NVL(SUM('  || l_dynsql_rec.hdc_trn_col_comp_tot ||
                 ') OVER (), 0)  comp_total_hdc_trn' || g_rtn ||
/* Grand Totals - Turnover */
' ,:HRI_CURR_TRN_VOL                       curr_total_trn_vol
 ,:HRI_CURR_TRN_INVOL                     curr_total_trn_inv
 ,:HRI_CURR_TRN_INVOL + :HRI_CURR_TRN_VOL curr_total_trn_tot
 ,:HRI_COMP_TRN_VOL                       comp_total_trn_vol
 ,:HRI_COMP_TRN_INVOL                     comp_total_trn_inv
 ,:HRI_COMP_TRN_VOL + :HRI_COMP_TRN_INVOL comp_total_trn_tot
 FROM
  ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || '  vby,
 (' || l_wcnt_chg_fact_sql || ') trn,
 (' || l_wrkfc_fact_sql || ')  wmv
 WHERE wmv.vby_id = trn.vby_id (+)
 AND wmv.vby_id ' || l_dynsql_rec.wrkfc_outer_join || ' = vby.id' || g_rtn ||
 l_dynsql_rec.viewby_condition ||
' ) tots
 ) a
WHERE 1 = 1 ' || g_rtn ||
  l_dynsql_rec.display_row_condition ||
  l_security_clause || '
ORDER BY a.direct_ind, ' || l_dynsql_rec.order_by;

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_ANL_FACTOR';
  l_custom_rec.attribute_value := l_calc_anl_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TRN_VOL';
  l_custom_rec.attribute_value := l_curr_term_vol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_CURR_TRN_INVOL';
  l_custom_rec.attribute_value := l_curr_term_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TRN_VOL';
  l_custom_rec.attribute_value := l_comp_term_vol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COMP_TRN_INVOL';
  l_custom_rec.attribute_value := l_comp_term_invol;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

END get_sql_pvt;

END hri_oltp_pmv_wrkfc_trn_summary;

/
