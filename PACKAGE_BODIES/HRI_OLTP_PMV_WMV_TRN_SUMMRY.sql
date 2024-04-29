--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_TRN_SUMMRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_TRN_SUMMRY" AS
/* $Header: hrioptsm.pkb 120.2 2005/10/26 07:54 jrstewar noship $ */

  g_rtn   VARCHAR2(5) := '
';

/******************************************************************************/
/* Turnover Pivot Setup
/******************************************************************************/

TYPE dynamic_sql_rec_type IS RECORD
 (
-- View by small dim outer join
  wrkfc_outer_join       VARCHAR2(5),
-- Turnover Headcount calculation
  hdc_trn_col_curr       VARCHAR2(1000),
  hdc_trn_col_comp       VARCHAR2(1000),
  hdc_trn_col_curr_tot   VARCHAR2(1000),
  hdc_trn_col_comp_tot   VARCHAR2(1000),
-- Drill URLs
  drill_mgr_sup          VARCHAR2(1000),
  drill_mgr_dir          VARCHAR2(1000),
  drill_trn_vol_dtl      VARCHAR2(1000),
  drill_trn_inv_dtl      VARCHAR2(1000),
  drill_trn_tot_dtl      VARCHAR2(1000),
  drill_total_sal        VARCHAR2(1000),
-- Display row condition
  display_row_condition  VARCHAR2(1000),
  view_by_filter         VARCHAR2(1000)
 );

/* Dynamically changes report SQL depending on parameters */
PROCEDURE set_dynamic_sql
      (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
       p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
       p_dynsql_rec     OUT NOCOPY dynamic_sql_rec_type) IS

BEGIN

/* Get the profile value for the turnover calculation */
  IF fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG' THEN
  /* Set the current calculation to be current start/end average */
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

/* Set drill URLs for constant drills */
  p_dynsql_rec.drill_trn_vol_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                                    'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                    'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                                    'HRI_P_WAC_SEPCAT_CN=SEP_VOL&'||
                                    'pParamIds=Y';
  p_dynsql_rec.drill_trn_inv_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                                    'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                    'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                                    'HRI_P_WAC_SEPCAT_CN=SEP_INV&'||
                                    'pParamIds=Y';
  p_dynsql_rec.drill_trn_tot_dtl := 'pFunctionName=HRI_P_WMV_TRN_SUP_DTL&' ||
                                    'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                    'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'  ||
                                    'pParamIds=Y';

-- ----------------------
-- View by Person
-- ----------------------
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN

  /* Set drill URLs */
    p_dynsql_rec.drill_mgr_sup := 'pFunctionName=HRI_P_WMV_TRN_SUMMARY_PVT&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'pParamIds=Y';
    p_dynsql_rec.drill_mgr_dir := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
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
    p_dynsql_rec.wrkfc_outer_join := ' (+)';

  /* Set the view by filter if these parameters have been set */
    p_dynsql_rec.view_by_filter := hri_oltp_pmv_util_pkg.set_viewby_filter
              (p_parameter_rec => p_parameter_rec,
               p_bind_tab => p_bind_tab,
               p_view_by_alias => 'vby');

  ELSE

  /* Only display rows with current headcount or turnover */
    p_dynsql_rec.display_row_condition :=
'AND (a.curr_hdc_end > 0
  OR a.curr_term_invol_hdc > 0
  OR a.curr_term_vol_hdc > 0
  OR a.direct_ind = 1)' || g_rtn;

  END IF;

 /* bug 4202907 append cl start AND end_date filter if viewby manager */
 IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
    p_dynsql_rec.view_by_filter := p_dynsql_rec.view_by_filter ||
        'AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date';
 END IF;

END set_dynamic_sql;

/******************************************************************************/
/* Turnover Pivot Ak Query centralized code
/******************************************************************************/

PROCEDURE get_sql_pvt
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;
  l_security_clause      VARCHAR2(4000);

/* Dynamic SQL support */
  l_dynsql_rec           dynamic_sql_rec_type;

/* Annualization factor for period type parameter */
  l_calc_anl_factor      NUMBER;

/* Pre-calculations for turnover total */
  l_curr_term_vol        NUMBER;
  l_curr_term_invol      NUMBER;
  l_curr_term            NUMBER;
  l_comp_term_vol        NUMBER;
  l_comp_term_invol      NUMBER;
  l_comp_term            NUMBER;

  -- new code centralization new variables/structures
  l_wcnt_chg_fact_sql    VARCHAR2(32767);
  l_wrkfc_fact_sql       VARCHAR2(32767);
  l_wrkfc_params         hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wcnt_chg_params      hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;

  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Messages */
  l_direct_reports_string   VARCHAR2(240);

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
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
    (p_period_type  => l_parameter_rec.page_period_type);

