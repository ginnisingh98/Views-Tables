--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_ABS_WMV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_ABS_WMV_PVT" AS
/* $Header: hriopabswmvpvt.pkb 120.8 2005/11/17 08:51 jrstewar noship $ */

g_rtn                VARCHAR2(30) := '
';

--
--****************************************************************************
--* AK SQL For Absence Summary by Manager                                    *
--* AK Region : HRI_P_ABS_WMV_PVT                                            *
--****************************************************************************
--
PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                 ,x_custom_sql  OUT NOCOPY VARCHAR2
                 ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
       IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_abs_fact_params       hri_bpl_fact_abs_sql.abs_fact_param_type;
  l_abs_fact_sql          VARCHAR2(10000);
  l_wrkfc_fact_params     hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql        VARCHAR2(10000);
  l_direct_reports_string VARCHAR2(100);
  l_dynsql_order_by       VARCHAR2(100);

  l_parameter_name        VARCHAR2(100);
  l_dynmc_drtn_curr       VARCHAR2(100) DEFAULT 'curr_abs_drtn_days';
  l_dynmc_drtn_comp       VARCHAR2(100) DEFAULT 'comp_abs_drtn_days';
  l_drill_mgr_sup         VARCHAR2(1000);
  l_drill_to_detail       VARCHAR2(1000);
  l_drill_abs_detail      VARCHAR2(1000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header          VARCHAR(550);

/* Total Variables */
  l_curr_tot_abs_drtn_days      NUMBER;
  l_curr_tot_abs_drtn_hrs       NUMBER;
  l_curr_tot_abs_drtn           NUMBER;
  l_curr_tot_abs_in_period      NUMBER;
  l_curr_tot_abs_ntfctn_period  NUMBER;

  l_comp_tot_abs_drtn_days      NUMBER;
  l_comp_tot_abs_drtn_hrs       NUMBER;
  l_comp_tot_abs_drtn           NUMBER;
  l_comp_tot_abs_in_period      NUMBER;
  l_comp_tot_abs_ntfctn_period  NUMBER;

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

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Set the order by */
   l_dynsql_order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                            (p_order_by_clause => l_parameter_rec.order_by);

/* Drill URL's for Manager and Direct Reports */
  l_drill_mgr_sup :='pFunctionName=HRI_P_ABS_WMV_PVT&' ||
                    'VIEW_BY=VIEW_BY_NAME&' ||
                    'VIEW_BY_NAME=VIEW_BY_ID&' ||
                    'pParamIds=Y';

  l_drill_to_detail :='pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                     'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                     'pParamIds=Y';

  l_drill_abs_detail :='pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                     'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                     'pParamIds=Y';

/* Get current period absence totals for supervisor from cursor */
    hri_bpl_dbi_calc_period.calc_sup_absence
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_curr_start_date,
         p_to_date          => l_parameter_rec.time_curr_end_date,
         p_period_type      => l_parameter_rec.page_period_type,
         p_comparison_type  => l_parameter_rec.time_comparison_type,
         p_total_type       => 'ROLLUP',
         p_wkth_wktyp_sk_fk => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_abs_drtn_days => l_curr_tot_abs_drtn_days,
         p_total_abs_drtn_hrs  => l_curr_tot_abs_drtn_hrs,
         p_total_abs_in_period => l_curr_tot_abs_in_period,
         p_total_abs_ntfctn_period => l_curr_tot_abs_ntfctn_period);

