--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_TRN_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_TRN_CTR" AS
/* $Header: hriopwtc.pkb 120.0 2005/05/29 07:39:30 appldev noship $ */

  g_rtn     VARCHAR2(5) := '
';

PROCEDURE GET_SQL_CTR_T4
  (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql          OUT NOCOPY VARCHAR2,
   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext                 VARCHAR2(32767);
  l_custom_rec              BIS_QUERY_ATTRIBUTES;
  l_security_clause         VARCHAR2(4000);

-- Parameter values
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_country_tab           hri_oltp_pmv_rank_ctr.country_tab_type;

-- Trend Period Parameters
  l_projection_periods  NUMBER;
  l_previous_periods    NUMBER;
  l_trend_sql           VARCHAR2(10000);
  l_trend_sql_params    hri_oltp_pmv_query_trend.trend_sql_params_type;

-- Annualization factor for period type parameter
  l_calc_anl_factor     NUMBER;

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

/* Get the annualization factor for the different periods */
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                          (p_period_type  => l_parameter_rec.page_period_type);

/* Get bind values for number of time periods */
  hri_oltp_pmv_query_time.get_period_binds
          (p_page_period_type    => l_parameter_rec.page_period_type
          ,p_page_comp_type      => l_parameter_rec.time_comparison_type
          ,o_previous_periods    => l_previous_periods
          ,o_projection_periods  => l_projection_periods);

/* Get the top 4 countries */
  hri_oltp_pmv_rank_ctr.set_top_countries
   (p_supervisor_id => l_parameter_rec.peo_supervisor_id,
    p_effective_date => l_parameter_rec.time_curr_end_date,
    p_no_countries => 4,
    p_country_tab => l_country_tab);

/* Get the trend sql */
  l_trend_sql_params.bind_format := 'PMV';
  l_trend_sql_params.include_hdc := 'Y';
  l_trend_sql_params.include_sep := 'Y';
  l_trend_sql_params.bucket_dim := 'GEOGRAPHY+COUNTRY';
  l_trend_sql := hri_oltp_pmv_query_trend.get_sql
                  (p_parameter_rec    => l_parameter_rec,
                   p_bind_tab         => l_bind_tab,
                   p_trend_sql_params => l_trend_sql_params,
                   p_calling_module   => 'HRI_OLTP_PMV_WMV_TRN_CTR.GET_SQL_CTR_T4');

l_sqltext :=
'SELECT -- Terminations by Top 4 Country Trend
 qry.period_as_of_date     VIEWBYID
,qry.period_as_of_date     VIEWBY
,qry.period_order          HRI_P_ORDER_BY_1
,qry.period_sep_hdc_ctr1   HRI_P_MEASURE1
,DECODE(qry.period_sep_hdc_ctr1,
   0, 0,
 qry.period_sep_hdc_ctr1 * :ANL_FACTOR * 100 /
 DECODE(qry.period_hdc_trn_ctr1,
          0, qry.period_sep_hdc_ctr1,
        qry.period_hdc_trn_ctr1))  HRI_P_MEASURE1_MP
,qry.period_sep_hdc_ctr2   HRI_P_MEASURE2
,DECODE(qry.period_sep_hdc_ctr2,
   0, 0,
 qry.period_sep_hdc_ctr2 * :ANL_FACTOR * 100 /
 DECODE(qry.period_hdc_trn_ctr2,
          0, qry.period_sep_hdc_ctr2,
        qry.period_hdc_trn_ctr2))  HRI_P_MEASURE2_MP
,qry.period_sep_hdc_ctr3   HRI_P_MEASURE3
,DECODE(qry.period_sep_hdc_ctr3,
   0, 0,
 qry.period_sep_hdc_ctr3 * :ANL_FACTOR * 100 /
 DECODE(qry.period_hdc_trn_ctr3,
          0, qry.period_sep_hdc_ctr3,
        qry.period_hdc_trn_ctr3))  HRI_P_MEASURE3_MP
,qry.period_sep_hdc_ctr4   HRI_P_MEASURE4
,DECODE(qry.period_sep_hdc_ctr4,
   0, 0,
 qry.period_sep_hdc_ctr4 * :ANL_FACTOR * 100 /
 DECODE(qry.period_hdc_trn_ctr4,
          0, qry.period_sep_hdc_ctr4,
        qry.period_hdc_trn_ctr4))  HRI_P_MEASURE4_MP
,to_char(qry.period_as_of_date,''DD/MM/YYYY'')          HRI_P_CHAR2_GA
FROM
 (' || l_trend_sql || ')  qry
WHERE 1=1
' || l_security_clause || '
ORDER BY
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

  l_custom_rec.attribute_name := ':ANL_FACTOR';
  l_custom_rec.attribute_value := l_calc_anl_factor;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

END get_sql_ctr_t4;

/******************************************************************************/
/* Annulaized Turnover By Top 10 Countries
/******************************************************************************/

PROCEDURE GET_SQL_RNK_CTR
          (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
           x_custom_sql          OUT NOCOPY VARCHAR2,
           x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText               VARCHAR2(32767) ;
  l_custom_rec            BIS_QUERY_ATTRIBUTES;
  l_security_clause       VARCHAR2(5000);

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wrkfc_params         hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wcnt_chg_params      hri_bpl_fact_sup_wcnt_chg_sql.wcnt_chg_fact_param_type;
  l_wcnt_chg_fact_sql    VARCHAR2(32767);
  l_wrkfc_fact_sql       VARCHAR2(32767);

/* Annualization factor for period type parameter */
  l_calc_anl_factor         NUMBER;

/* Headcount for turnover calc method selected */
  l_hdc_trn_col_curr        VARCHAR(250);
  l_hdc_trn_col_comp        VARCHAR(250);

/* Drill URL */
  l_drill_url               VARCHAR(1000);

/* Others string */
  l_others_string           VARCHAR2(240);

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Force the View By parameter to Country */
  l_parameter_rec.view_by := 'GEOGRAPHY+COUNTRY';

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get the annualization factor for the different periods */
  l_calc_anl_factor := hri_oltp_pmv_util_pkg.calc_anl_factor
                          (p_period_type  => l_parameter_rec.page_period_type);

/* Generate the Turnover Fact SQL */
  l_wcnt_chg_params.bind_format     := 'PMV';
  l_wcnt_chg_params.include_comp    := 'Y';
  l_wcnt_chg_params.include_sep     := 'Y';
  l_wcnt_chg_params.include_sep_inv := 'Y';
  l_wcnt_chg_params.include_sep_vol := 'Y';
  l_wcnt_chg_fact_sql := hri_oltp_pmv_query_wcnt_chg.get_sql
             (p_parameter_rec   => l_parameter_rec,
              p_bind_tab        => l_bind_tab,
              p_wcnt_chg_params => l_wcnt_chg_params,
              p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_CTR.GET_SQL_RNK_CTR');

/* Generate the Workforce Fact SQL */
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.include_comp  := 'Y';
  l_wrkfc_params.include_start := 'Y';
  l_wrkfc_fact_sql := hri_oltp_pmv_query_wrkfc.get_sql
             (p_parameter_rec   => l_parameter_rec,
              p_bind_tab        => l_bind_tab,
              p_wrkfc_params    => l_wrkfc_params,
              p_calling_module  => 'HRI_OLTP_PMV_WMV_TRN_CTR.GET_SQL_RNK_CTR');


/* Get the profile value for the turnover calculation */
  IF fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG' THEN
    l_hdc_trn_col_curr := '(wmv.curr_hdc_start+wmv.curr_hdc_end)/2';
    l_hdc_trn_col_comp := '(wmv.comp_hdc_start+wmv.comp_hdc_end)/2';
  /* Else (Value = Workforce End or Null, which is default ) */
  ELSE
    l_hdc_trn_col_curr := 'wmv.curr_hdc_end';
    l_hdc_trn_col_comp := 'wmv.comp_hdc_end';
  END IF;

  l_drill_url := 'pFunctionName=HRI_P_WMV_TRN_SUMMARY_PVT&' ||
                 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                 'VIEW_BY_NAME=VIEW_BY_ID&' ||
                 'pParamIds=Y';

/* Set Others String */
  l_others_string := hri_oltp_view_message.get_others_msg;

/* Return AK Sql To PMV */
 l_SQLText    :=
'SELECT
 -- Annualized Turnover By Top x Countries
 grp.vby_id               VIEWBYID
,DECODE(grp.vby_id, ''NA_OTHERS'', ''' || l_others_string || ''',
        vby.value)        VIEWBY
,DECODE(grp.vby_id, ''NA_OTHERS'', ''' || l_others_string || ''',
        vby.value)        HRI_P_CHAR1_GA '|| g_rtn ||
/* Title - Headcount */
',grp.curr_hdc_end         HRI_P_MEASURE1 '|| g_rtn ||
/* Title - Voluntary  */
',grp.curr_trn_vol         HRI_P_MEASURE2
,:HRI_ANL_FACTOR * 100 * grp.curr_trn_vol / grp.curr_trn_div
                          HRI_P_MEASURE3 '|| g_rtn ||
/* Title -  InVoluntary */
',grp.curr_trn_inv         HRI_P_MEASURE4
,:HRI_ANL_FACTOR * 100 * grp.curr_trn_inv / grp.curr_trn_div
                          HRI_P_MEASURE5 '|| g_rtn ||
/* Title - Total Terms */
',grp.curr_trn_tot         HRI_P_MEASURE6
,:HRI_ANL_FACTOR * 100 * grp.curr_trn_tot / grp.curr_trn_div
                          HRI_P_MEASURE7 '|| g_rtn ||
/* Title - Grand Total Headcount */
',grp.total_curr_hdc_end   HRI_P_GRAND_TOTAL1 '|| g_rtn ||
/* Title - Grand Total VOL */
',grp.total_curr_trn_vol   HRI_P_GRAND_TOTAL2
,:HRI_ANL_FACTOR * 100 * grp.total_curr_trn_vol / grp.total_curr_trn_div
                          HRI_P_GRAND_TOTAL3 '|| g_rtn ||
/* Title - Grand Total INVOL */
',grp.total_curr_trn_inv   HRI_P_GRAND_TOTAL4
,:HRI_ANL_FACTOR * 100 * grp.total_curr_trn_inv / grp.total_curr_trn_div
                          HRI_P_GRAND_TOTAL5 '|| g_rtn ||
/* Title - Grand Total TOTAL TERMS */
',grp.total_curr_trn_tot   HRI_P_GRAND_TOTAL6
,:HRI_ANL_FACTOR * 100 * grp.total_curr_trn_tot / grp.total_curr_trn_div
                          HRI_P_GRAND_TOTAL7
,'''||l_drill_url||'''
                          HRI_P_DRILL_URL1
FROM
 hri_dbi_cl_geo_country_v  vby,
 (SELECT' || g_rtn ||
/* Bug 4068969 - added country_code and fixed order_by and vby_id */
'   DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - a.rnk),
            -1, :HRI_NO_COUNTRIES_TO_SHOW + 1,
          a.rnk)       order_by
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - a.rnk),
            -1, ''NA_OTHERS'',
          a.vby_id)            vby_id
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - a.rnk),
            -1, ''NA_EDW'',
          a.vby_id)            country_code
  ,SUM(a.curr_hdc_end)         curr_hdc_end
  ,SUM(a.total_curr_hdc_end)   total_curr_hdc_end
  ,SUM(a.curr_trn_vol)         curr_trn_vol
  ,SUM(a.comp_trn_vol)         comp_trn_vol
  ,SUM(a.total_curr_trn_vol)   total_curr_trn_vol
  ,SUM(a.total_comp_trn_vol)   total_comp_trn_vol
  ,SUM(a.curr_trn_inv)         curr_trn_inv
  ,SUM(a.comp_trn_inv)         comp_trn_inv
  ,SUM(a.total_curr_trn_inv)   total_curr_trn_inv
  ,SUM(a.total_comp_trn_inv)   total_comp_trn_inv
  ,SUM(a.curr_trn_tot)         curr_trn_tot
  ,SUM(a.comp_trn_tot)         comp_trn_tot
  ,SUM(a.total_curr_trn_tot)   total_curr_trn_tot
  ,SUM(a.total_comp_trn_tot)   total_comp_trn_tot
  ,SUM(a.curr_trn_div)         curr_trn_div
  ,SUM(a.comp_trn_div)         comp_trn_div
  ,SUM(a.total_curr_trn_div)   total_curr_trn_div
  ,SUM(a.total_comp_trn_div)   total_comp_trn_div
  FROM
   (SELECT
     tots.*' || g_rtn ||
/* Bug 4068969 - Ensured ranking function is unique */
'    ,RANK() OVER (ORDER BY
      tots.curr_hdc_end DESC NULLS LAST,
      tots.vby_id)   rnk ' || g_rtn ||