/* Set the dynamic sql portion */
   set_dynamic_sql(p_parameter_rec => l_parameter_rec,
                   p_bind_tab      => l_bind_tab,
                   p_dynsql_rec    => l_dynsql_rec);

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

/* Generate the Turnover Fact SQL */
  l_wcnt_chg_params.bind_format     := 'PMV';
  l_wcnt_chg_params.include_comp    := 'Y';
  l_wcnt_chg_params.include_sep     := 'Y';
  l_wcnt_chg_params.include_sep_inv := 'Y';
  l_wcnt_chg_params.include_sep_vol := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
             (p_parameter_rec   => l_parameter_rec,
              p_bind_tab        => l_bind_tab,
              p_wcnt_chg_params => l_wcnt_chg_params);

/* Generate the Workforce Fact SQL */
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.include_comp  := 'Y';
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN
    l_wrkfc_params.include_start := 'Y';
  END IF;
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
             (p_parameter_rec   => l_parameter_rec,
              p_bind_tab        => l_bind_tab,
              p_wrkfc_params => l_wrkfc_params);

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);


/* Format the AK_SQL for the report UI */
  l_sqltext :=
'SELECT  -- Workforce Turnover Summary Portlet new code
 a.id                               VIEWBYID
,a.value                            VIEWBY
,DECODE(a.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB' || g_rtn ||
/* Title - Headcount */'
,NVL(a.comp_hdc_end,0)              HRI_P_MEASURE1
,NVL(a.curr_hdc_end,0)              HRI_P_MEASURE2
,DECODE(a.curr_total_hdc_end, 0, 0,
        (100 * a.curr_hdc_end) / a.curr_total_hdc_end)  ' ||
                   '                HRI_P_MEASURE3' || g_rtn ||
/* Title - Voluntary Terminations */'
,a.curr_term_vol_hdc                     HRI_P_MEASURE4
,a.anl_factor * 100 * a.curr_term_vol_hdc / a.curr_trn_div
                                    HRI_P_MEASURE5
,a.anl_factor * 100 * (a.curr_term_vol_hdc / a.curr_trn_div -
 a.comp_term_vol_hdc / a.comp_trn_div)
                                    HRI_P_MEASURE6 ' || g_rtn ||
/* Title - InVoluntary Terminations */'
,a.curr_term_invol_hdc                     HRI_P_MEASURE7
,a.anl_factor * 100 * a.curr_term_invol_hdc / a.curr_trn_div
                                    HRI_P_MEASURE8
,a.anl_factor * 100 * (a.curr_term_invol_hdc / a.curr_trn_div -
 a.comp_term_invol_hdc / a.comp_trn_div)
                                    HRI_P_MEASURE9' || g_rtn ||
/* Title - Total Terminations */'
,a.curr_termination_hdc                     HRI_P_MEASURE10
,a.anl_factor * 100 * a.curr_termination_hdc / a.curr_trn_div
                                    HRI_P_MEASURE11
,a.anl_factor * 100 * (a.curr_termination_hdc / a.curr_trn_div -
 a.comp_termination_hdc / a.comp_trn_div)
                                    HRI_P_MEASURE12' || g_rtn ||

/* Title - Grand Total Headcount */'
,a.comp_total_hdc_end               HRI_P_GRAND_TOTAL1
,a.curr_total_hdc_end               HRI_P_GRAND_TOTAL2
,100                                HRI_P_GRAND_TOTAL3' || g_rtn ||
/* Title - Grand Total Voluntary Terminations */'
,a.curr_total_trn_vol               HRI_P_GRAND_TOTAL4
,a.anl_factor * 100 * a.curr_total_trn_vol / curr_total_trn_div
                                    HRI_P_GRAND_TOTAL5
,a.anl_factor * 100 * (a.curr_total_trn_vol / curr_total_trn_div -
 a.comp_total_trn_vol / comp_total_trn_div)
                                    HRI_P_GRAND_TOTAL6' || g_rtn ||
/* Title - Grand Total InVoluntary Terminations */'
,a.curr_total_trn_inv               HRI_P_GRAND_TOTAL7
,a.anl_factor * 100 * a.curr_total_trn_inv / curr_total_trn_div
                                    HRI_P_GRAND_TOTAL8
,a.anl_factor * 100 * (a.curr_total_trn_inv / curr_total_trn_div -
 a.comp_total_trn_inv / comp_total_trn_div)
                                    HRI_P_GRAND_TOTAL9' || g_rtn ||
/* Title - Grand Total Total Terminations */'
,a.curr_total_trn_tot               HRI_P_GRAND_TOTAL10
,a.anl_factor * 100 * a.curr_total_trn_tot / curr_total_trn_div
                                    HRI_P_GRAND_TOTAL11
,a.anl_factor * 100 * (a.curr_total_trn_tot / curr_total_trn_div -
 a.comp_total_trn_tot / comp_total_trn_div)
                                    HRI_P_GRAND_TOTAL12' || g_rtn ||
/* Order by person name default sort order */
',a.order_by                        HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Whether the row is a supervisor rollup row */
',DECODE(a.direct_ind , 0, '''', ''N'')
                                    HRI_P_SUPH_RO_CA' || g_rtn ||
/* Drill URLs */
',DECODE(a.direct_ind,
    0, ''' || l_dynsql_rec.drill_mgr_sup  || ''',
    1, ''' || l_dynsql_rec.drill_mgr_dir  || ''',
  '''')                             HRI_P_DRILL_URL1
,''' || l_dynsql_rec.drill_trn_vol_dtl || '''
		                    HRI_P_DRILL_URL2
,''' || l_dynsql_rec.drill_trn_inv_dtl || '''
                                    HRI_P_DRILL_URL3
,''' || l_dynsql_rec.drill_trn_tot_dtl || '''
                                    HRI_P_DRILL_URL4
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
' ,DECODE(tots.curr_total_hdc_trn,
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
         vby.value)     value
 ,to_char(NVL(wmv.direct_ind, 0)) || vby.order_by  order_by' || g_rtn ||