/* Get previous period turnover totals for supervisor from cursor */
    hri_bpl_dbi_calc_period.calc_sup_absence
        (p_supervisor_id    => l_parameter_rec.peo_supervisor_id,
         p_from_date        => l_parameter_rec.time_comp_start_date,
         p_to_date          => l_parameter_rec.time_comp_end_date,
         p_period_type      => l_parameter_rec.page_period_type,
         p_comparison_type  => l_parameter_rec.time_comparison_type,
         p_total_type       => 'ROLLUP',
         p_wkth_wktyp_sk_fk => l_parameter_rec.wkth_wktyp_sk_fk,
         p_total_abs_drtn_days => l_comp_tot_abs_drtn_days,
         p_total_abs_drtn_hrs  => l_comp_tot_abs_drtn_hrs,
         p_total_abs_in_period => l_comp_tot_abs_in_period,
         p_total_abs_ntfctn_period => l_comp_tot_abs_ntfctn_period);

  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure paramter selection  Default Days                */

      IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS')  THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
        l_curr_tot_abs_drtn:= l_curr_tot_abs_drtn_days;
        l_comp_tot_abs_drtn:= l_comp_tot_abs_drtn_days;
      ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_hrs';
        l_dynmc_drtn_comp := 'comp_abs_drtn_hrs';
        l_abs_fact_params.include_abs_drtn_hrs := 'Y';
        l_curr_tot_abs_drtn:= l_curr_tot_abs_drtn_hrs;
        l_comp_tot_abs_drtn:= l_comp_tot_abs_drtn_hrs;
      ELSE -- functional decision (JC) default to days
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
        l_curr_tot_abs_drtn:= l_curr_tot_abs_drtn_days;
        l_comp_tot_abs_drtn:= l_comp_tot_abs_drtn_hrs;
      END IF;

/* Get SQL for absence fact */
  l_abs_fact_params.bind_format := 'PMV';

  l_abs_fact_params.include_abs_in_period     := 'Y';
  l_abs_fact_params.include_abs_ntfctn_period := 'Y';
  l_abs_fact_params.include_comp              := 'Y';
  l_abs_fact_params.kpi_mode                  := 'N';
  l_abs_fact_sql := hri_bpl_fact_abs_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_abs_params     => l_abs_fact_params,
    p_calling_module => 'HRI_P_ABS_WMV_PVT');

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format   := 'PMV';
  l_wrkfc_fact_params.include_start := 'N';
  l_wrkfc_fact_params.include_hdc   := 'Y';
  l_wrkfc_fact_params.include_sal   := 'N';
  l_wrkfc_fact_params.include_low   := 'N';
  l_wrkfc_fact_params.include_comp  := 'N';
  l_wrkfc_fact_params.kpi_mode      := 'N';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_P_ABS_WMV_PVT');

l_SQLText :=
'SELECT  -- Absence Summary by Manager Status
 babs.vby_id	VIEWBYID
,babs.value	VIEWBY '|| g_rtn
/* Workforce */  || g_rtn ||
',NVL(curr_hdc_end, 0 )                   HRI_P_MEASURE1 '|| g_rtn
/* Absence  */ || g_rtn ||'
,NVL(babs.curr_abs_in_period,0)           HRI_P_MEASURE2
,NVL(babs.comp_abs_in_period,0)           HRI_P_MEASURE3 '|| g_rtn
/* Total Notification  */ || g_rtn ||'
,NVL(babs.curr_abs_ntfctn_period,0)       HRI_P_MEASURE4
,NVL(babs.comp_abs_ntfctn_period,0)       HRI_P_MEASURE5 '|| g_rtn
/* Average Notification  */ || g_rtn ||'
,NVL(curr_abs_avg_ntfctn_period,0)        HRI_P_MEASURE6
,NVL(comp_abs_avg_ntfctn_period,0)        HRI_P_MEASURE7'|| g_rtn
/* Change - Average Notification  */ || g_rtn ||'
,'|| hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'comp_abs_avg_ntfctn_period',
          p_current_col  => 'curr_abs_avg_ntfctn_period') || '
                                          HRI_P_MEASURE6_MP'|| g_rtn
/* Total Absence Duration */ || g_rtn ||'
,NVL(babs.curr_abs_drtn,0)                HRI_P_MEASURE8
,NVL(babs.comp_abs_drtn,0)                HRI_P_MEASURE9'|| g_rtn
/* Change - Total Absence Duration  */ || g_rtn ||'
,'|| hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_abs_drtn',
          p_current_col  => 'babs.curr_abs_drtn') || '
                                          HRI_P_MEASURE8_MP'|| g_rtn
