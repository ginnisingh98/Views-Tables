--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SUP" AS
/* $Header: hriopwmv.pkb 120.7 2006/08/18 06:24:08 rkonduru noship $ */

  g_rtn   VARCHAR2(5) := '
';

PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
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
  l_tot_gain_transfer     NUMBER;
  l_tot_loss              NUMBER;
  l_tot_loss_term         NUMBER;
  l_tot_loss_transfer     NUMBER;
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

 /* Employee Activity by Manager */
    IF (l_parameter_rec.bis_region_code = 'HRI_P_WMV_SUP') THEN
      l_drill_to_function1 := 'HRI_P_WAC_HIR_SUP_DTL';
      l_drill_to_function2 := 'HRI_P_WAC_IN_SUP_DTL';
      l_drill_to_function3 := 'HRI_P_WAC_SEP_SUP_DTL';
      l_drill_to_function4 := 'HRI_P_WAC_OUT_SUP_DTL';
      l_drill_to_function5 := 'HRI_P_WMV_SUP';
      l_drill_to_function6 := 'HRI_P_WMV_SAL_SUP_DTL';
    /* Contingent Worker Activity by Manager */
    ELSIF (l_parameter_rec.bis_region_code = 'HRI_P_WMV_C_SUP') THEN
      l_drill_to_function1 := 'HRI_P_WAC_C_HIR_SUP_DTL';
      l_drill_to_function2 := 'HRI_P_WAC_C_IN_SUP_DTL';
      l_drill_to_function3 := 'HRI_P_WAC_C_SEP_SUP_DTL';
      l_drill_to_function4 := 'HRI_P_WAC_C_OUT_SUP_DTL';
      l_drill_to_function5 := 'HRI_P_WMV_C_SUP';
      l_drill_to_function6 := 'HRI_P_WMV_C_SUP_DTL';
    END IF;

  /* use selective drill across feature */
  l_drill_url1 := 'pFunctionName=' || l_drill_to_function1 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url2 := 'pFunctionName=' || l_drill_to_function2 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url3 := 'pFunctionName=' || l_drill_to_function3 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url4 := 'pFunctionName=' || l_drill_to_function4 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

  l_drill_url5 := 'pFunctionName=' || l_drill_to_function5 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';

  l_drill_url6 := 'pFunctionName=' || l_drill_to_function6 || '&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';


/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Set direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get WMV Change totals for supervisor from cursor */
  hri_bpl_dbi_calc_period.calc_sup_wcnt_chg
        (p_supervisor_id        => l_parameter_rec.peo_supervisor_id,
         p_from_date            => l_parameter_rec.time_curr_start_date,
         p_to_date              => l_parameter_rec.time_curr_end_date,
         p_period_type          => l_parameter_rec.page_period_type,
         p_comparison_type      => l_parameter_rec.time_comparison_type,
         p_total_type           => 'ROLLUP',
         p_wkth_wktyp_sk_fk     => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_gain_hire      => l_tot_gain_hire,
         p_total_gain_transfer  => l_tot_gain_transfer,
         p_total_loss_term      => l_tot_loss_term,
         p_total_loss_transfer  => l_tot_loss_transfer);

/* Set WMV Change dependent totals */
  l_tot_gain := l_tot_gain_hire + l_tot_gain_transfer;
  l_tot_loss := l_tot_loss_term + l_tot_loss_transfer;
  l_tot_net := l_tot_gain - l_tot_loss;

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP.GET_SQL2');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format := 'PMV';
  l_wcnt_chg_fact_params.include_hire := 'Y';
  l_wcnt_chg_fact_params.include_trin := 'Y';
  l_wcnt_chg_fact_params.include_trout := 'Y';
  l_wcnt_chg_fact_params.include_term := 'Y';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_SUP.GET_SQL2');

/* Build query */
  l_sqltext :=
'SELECT  -- Headcount Portlet
 tots.id                      VIEWBYID
,tots.value                   VIEWBY ' || g_rtn ||
',DECODE(tots.suph_rollup_flag,
           ''N'', ''' || l_drill_url6  || ''',
         ''' || l_drill_url5 || ''')    HRI_P_DRILL_URL5'  || g_rtn ||