/* Indicators */
' ,NVL(wmv.direct_ind, 0)  direct_ind' || g_rtn ||
/* Headcount */
' ,NVL(wmv.curr_hdc_end, 0)  curr_hdc_end
 ,NVL(wmv.comp_hdc_end, 0)  comp_hdc_end' || g_rtn ||
/* Headcount for turnover calculation */
'  ,' || l_dynsql_rec.hdc_trn_col_curr || '  curr_hdc_trn
  ,' || l_dynsql_rec.hdc_trn_col_comp || '  comp_hdc_trn' || g_rtn ||
/* Turnover */
' ,NVL(trn.curr_sep_vol_hdc, 0)     curr_term_vol_hdc
 ,NVL(trn.curr_sep_invol_hdc, 0)   curr_term_invol_hdc
 ,NVL(trn.curr_separation_hdc, 0)  curr_termination_hdc
 ,NVL(trn.comp_sep_vol_hdc, 0)     comp_term_vol_hdc
 ,NVL(trn.comp_sep_invol_hdc, 0)   comp_term_invol_hdc
 ,NVL(trn.comp_separation_hdc, 0)  comp_termination_hdc' || g_rtn ||
/* Grand Totals - Headcount */
' ,NVL(SUM(wmv.curr_hdc_end) OVER (), 0)  curr_total_hdc_end
 ,NVL(SUM(comp_total_hdc_end) OVER (), 0)  comp_total_hdc_end' || g_rtn ||
/* Grand Totals - Headcount for turnover calculation */
' ,NVL(SUM(' || l_dynsql_rec.hdc_trn_col_curr_tot ||
                 ') OVER (), 0)  curr_total_hdc_trn
 ,NVL(SUM('  || l_dynsql_rec.hdc_trn_col_comp_tot ||
                 ') OVER (), 0)  comp_total_hdc_trn' || g_rtn ||
/* Grand Totals - Turnover */
' ,:HRI_CURR_TERM_VOL                        curr_total_trn_vol
 ,:HRI_CURR_TERM_INVOL                      curr_total_trn_inv
 ,:HRI_CURR_TERM_INVOL + :HRI_CURR_TERM_VOL curr_total_trn_tot
 ,:HRI_COMP_TERM_VOL                        comp_total_trn_vol
 ,:HRI_COMP_TERM_INVOL                      comp_total_trn_inv
 ,:HRI_COMP_TERM_VOL + :HRI_COMP_TERM_INVOL comp_total_trn_tot
 FROM
   ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
       (l_parameter_rec.view_by).viewby_table || ' vby' || g_rtn
     || ',( ' || l_wrkfc_fact_sql    || ' ) wmv' || g_rtn
     || ',( ' || l_wcnt_chg_fact_sql || ' ) trn' || g_rtn
|| 'WHERE wmv.vby_id = trn.vby_id (+)
 AND wmv.vby_id ' || l_dynsql_rec.wrkfc_outer_join || ' = vby.id ' || g_rtn ||
  l_dynsql_rec.view_by_filter ||
' ) tots
 ) a
WHERE 1 = 1  ' || g_rtn ||
  l_dynsql_rec.display_row_condition ||
  l_security_clause || '
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

END get_sql_pvt;

END hri_oltp_pmv_wmv_trn_summry;

/
