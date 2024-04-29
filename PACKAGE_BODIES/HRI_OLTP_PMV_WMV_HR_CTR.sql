--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_HR_CTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_HR_CTR" AS
/* $Header: hriopwhc.pkb 120.7 2006/01/11 06:29:52 jrstewar noship $ */

  g_rtn   VARCHAR2(30) := '
';

-- *********************************
-- * AK SQL For HR Staff Ratio KPI *
-- * AK Region : HRI_K_WMV_HR      *
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

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Force view by manager */
  l_parameter_rec.view_by := 'HRI_PERSON+HRI_PER_USRDR_H';

/* Force usage of CHO: Named User Profile Option as the Manager bind */
  l_bind_tab('HRI_PERSON+HRI_PER_USRDR_H').pmv_bind_string :=
     'NVL(hri_bpl_security.get_apps_signin_person_id, -1)';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.kpi_mode := 'Y';
  l_wrkfc_fact_params.bucket_dim := 'JOB+PRIMARY_JOB_ROLE';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_HR_CTR_SUP.GET_KPI');

l_SQLText :=
'SELECT -- HR Staff KPIs
 vby.id                         VIEWBYID
,vby.value                      VIEWBY
,tab.curr_hdc_end               HRI_P_MEASURE1
,tab.comp_hdc_end               HRI_P_MEASURE2
,tab.curr_hdc_hr                HRI_P_MEASURE3
,tab.comp_hdc_hr                HRI_P_MEASURE4
,DECODE(tab.curr_hdc_hr,
          0, to_number(null),
        tab.curr_hdc_end / tab.curr_hdc_hr)
                                HRI_P_MEASURE5
,DECODE(tab.comp_hdc_hr,
          0, to_number(null),
        tab.comp_hdc_end / tab.comp_hdc_hr)
                                HRI_P_MEASURE6
,tab.curr_hdc_end               HRI_P_GRAND_TOTAL1
,tab.comp_hdc_end               HRI_P_GRAND_TOTAL2
,tab.curr_hdc_hr                HRI_P_GRAND_TOTAL3
,tab.comp_hdc_hr                HRI_P_GRAND_TOTAL4
,DECODE(tab.curr_hdc_hr,
          0, to_number(null),
        tab.curr_hdc_end / tab.curr_hdc_hr)
                                HRI_P_GRAND_TOTAL5
,DECODE(tab.comp_hdc_hr,
          0, to_number(null),
        tab.comp_total_hdc_end / tab.comp_hdc_hr)
                                HRI_P_GRAND_TOTAL6
FROM
 hri_dbi_cl_per_n_v  vby
,(' || l_wrkfc_fact_sql || ')  tab
WHERE tab.vby_id = vby.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.effective_start_date
                          AND vby.effective_end_date ';

  x_custom_sql := l_SQLText;

END GET_KPI;


--* AK SQL For HR Staff Ratio by Country                                     *
--* AK Region : HRI_OLTP_PMV_WMV_HR_CTR_SUP                                   *
--****************************************************************************
--
PROCEDURE GET_SQL2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                  ,x_custom_sql  OUT NOCOPY VARCHAR2
                  ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Pre-calculations */
  l_drill_url            VARCHAR2(1000);

/* translation values */
  l_others_string        VARCHAR2(80);

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

BEGIN
/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Translate 'others' string */
   l_others_string := hri_oltp_view_message.get_others_msg;

/* Set l_drill_url to null to turn off drill to regions report */
  l_drill_url := '' ;

/* Force view by country */
  l_parameter_rec.view_by := 'GEOGRAPHY+COUNTRY';

/* Force usage of CHO: Named User Profile Option as the Manager bind */
  l_bind_tab('HRI_PERSON+HRI_PER_USRDR_H').pmv_bind_string :=
     'NVL(hri_bpl_security.get_apps_signin_person_id, -1)';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.bucket_dim := 'JOB+PRIMARY_JOB_ROLE';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_HR_CTR_SUP.GET_SQL2');

l_SQLText :=
'SELECT -- HR Staff Ratio by Country
 vby.value                      HRI_P_GEO_CTY_CN
,tab.curr_hdc_end               HRI_P_MEASURE1
,tab.comp_hdc_end               HRI_P_MEASURE2
,tab.curr_hdc_hr                HRI_P_MEASURE3
,tab.comp_hdc_hr                HRI_P_MEASURE4
,ROUND(DECODE(tab.curr_hdc_hr,
          0, to_number(null),
        tab.curr_hdc_end / tab.curr_hdc_hr),0)
                                HRI_P_MEASURE5
,DECODE(tab.comp_hdc_hr,
          0, to_number(null),
        tab.comp_hdc_end / tab.comp_hdc_hr)
                                HRI_P_MEASURE6
,SUM(tab.curr_hdc_end) OVER ()  HRI_P_GRAND_TOTAL1
,tab.comp_total_hdc_end         HRI_P_GRAND_TOTAL2
,SUM(tab.curr_hdc_hr) OVER ()   HRI_P_GRAND_TOTAL3
,tab.comp_total_hdc_hr          HRI_P_GRAND_TOTAL4
,DECODE(SUM(tab.curr_hdc_hr) OVER (),
          0, to_number(null),
        SUM(tab.curr_hdc_end) OVER () / SUM(tab.curr_hdc_hr) OVER ())
                                HRI_P_GRAND_TOTAL5
,DECODE(SUM(tab.comp_total_hdc_hr) OVER (),
          0, to_number(null),
        SUM(tab.comp_total_hdc_end) OVER () / SUM(tab.comp_total_hdc_hr) OVER ())
                                HRI_P_GRAND_TOTAL6
,0 - tab.curr_hdc_end           HRI_P_ORDER_BY_1
,tab.vby_id                     HRI_P_CHAR1_GA
FROM
 hri_dbi_cl_geo_country_v  vby
,(' || l_wrkfc_fact_sql || ')  tab
WHERE vby.id = tab.vby_id
ORDER BY ' || hri_oltp_pmv_util_pkg.set_default_order_by
               (p_order_by_clause => l_parameter_rec.order_by);

  x_custom_sql := '-- View by: ' || l_parameter_rec.view_by || g_rtn || l_SQLText;

END get_sql2;


END hri_oltp_pmv_wmv_hr_ctr;

/