',tots.value                  HRI_P_CHAR1_GA'  || g_rtn ||
/* WMV value at Start */
',tots.current_wmv_start      HRI_P_MEASURE7 ' || g_rtn ||
/* WMV gained through hires */
',tots.wmv_gain_hire          HRI_P_MEASURE3 ' || g_rtn ||
',''' || l_drill_url1   ||''' HRI_P_DRILL_URL1 ' || g_rtn ||
/* WMV gained through transfers in */
',tots.wmv_gain_transfer      HRI_P_MEASURE4 ' || g_rtn ||
',''' || l_drill_url2   ||''' HRI_P_DRILL_URL2 ' || g_rtn ||
/* WMV lost through terminations */
',tots.wmv_loss_term          HRI_P_MEASURE5 ' || g_rtn ||
',''' || l_drill_url3   ||''' HRI_P_DRILL_URL3 ' || g_rtn ||
/* WMV lost through transfers out */
',tots.wmv_loss_transfer      HRI_P_MEASURE6 ' || g_rtn ||
',''' || l_drill_url4   ||''' HRI_P_DRILL_URL4 ' || g_rtn ||
/* Current WMV value */
',tots.current_wmv_end        HRI_P_MEASURE2 ' || g_rtn ||
/* Net change in WMV value */
',tots.wmv_net                HRI_P_WMV_CHNG_NET_SUM_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tots.previous_wmv_end',
        p_current_col  => 'tots.current_wmv_end') || '
                             HRI_P_WMV_CHNG_PCT_SUM_MV
,tots.comp_total_hdc_end     HRI_P_WMV_SUM_PREV_MV
,tots.comp_total_hdc_end     HRI_P_MEASURE1
,tots.wmv_gain_hire          HRI_P_MEASURE8
,tots.wmv_loss_term          HRI_P_MEASURE9
,tots.curr_total_hdc_end     HRI_P_GRAND_TOTAL1
,:HRI_TOT_GAIN_HIRE          HRI_P_GRAND_TOTAL5
,:HRI_TOT_GAIN_TRANSFER      HRI_P_GRAND_TOTAL6
,:HRI_TOT_LOSS_TERM          HRI_P_GRAND_TOTAL7
,:HRI_TOT_LOSS_TRANSFER      HRI_P_GRAND_TOTAL8
,tots.curr_total_hdc_start   HRI_P_GRAND_TOTAL2
,:HRI_TOT_NET_GAIN_LOSS      HRI_P_GRAND_TOTAL3
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tots.comp_total_hdc_end',
        p_current_col  => 'tots.curr_total_hdc_end') || '
                             HRI_P_GRAND_TOTAL4
,tots.comp_total_hdc_end     HRI_P_GRAND_TOTAL9 ' || g_rtn ||
/* Order by person name default sort order */
',tots.order_by              HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Whether the row is a supervisor rollup row */
',tots.suph_rollup_flag      HRI_P_SUPH_RO_CA
FROM
(SELECT
  per.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         per.value)                 value
 ,to_char(wmv.direct_ind) || per.order_by  order_by
 ,NVL(chg.curr_hire_hdc + chg.curr_transfer_in_hdc,0)  wmv_gain
 ,NVL(chg.curr_hire_hdc,0)                 wmv_gain_hire
 ,NVL(chg.curr_transfer_in_hdc,0)          wmv_gain_transfer
 ,NVL(chg.curr_termination_hdc + chg.curr_transfer_out_hdc,0)   wmv_loss
 ,NVL(chg.curr_termination_hdc,0)          wmv_loss_term
 ,NVL(chg.curr_transfer_out_hdc,0)         wmv_loss_transfer
 ,NVL(chg.curr_hire_hdc + chg.curr_transfer_in_hdc -
 (chg.curr_termination_hdc + chg.curr_transfer_out_hdc), 0)  wmv_net
 ,wmv.curr_hdc_start                current_wmv_start
 ,wmv.curr_hdc_end                  current_wmv_end
 ,wmv.comp_hdc_end                  previous_wmv_end
 ,SUM(wmv.curr_hdc_end) OVER ()          curr_total_hdc_end
 ,SUM(wmv.curr_total_hdc_start) OVER ()  curr_total_hdc_start
 ,SUM(wmv.comp_total_hdc_end) OVER ()    comp_total_hdc_end
 ,DECODE(wmv.direct_ind,
           1, ''N'',
         '''')                     suph_rollup_flag
 FROM
  hri_dbi_cl_per_n_v      per
 ,(' || l_wrkfc_fact_sql || ') wmv
 ,(' || l_wcnt_chg_fact_sql || ') chg
 WHERE wmv.vby_id = chg.vby_id (+)
 AND wmv.vby_id = per.id
 AND &BIS_CURRENT_ASOF_DATE BETWEEN per.effective_start_date
                            AND per.effective_end_date
 AND (wmv.curr_hdc_end > 0
   OR chg.curr_hire_hdc > 0
   OR chg.curr_transfer_in_hdc > 0
   OR chg.curr_transfer_out_hdc > 0
   OR chg.curr_termination_hdc > 0
   OR wmv.direct_ind = 1)
) tots
WHERE 1 = 1
' || l_security_clause || '
ORDER BY ' || l_parameter_rec.order_by;

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_TOT_GAIN_HIRE';
  l_custom_rec.attribute_value := l_tot_gain_hire;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_GAIN_TRANSFER';
  l_custom_rec.attribute_value := l_tot_gain_transfer;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_LOSS_TERM';
  l_custom_rec.attribute_value := l_tot_loss_term;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_LOSS_TRANSFER';
  l_custom_rec.attribute_value := l_tot_loss_transfer;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_TOT_NET_GAIN_LOSS';
  l_custom_rec.attribute_value := l_tot_net;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END get_sql2;