/* Terminations Factor */'
    ,DECODE(tots.curr_hdc_trn,
       0, DECODE(tots.curr_trn_tot, 0 , 1, tots.curr_trn_tot),
     tots.curr_hdc_trn)         curr_trn_div
    ,DECODE(tots.comp_hdc_trn,
       0, DECODE(tots.comp_trn_tot, 0 , 1, tots.comp_trn_tot),
     tots.comp_hdc_trn)         comp_trn_div
    ,:HRI_ANL_FACTOR            anl_factor ' || g_rtn ||
/* Grand Totals - Terminations */ '
    ,DECODE(tots.total_curr_hdc_trn,
       0, DECODE(tots.total_curr_trn_tot, 0 , 1, tots.total_curr_trn_tot),
     tots.total_curr_hdc_trn)   total_curr_trn_div
    ,DECODE(tots.total_comp_hdc_trn,
       0, DECODE(tots.total_comp_trn_tot, 0 , 1, tots.total_comp_trn_tot),
     tots.total_comp_hdc_trn)   total_comp_trn_div
    FROM
     (SELECT
/* View by */
       wmv.vby_id ' || g_rtn ||
/* Headcount */'
      ,wmv.curr_hdc_end
      ,wmv.comp_hdc_end
      ,DECODE(wmv.comp_hdc_end,
         0, 0,
       100 * (wmv.curr_hdc_end - wmv.comp_hdc_end) /
       wmv.comp_hdc_end)  hdc_change_pct ' || g_rtn ||
/* Headcount for turnover calculation */ '
      ,' || l_hdc_trn_col_curr || '       curr_hdc_trn
      ,' || l_hdc_trn_col_comp || '       comp_hdc_trn' || g_rtn ||
/* Turnover */'
      ,NVL(trn.curr_sep_vol_hdc, 0)  curr_trn_vol
      ,NVL(trn.curr_sep_invol_hdc, 0)  curr_trn_inv
      ,NVL(trn.curr_separation_hdc, 0)  curr_trn_tot
      ,NVL(trn.comp_sep_vol_hdc, 0)  comp_trn_vol
      ,NVL(trn.comp_sep_invol_hdc, 0)  comp_trn_inv
      ,NVL(trn.comp_separation_hdc, 0)  comp_trn_tot ' || g_rtn ||
/* Grand Totals - Headcount */ '
      ,SUM(wmv.curr_hdc_end) OVER ()  total_curr_hdc_end
      ,SUM(wmv.comp_hdc_end) OVER ()  total_comp_hdc_end ' || g_rtn ||
/* Grand Totals - Headcount for turnover calculation */ '
       ,SUM(' || l_hdc_trn_col_curr || ') OVER ()  total_curr_hdc_trn
       ,SUM(' || l_hdc_trn_col_comp || ') OVER ()  total_comp_hdc_trn ' || g_rtn ||
/* Grand Totals - Turnover */'
      ,NVL(SUM(trn.curr_sep_vol_hdc) OVER (), 0)  total_curr_trn_vol
      ,NVL(SUM(trn.curr_sep_invol_hdc) OVER (), 0)  total_curr_trn_inv
      ,NVL(SUM(trn.curr_separation_hdc) OVER (), 0)  total_curr_trn_tot
      ,NVL(SUM(trn.comp_sep_vol_hdc) OVER (), 0)  total_comp_trn_vol
      ,NVL(SUM(trn.comp_sep_invol_hdc) OVER (), 0)  total_comp_trn_inv
      ,NVL(SUM(trn.comp_separation_hdc) OVER (), 0)  total_comp_trn_tot
      FROM
         ( ' || l_wcnt_chg_fact_sql || ' ) trn' || g_rtn
     || ',( ' || l_wrkfc_fact_sql    || ' ) wmv' || g_rtn
     || 'WHERE wmv.vby_id = trn.vby_id (+)
     ) tots
   ) a
  WHERE 1 = 1
  AND (a.curr_hdc_end > 0
    OR a.curr_trn_vol > 0
    OR a.curr_trn_inv > 0
    OR a.comp_trn_vol > 0
    OR a.comp_trn_inv > 0)
  GROUP BY
   DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - a.rnk),
            -1, :HRI_NO_COUNTRIES_TO_SHOW + 1,
          a.rnk)
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_OTHERS'',
          a.vby_id)
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_EDW'',
          a.vby_id)
 ) grp
WHERE grp.country_code = vby.id
' || l_security_clause || '
ORDER BY grp.order_by';

 x_custom_sql := l_SQLText;

/* Binds Will be inserted Below */

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_ANL_FACTOR';
  l_custom_rec.attribute_value := l_calc_anl_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_NO_COUNTRIES_TO_SHOW';
  l_custom_rec.attribute_value := 10;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END GET_SQL_RNK_CTR;

END hri_oltp_pmv_wmv_trn_ctr;

/