/* Average Absence Duration  */ || g_rtn ||'
,DECODE(babs.curr_abs_in_period,0,to_number(NULL)
       ,(babs.curr_abs_drtn / babs.curr_abs_in_period)
	   )                              HRI_P_MEASURE10
,DECODE(babs.comp_abs_in_period,0,to_number(NULL)
       ,(babs.curr_abs_drtn / babs.comp_abs_in_period)
	   )                              HRI_P_MEASURE11 '|| g_rtn
/* Total Workforce */ || g_rtn ||'
,NVL(tot_curr_hdc_end,0)                  HRI_P_GRAND_TOTAL1 '|| g_rtn
/* Total Absence  */ || g_rtn ||'
,NVL(babs.curr_tot_abs_in_period,0)       HRI_P_GRAND_TOTAL2
,NVL(babs.comp_tot_abs_in_period,0)       HRI_P_GRAND_TOTAL3 '|| g_rtn
/* Total Notification  */ || g_rtn ||'
,NVL(babs.curr_tot_abs_ntfctn_period,0)   HRI_P_GRAND_TOTAL4
,NVL(babs.comp_tot_abs_ntfctn_period,0)   HRI_P_GRAND_TOTAL5 '|| g_rtn
/* Total Average Notification */ || g_rtn ||'
,NVL(babs.curr_tot_avg_abs_ntfctn_period,0)
                                          HRI_P_GRAND_TOTAL6
,NVL(babs.comp_tot_avg_abs_ntfctn_period,0)
                                          HRI_P_GRAND_TOTAL7'|| g_rtn
/* Change Total - Average Notification  */ || g_rtn ||'
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_tot_avg_abs_ntfctn_period',
          p_current_col  => 'babs.curr_tot_avg_abs_ntfctn_period') || '
                                          HRI_P_GRAND_TOTAL6_MP'|| g_rtn
/* Total Absence Duration */ || g_rtn ||'
,NVL(babs.curr_tot_abs_drtn,0)            HRI_P_GRAND_TOTAL8
,NVL(babs.comp_tot_abs_drtn,0)            HRI_P_GRAND_TOTAL9'|| g_rtn
/* Change Total - Total Absence Duration  */ || g_rtn ||'
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_tot_abs_drtn',
          p_current_col  => 'babs.curr_tot_abs_drtn') || '
                                          HRI_P_GRAND_TOTAL8_MP'|| g_rtn
/* Total Average Absence Duration  */ || g_rtn ||'
,DECODE(babs.curr_tot_abs_in_period,0,to_number(NULL)
       ,(babs.curr_tot_abs_drtn  / babs.curr_tot_abs_in_period)
	   )                              HRI_P_GRAND_TOTAL10
,DECODE(babs.comp_tot_abs_in_period,0,to_number(NULL)
       ,(babs.comp_tot_abs_drtn  / babs.comp_tot_abs_in_period)
	   )                              HRI_P_GRAND_TOTAL11 '|| g_rtn