--
-- ----------------------------------------------------------------------
-- Procedure to fetch the headcount KPI
-- It fetched the values for the following KPIs
--  1. Total  Headcount
--  2. Previous Total Headcount
--  3. Average Length of Service
--  4. Previous Average Length of Service
-- ----------------------------------------------------------------------
--
PROCEDURE get_wmv_low_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql             OUT NOCOPY VARCHAR2,
                          x_custom_output          OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
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
  l_wrkfc_params         hri_bpl_fact_sup_wrkfc_sql.WRKFC_FACT_PARAM_TYPE;
  --
  -- Inner SQL
  --
  l_trend_sql              VARCHAR2(32767);
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
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_comp  := 'Y';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.include_low   := 'Y';
  l_wrkfc_params.include_pasg_cnt  := 'Y';
  l_wrkfc_params.kpi_mode      := 'Y';
  --
  -- Get the inner SQL
  --
  l_trend_sql := HRI_OLTP_PMV_QUERY_WRKFC.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wrkfc_params     => l_wrkfc_params,
                  p_calling_module   => 'HRI_OLTP_PMV_WMV_SUP.get_wmv_low_kpi');
  --
 -- Form the SQL
  --
  x_custom_sql :=
'SELECT -- Headcount KPI
 qry.vby_id           VIEWBYID
,qry.vby_id           VIEWBY
,qry.curr_hdc_end     HRI_P_MEASURE1
,qry.comp_hdc_end     HRI_P_MEASURE2
,DECODE(qry.curr_pasg_cnt_end,0,0,qry.curr_low_end/(365*qry.curr_pasg_cnt_end))
                      HRI_P_MEASURE4
,DECODE(qry.comp_pasg_cnt_end,0,0,qry.comp_low_end/(365*qry.comp_pasg_cnt_end))
                      HRI_P_MEASURE5
,qry.curr_hdc_end     HRI_P_GRAND_TOTAL1
,qry.comp_hdc_end     HRI_P_GRAND_TOTAL2
,DECODE(qry.curr_pasg_cnt_end,0,0,qry.curr_low_end/(365*qry.curr_pasg_cnt_end))
                      HRI_P_GRAND_TOTAL4
,DECODE(qry.comp_pasg_cnt_end,0,0,qry.comp_low_end/(365*qry.comp_pasg_cnt_end))
                      HRI_P_GRAND_TOTAL5
FROM
('||l_trend_sql||') qry
WHERE 1=1
' || l_security_clause;
  --
END get_wmv_low_kpi;


/* CWK KPIs */
PROCEDURE get_wmv_c_low_kpi(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_security_clause      VARCHAR2(4000);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

  l_page_parameter_tbl   BIS_PMV_PAGE_PARAMETER_TBL;

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

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_params.include_low := 'Y';
  l_wrkfc_fact_params.include_pasg_cnt  := 'Y';
  l_wrkfc_fact_params.kpi_mode      := 'Y';
  l_wrkfc_fact_params.bucket_dim   := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP.GET_WMV_C_LOW_KPI');

/* Form the dynamic SQL to PMV */
  x_custom_sql :=
  --l_parameter_rec.debug_header || g_rtn ||
'SELECT -- Contingent Worker Headcount KPI
 qry.vby_id           VIEWBYID
,qry.vby_id           VIEWBY
,qry.curr_hdc_cwk     HRI_P_MEASURE1
,qry.comp_hdc_cwk     HRI_P_MEASURE2
,DECODE(qry.curr_pasg_cnt_cwk,0,0,qry.curr_low_cwk/(:MONTHS_MULTIPLIER*qry.curr_pasg_cnt_cwk))
                      HRI_P_MEASURE4
,DECODE(qry.comp_pasg_cnt_cwk,0,0,qry.comp_low_cwk/(:MONTHS_MULTIPLIER*qry.comp_pasg_cnt_cwk))
                      HRI_P_MEASURE5
,qry.curr_hdc_cwk     HRI_P_GRAND_TOTAL1
,qry.comp_hdc_cwk     HRI_P_GRAND_TOTAL2
,DECODE(qry.curr_pasg_cnt_cwk,0,0,qry.curr_low_cwk/(:MONTHS_MULTIPLIER*qry.curr_pasg_cnt_cwk))
                      HRI_P_GRAND_TOTAL4
,DECODE(qry.comp_pasg_cnt_cwk,0,0,qry.comp_low_cwk/(:MONTHS_MULTIPLIER*qry.comp_pasg_cnt_cwk))
                      HRI_P_GRAND_TOTAL5
FROM
('||l_wrkfc_fact_sql||') qry
WHERE 1=1' || g_rtn
||l_security_clause;

  l_custom_rec.attribute_name := ':MONTHS_MULTIPLIER';
  l_custom_rec.attribute_value := 30.42;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END get_wmv_c_low_kpi;

PROCEDURE get_wmv_c_atvty_kpi(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext              VARCHAR2(32767);
  l_security_clause      VARCHAR2(4000);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);
  l_wcnt_chg_fact_params hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(10000);

  l_page_parameter_tbl   BIS_PMV_PAGE_PARAMETER_TBL;

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

/* Set the dynamic order by from the dimension metadata */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.kpi_mode    := 'Y';
  l_wrkfc_fact_params.bucket_dim   := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP.GET_WMV_C_KPI');

/* Get SQL for workforce changes fact */
  l_wcnt_chg_fact_params.bind_format  := 'PMV';
  l_wcnt_chg_fact_params.include_comp := 'Y';
  l_wcnt_chg_fact_params.include_hire := 'Y';
  l_wcnt_chg_fact_params.include_term := 'Y';
  l_wcnt_chg_fact_params.kpi_mode     := 'Y';
  l_wcnt_chg_fact_params.bucket_dim   := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  l_wcnt_chg_fact_sql := hri_bpl_fact_sup_wcnt_chg_sql.get_sql
   (p_parameter_rec   => l_parameter_rec,
    p_bind_tab        => l_bind_tab,
    p_wcnt_chg_params => l_wcnt_chg_fact_params,
    p_calling_module  => 'HRI_OLTP_PMV_WMV_SUP.GET_WMV_C_ATVTY_KPI');

/* Form the dynamic SQL to PMV */
  x_custom_sql :=
  --l_parameter_rec.debug_header || g_rtn ||
'SELECT -- Contingent Worker Activity KPI
 wmv.vby_id                 VIEWBYID
,wmv.vby_id                 VIEWBY
,wmv.curr_hdc_cwk           HRI_P_MEASURE1
,wmv.comp_hdc_cwk           HRI_P_MEASURE2
,NVL(atvty.curr_hire_hdc_cwk,0)         HRI_P_MEASURE4
,NVL(atvty.comp_hire_hdc_cwk,0)         HRI_P_MEASURE5
,NVL(atvty.curr_termination_hdc_cwk,0)  HRI_P_MEASURE7
,NVL(atvty.comp_termination_hdc_cwk,0)  HRI_P_MEASURE8
,wmv.curr_hdc_cwk                   HRI_P_GRAND_TOTAL1
,wmv.comp_hdc_cwk                   HRI_P_GRAND_TOTAL2
,NVL(atvty.curr_hire_hdc_cwk,0)         HRI_P_GRAND_TOTAL4
,NVL(atvty.comp_hire_hdc_cwk,0)         HRI_P_GRAND_TOTAL5
,NVL(atvty.curr_termination_hdc_cwk,0)  HRI_P_GRAND_TOTAL7
,NVL(atvty.comp_termination_hdc_cwk,0)  HRI_P_GRAND_TOTAL8
FROM
 ('||l_wcnt_chg_fact_sql||') atvty ' || g_rtn
||',('||l_wrkfc_fact_sql||') wmv
WHERE 1=1
AND wmv.vby_id = atvty.vby_id (+)' || g_rtn
||l_security_clause;

END get_wmv_c_atvty_kpi;


END HRI_OLTP_PMV_WMV_SUP;

/