/* Order by person name default sort order */ || g_rtn ||'
,babs.order_by                           HRI_P_ORDER_BY_1 ' || g_rtn
/* Whether the row is a supervisor rollup row */ || g_rtn ||'
,DECODE(babs.direct_ind , 0, '''', ''N'') HRI_P_SUPH_RO_CA '|| g_rtn
/* Drill URLs */ || g_rtn ||'
,DECODE(babs.direct_ind,0, ''' || l_drill_mgr_sup  || '''
        ,1, ''' || l_drill_to_detail  || '''
        ,'''')                            HRI_P_DRILL_URL1
,DECODE(babs.direct_ind,0, ''''
        ,1, ''' || l_drill_abs_detail || '''
        ,'''')	                          HRI_P_DRILL_URL2
FROM
(
SELECT
/* Base Measures */
 vby.id                                      vby_id
,DECODE(wfact.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         vby.value)  value
,to_char(NVL(wfact.direct_ind, 0)) || vby.order_by
                                            order_by
,wfact.direct_ind                           direct_ind
,NVL(wfact.curr_hdc_end,0)                  curr_hdc_end
,NVL(afact.'||l_dynmc_drtn_curr ||',0)      curr_abs_drtn
,NVL(afact.curr_abs_in_period,0)            curr_abs_in_period
,NVL(afact.'||l_dynmc_drtn_comp ||',0)      comp_abs_drtn
,NVL(afact.comp_abs_in_period,0)            comp_abs_in_period
,NVL(afact.curr_abs_ntfctn_period,0) 		curr_abs_ntfctn_period
,NVL(afact.comp_abs_ntfctn_period,0) 		comp_abs_ntfctn_period
,DECODE(afact.curr_abs_ntfctn_period,0,to_number(NULL)
       ,DECODE(afact.curr_abs_in_period,0,to_number(NULL)
	          ,(afact.curr_abs_ntfctn_period / afact.curr_abs_in_period)
	          )
       )                                    curr_abs_avg_ntfctn_period
,DECODE(afact.comp_abs_ntfctn_period,0,to_number(NULL)
       ,DECODE(afact.curr_abs_in_period,0,to_number(NULL)
	          ,(afact.comp_abs_ntfctn_period / afact.comp_abs_in_period)
	          )
      )                                     comp_abs_avg_ntfctn_period
,SUM(wfact.curr_hdc_end) OVER()             tot_curr_hdc_end
,:CURR_TOT_ABS_DRTN                         curr_tot_abs_drtn
,:CURR_TOT_ABS_IN_PERIOD                    curr_tot_abs_in_period
,:COMP_TOT_ABS_DRTN                         comp_tot_abs_drtn
,:COMP_TOT_ABS_IN_PERIOD                    comp_tot_abs_in_period
,:CURR_TOT_ABS_NTFCTN_PERIOD                curr_tot_abs_ntfctn_period
,:COMP_TOT_ABS_NTFCTN_PERIOD                comp_tot_abs_ntfctn_period
,DECODE(:CURR_TOT_ABS_NTFCTN_PERIOD,0,to_number(NULL)
       ,DECODE(:CURR_TOT_ABS_IN_PERIOD ,0,to_number(NULL)
              ,(:CURR_TOT_ABS_NTFCTN_PERIOD / :CURR_TOT_ABS_IN_PERIOD )
	          )
       )                                    curr_tot_avg_abs_ntfctn_period
,DECODE(:COMP_TOT_ABS_NTFCTN_PERIOD,0,to_number(NULL)
       ,DECODE(:COMP_TOT_ABS_IN_PERIOD,0,to_number(NULL)
              ,(:COMP_TOT_ABS_NTFCTN_PERIOD / :COMP_TOT_ABS_IN_PERIOD)
	          )
       )                                    comp_tot_avg_abs_ntfctn_period
FROM
 hri_dbi_cl_per_n_v   vby
,('|| l_abs_fact_sql ||') afact
,('|| l_wrkfc_fact_sql ||') wfact
WHERE
   vby.id = wfact.vby_id
AND afact.vby_id (+) = wfact.vby_id
AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date
 ' || l_security_clause || '
) babs
ORDER BY babs.direct_ind,' || l_dynsql_order_by;

  x_custom_sql := l_SQLText ;

  l_custom_rec.attribute_name := ':CURR_TOT_ABS_DRTN';
  l_custom_rec.attribute_value := l_curr_tot_abs_drtn;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':CURR_TOT_ABS_IN_PERIOD';
  l_custom_rec.attribute_value := l_curr_tot_abs_in_period;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':CURR_TOT_ABS_NTFCTN_PERIOD';
  l_custom_rec.attribute_value := l_curr_tot_abs_ntfctn_period;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':COMP_TOT_ABS_DRTN';
  l_custom_rec.attribute_value := l_comp_tot_abs_drtn;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':COMP_TOT_ABS_IN_PERIOD';
  l_custom_rec.attribute_value := l_comp_tot_abs_in_period;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':COMP_TOT_ABS_NTFCTN_PERIOD';
  l_custom_rec.attribute_value := l_comp_tot_abs_ntfctn_period;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

END get_sql;
--
--****************************************************************************
--* AK SQL For Absence (Employee) KPI's                                      *
--* AK Region : HRI_K_ABS_WMV                                                *
--****************************************************************************
--
PROCEDURE GET_SQL_KPI(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                 ,x_custom_sql  OUT NOCOPY VARCHAR2
                 ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
       IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_abs_fact_params       hri_bpl_fact_abs_sql.abs_fact_param_type;
  l_abs_fact_sql          VARCHAR2(10000);
  l_wrkfc_fact_params     hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql        VARCHAR2(10000);
  l_direct_reports_string VARCHAR2(100);
  l_dynsql_order_by       VARCHAR2(100);

  l_parameter_name        VARCHAR2(100);
  l_dynmc_drtn_curr       VARCHAR2(100) DEFAULT 'curr_abs_drtn_days';
  l_dynmc_drtn_comp       VARCHAR2(100) DEFAULT 'comp_abs_drtn_days';
  l_dynmc_hdc_curr        VARCHAR2(100);
  l_dynmc_hdc_comp        VARCHAR2(100);
  l_dynmc_tot_hdc_curr    VARCHAR2(100);
  l_dynmc_tot_hdc_comp    VARCHAR2(100);

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

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure paramter selection  Default Days                */

      IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS')  THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
      ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_hrs';
        l_dynmc_drtn_comp := 'comp_abs_drtn_hrs';
        l_abs_fact_params.include_abs_drtn_hrs := 'Y';
      ELSE -- functional decision (JC) default to days
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days := 'Y';
      END IF;

/* Format the SQL differently depending on the headcount calculation method */
  IF (fnd_profile.value('HR_TRNVR_CALC_MTHD') = 'WMV_STARTENDAVG') THEN
    l_dynmc_hdc_curr     := 'NVL((babs.curr_hdc_start + babs.curr_hdc_end)/2,0)';
    l_dynmc_hdc_comp     := 'NVL((babs.comp_hdc_start + babs.comp_hdc_end)/2,0)';
    l_dynmc_tot_hdc_curr := 'NVL((babs.tot_curr_hdc_start + babs.tot_curr_hdc_end)/2,0)';
    l_dynmc_tot_hdc_comp := 'NVL((babs.tot_comp_hdc_start + babs.tot_comp_hdc_end)/2,0)';
  ELSE
    l_dynmc_hdc_curr     := 'babs.curr_hdc_end';
    l_dynmc_hdc_comp     := 'babs.comp_hdc_end';
    l_dynmc_tot_hdc_curr := 'babs.tot_curr_hdc_end';
    l_dynmc_tot_hdc_comp := 'babs.tot_comp_hdc_end';
  END IF;

/* Get SQL for absence fact */
  l_abs_fact_params.bind_format               := 'PMV';
  l_abs_fact_params.include_abs_in_period     := 'Y';
  l_abs_fact_params.include_abs_ntfctn_period := 'Y';
  l_abs_fact_params.include_comp              := 'Y';
  l_abs_fact_params.kpi_mode                  := 'Y';
  l_abs_fact_sql := hri_bpl_fact_abs_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_abs_params     => l_abs_fact_params,
    p_calling_module => 'HRI_K_ABS_WMV');

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format   := 'PMV';
  l_wrkfc_fact_params.include_start := 'Y';
  l_wrkfc_fact_params.include_hdc   := 'Y';
  l_wrkfc_fact_params.include_sal   := 'N';
  l_wrkfc_fact_params.include_low   := 'N';
  l_wrkfc_fact_params.include_comp  := 'Y';
  l_wrkfc_fact_params.kpi_mode      := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_K_ABS_WMV');

l_SQLText :=
    ' -- Absence (Employee) KPIs
SELECT
 babs.vby_id	VIEWBYID
,babs.value	VIEWBY'|| g_rtn
/* Workforce */|| g_rtn ||'
,NVL(curr_hdc_end,0)                      HRI_P_MEASURE1
,NVL(comp_hdc_end,0)                      HRI_P_MEASURE2'|| g_rtn
/* Absence  */|| g_rtn ||'
,NVL(babs.curr_abs_in_period,0)           HRI_P_MEASURE3
,NVL(babs.comp_abs_in_period,0)           HRI_P_MEASURE4'|| g_rtn
/* Total Notification  */|| g_rtn ||'
,NVL(babs.curr_abs_ntfctn_period,0)       HRI_P_MEASURE5
,NVL(babs.comp_abs_ntfctn_period,0)       HRI_P_MEASURE6'|| g_rtn
/* Average Notification  */|| g_rtn ||'
,DECODE(babs.curr_abs_ntfctn_period,0, to_number(NULL)
	   ,DECODE(babs.curr_abs_in_period,0, to_number(NULL)
              ,(babs.curr_abs_ntfctn_period / babs.curr_abs_in_period)
	          )
        )                                 HRI_P_MEASURE7
,DECODE(babs.comp_abs_ntfctn_period,0,to_number(NULL)
	   ,DECODE(babs.comp_abs_in_period,0,to_number(NULL)
              ,(babs.comp_abs_ntfctn_period / babs.comp_abs_in_period)
	          )
        )                                 HRI_P_MEASURE8'|| g_rtn
/* Total Absence Duration */|| g_rtn ||'
,NVL(babs.curr_abs_drtn,0)                HRI_P_MEASURE9
,NVL(babs.comp_abs_drtn,0)                HRI_P_MEASURE10'|| g_rtn
/* Average Absence Duration  */|| g_rtn ||'
,DECODE(babs.curr_abs_in_period,0, to_number(NULL)
       ,(babs.curr_abs_drtn / babs.curr_abs_in_period)
	   )                              HRI_P_MEASURE11
,DECODE(babs.comp_abs_in_period,0, to_number(NULL)
       ,(babs.comp_abs_drtn / babs.comp_abs_in_period)
	   )                              HRI_P_MEASURE12'|| g_rtn
/* Average Absence Duration by Emp */|| g_rtn ||'
,DECODE('|| l_dynmc_hdc_curr||',0, to_number(NULL)
       ,(babs.curr_abs_drtn / '|| l_dynmc_hdc_curr||' )
	   )                              HRI_P_MEASURE13
,DECODE('|| l_dynmc_hdc_curr||' ,0,to_number(NULL)
       ,(babs.comp_abs_drtn / '|| l_dynmc_hdc_curr||' )
	   )                              HRI_P_MEASURE14'|| g_rtn
/* Total Workforce */|| g_rtn ||'
,NVL(tot_curr_hdc_end,0)                  HRI_P_GRAND_TOTAL1
,NVL(tot_comp_hdc_end,0)                  HRI_P_GRAND_TOTAL2'|| g_rtn
/* Total Absence  */|| g_rtn ||'
,NVL(babs.curr_tot_abs_in_period,0)       HRI_P_GRAND_TOTAL3
,NVL(babs.comp_tot_abs_in_period,0)       HRI_P_GRAND_TOTAL4'|| g_rtn
/* Total Notification  */|| g_rtn ||'
,NVL(babs.curr_tot_abs_ntfctn_period,0)   HRI_P_GRAND_TOTAL5
,NVL(babs.comp_tot_abs_ntfctn_period,0)   HRI_P_GRAND_TOTAL6'|| g_rtn
/* Total Average Notification */|| g_rtn ||'
,DECODE(babs.curr_tot_abs_ntfctn_period,0, to_number(NULL)
       ,DECODE(babs.curr_abs_in_period,0, to_number(NULL)
              ,(babs.curr_tot_abs_ntfctn_period / babs.curr_tot_abs_in_period)
	          )
       )                                  HRI_P_GRAND_TOTAL7
,DECODE(babs.comp_tot_abs_ntfctn_period,0, to_number(NULL)
       ,DECODE(babs.comp_tot_abs_in_period,0, to_number(NULL)
              ,(babs.comp_tot_abs_ntfctn_period / babs.comp_tot_abs_in_period)
	          )
       )                                  HRI_P_GRAND_TOTAL8'|| g_rtn
/* Total Absence Duration */|| g_rtn ||'
,NVL(babs.curr_tot_abs_drtn,0)            HRI_P_GRAND_TOTAL9
,NVL(babs.comp_tot_abs_drtn,0)            HRI_P_GRAND_TOTAL10'|| g_rtn
/* Total Average Absence Duration  */|| g_rtn ||'
,DECODE(babs.curr_tot_abs_in_period,0, to_number(NULL)
       ,(babs.curr_tot_abs_drtn  / babs.curr_tot_abs_in_period)
	   )                              HRI_P_GRAND_TOTAL11
,DECODE(babs.comp_tot_abs_in_period,0, to_number(NULL)
       ,(babs.comp_tot_abs_drtn  / babs.comp_tot_abs_in_period)
	   )                              HRI_P_GRAND_TOTAL12'|| g_rtn
/* Total Average Absence Duration by Emp */	|| g_rtn ||'
,DECODE('||l_dynmc_tot_hdc_curr||' ,0, to_number(NULL)
       ,(babs.curr_tot_abs_drtn  / '||l_dynmc_tot_hdc_curr||' )
	   )                              HRI_P_GRAND_TOTAL13
,DECODE('||l_dynmc_tot_hdc_comp||' ,0, to_number(NULL)
       ,(babs.comp_tot_abs_drtn  / '||l_dynmc_tot_hdc_comp||' )
	   )                              HRI_P_GRAND_TOTAL14
FROM
(
SELECT
/* Base Measures */
 wfact.vby_id                               vby_id
,wfact.vby_id                               value
,wfact.direct_ind
,NVL(wfact.curr_hdc_start,0)                curr_hdc_start
,NVL(wfact.comp_hdc_start,0)                comp_hdc_start
,NVL(wfact.curr_hdc_end,0)                  curr_hdc_end
,NVL(wfact.comp_hdc_end,0)                  comp_hdc_end
,NVL(afact.'|| l_dynmc_drtn_curr ||',0)     curr_abs_drtn
,NVL(afact.curr_abs_in_period,0)            curr_abs_in_period
,NVL(afact.'|| l_dynmc_drtn_comp ||',0)     comp_abs_drtn
,NVL(afact.comp_abs_in_period,0)            comp_abs_in_period
,NVL(afact.curr_abs_ntfctn_period,0)        curr_abs_ntfctn_period
,NVL(afact.comp_abs_ntfctn_period,0)        comp_abs_ntfctn_period
,SUM(wfact.curr_hdc_start) OVER()           tot_curr_hdc_start
,SUM(wfact.comp_hdc_start) OVER()           tot_comp_hdc_start
,SUM(wfact.curr_hdc_end) OVER()             tot_curr_hdc_end
,SUM(wfact.comp_hdc_end) OVER()             tot_comp_hdc_end
,SUM(afact.'|| l_dynmc_drtn_curr ||') OVER()
                                            curr_tot_abs_drtn
,SUM(afact.curr_abs_in_period) OVER()       curr_tot_abs_in_period
,SUM(afact.'|| l_dynmc_drtn_comp ||') OVER()
                                            comp_tot_abs_drtn
,SUM(afact.comp_abs_in_period) OVER()       comp_tot_abs_in_period
,SUM(afact.curr_abs_ntfctn_period) OVER()   curr_tot_abs_ntfctn_period
,SUM(afact.comp_abs_ntfctn_period) OVER()   comp_tot_abs_ntfctn_period
FROM
('|| l_abs_fact_sql ||') afact
,('|| l_wrkfc_fact_sql ||') wfact
WHERE
    afact.vby_id (+) = wfact.vby_id
 ' || l_security_clause || '
) babs';

  x_custom_sql := l_SQLText ;

END get_sql_kpi;

END HRI_OLTP_PMV_ABS_WMV_PVT;

/
