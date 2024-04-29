--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SAL_SUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SAL_SUP_PVT" AS
/* $Header: hriopwsp.pkb 120.6 2005/11/30 06:05:39 cbridge noship $ */

g_rtn                VARCHAR2(30) := '
';

--
--****************************************************************************
--*  RE-ARCH
--* AK SQL For Headcount and Salary by Country Status                        *
--* AK Region : HRI_P_WMV_SAL_CTR_SUP_PVT                                    *
--****************************************************************************
--
PROCEDURE get_sql_ctr2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql  OUT NOCOPY VARCHAR2
                      ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
       IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Pre-calculations */
  l_drill_url             VARCHAR2(1000);

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

/* Set l_drill_url to null to turnoff drill  */
 l_drill_url := '' ; -- bug 3696662, turned off drill url

                -- 'pFunctionName=HRI_P_WMV_SAL_RGN_SUP&' ||
                -- 'HRI_P_GEO_CTY_CN=HRI_P_GEO_CTY_CN&' ||
                -- 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                -- 'pParamIds=Y';

/* Set order by */
  l_parameter_rec.order_by :=  hri_oltp_pmv_util_pkg.set_default_order_by
                                (p_order_by_clause => l_parameter_rec.order_by);

/* Force view by to country */
  l_parameter_rec.view_by := 'GEOGRAPHY+COUNTRY';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_PVT.GET_SQL_CTR2');

l_SQLText :=
    ' -- Headcount and Salary by Country Status
SELECT
 tab.order_by         HRI_P_ORDER_BY_1
,ctr.value            HRI_P_MEASURE1
,tab.wmv_curr         HRI_P_WMV_SUM_MV
,tab.wmv_prev         HRI_P_WMV_SUM_PREV_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.wmv_prev',
        p_current_col  => 'tab.wmv_curr') || '
                                HRI_P_WMV_CHNG_PCT_SUM_MV
,tab.sal_curr         HRI_P_MEASURE2
,tab.sal_prev         HRI_P_MEASURE3
,tab.avg_sal          HRI_P_MEASURE4
,NVL(tab.avg_sal_prev,0)        HRI_P_MEASURE5
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.avg_sal_prev',
        p_current_col  => 'tab.avg_sal') || '
                                HRI_P_MEASURE6
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col =>
'DECODE(tab.tot_wmv_prev, 0, to_number(null), tab.tot_sal_prev / tab.tot_wmv_prev)',
        p_current_col  =>
'DECODE(tab.tot_wmv_curr, 0, to_number(null), tab.tot_sal_curr / tab.tot_wmv_curr)') || '
                      HRI_P_GRAND_TOTAL1
,DECODE(tab.tot_wmv_curr,
          0, to_number(null),
        tab.tot_sal_curr/tab.tot_wmv_curr)
                      HRI_P_GRAND_TOTAL2
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.tot_wmv_prev',
        p_current_col  => 'tab.tot_wmv_curr') || '
                      HRI_P_GRAND_TOTAL3
,tab.country_code     HRI_P_GEO_CTY_CN
,'''||l_drill_url||'''
                      HRI_P_CHAR1_GA
FROM
 hri_dbi_cl_geo_country_v   ctr
,(SELECT
   bc.vby_id              country_code
  ,-bc.curr_hdc_end       order_by
  ,bc.curr_hdc_end        wmv_curr
  ,bc.comp_hdc_end        wmv_prev
  ,bc.curr_sal_end        sal_curr
  ,DECODE(bc.curr_hdc_end,
            0, to_number(null),
          bc.curr_sal_end / bc.curr_hdc_end)
                          avg_sal
  ,bc.comp_sal_end        sal_prev
  ,DECODE(bc.comp_hdc_end,
            0, to_number(null),
          bc.comp_sal_end / bc.comp_hdc_end)
                          avg_sal_prev
  ,SUM(bc.curr_hdc_end) OVER ()  tot_wmv_curr
  ,SUM(bc.curr_sal_end) OVER ()  tot_sal_curr
  ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
  ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
  FROM
   (' || l_wrkfc_fact_sql || ')   bc
  WHERE (bc.curr_hdc_end > 0
      OR bc.comp_hdc_end > 0
      OR bc.curr_sal_end > 0
      OR bc.comp_sal_end > 0)
 ) tab
WHERE tab.country_code = ctr.id
' || l_security_clause || '
ORDER BY
 HRI_P_ORDER_BY_1
,HRI_P_MEASURE4
,HRI_P_MEASURE1';

  x_custom_sql := l_SQLText ;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END get_sql_ctr2;
--
--****************************************************************************
--* RE-ARCH
--* AK SQL For Headcount and Salary by Region                                *
--* AK Region : HRI_P_WMV_SAL_RGN_SUP                                        *
--****************************************************************************
--
PROCEDURE get_sql_rgn2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                      ,x_custom_sql  OUT NOCOPY VARCHAR2
                      ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
                      IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Pre-calculations */
  l_drill_url             VARCHAR2(1000);
  l_country_code          VARCHAR2(1000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header          VARCHAR(550);

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

/* Set l_drill_url to null to turnoff drill  Drilling to Rearch Report*/
  l_drill_url := 'pFunctionName=HRI_P_WMV_SAL_CIT_SUP&'||
                 'HRI_P_GEO_REG_CN=HRI_P_GEO_REG_CN&'||
                 'HRI_P_CHAR2_GA=HRI_P_CHAR2_GA&'||
                 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&pParamIds=Y';

/* Force view by to region */
  l_parameter_rec.view_by := 'GEOGRAPHY+REGION';

/* Get the country code */
  l_country_code := ltrim(rtrim(l_bind_tab('GEOGRAPHY+COUNTRY').sql_bind_string
                                ,'''')
                         ,'''');

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_PVT.GET_SQL_RGN2');

l_SQLText :=
    ' -- Headcount and Salary by Region Status
SELECT
 tab.order_by       HRI_P_ORDER_BY_1
,rgn.value          HRI_P_MEASURE1
,tab.wmv_curr       HRI_P_WMV_SUM_MV
,tab.wmv_prev       HRI_P_WMV_SUM_PREV_MV
,tab.sal_curr       HRI_P_MEASURE2
,tab.sal_prev       HRI_P_MEASURE3
,tab.avg_sal        HRI_P_MEASURE4 ' || g_rtn ||
/* Test whether tot_wmv_prev or tot_sal_prev is zero */
',DECODE(DECODE(tab.tot_wmv_prev, 0, 0,
                  tab.tot_sal_prev / tab.tot_wmv_prev), ' || g_rtn ||
/* If either is zero then return 0 if the total salary is zero otherwise 100 */
'              0, DECODE(tab.tot_sal_curr, 0, 0, 100), ' || g_rtn ||
/* Otherwise if tot_sal_prev <> 0 and tot_wmv_prev <> 0 */
'            ((DECODE(tab.tot_wmv_curr, 0, 0,
                      (tab.tot_sal_curr / tab.tot_wmv_curr)
                     ) -
               (tab.tot_sal_prev/tab.tot_wmv_prev)
              ) /
              (tab.tot_sal_prev/tab.tot_wmv_prev)
             ) * 100)   HRI_P_GRAND_TOTAL1
,DECODE(tab.tot_wmv_curr,
          0, tab.tot_sal_curr,
        tab.tot_sal_curr / tab.tot_wmv_curr)
                        HRI_P_GRAND_TOTAL2
,DECODE(tab.tot_wmv_prev, 0, 100,
        (tab.tot_wmv_curr - tab.tot_wmv_prev) * 100 / tab.tot_wmv_prev)
                        HRI_P_GRAND_TOTAL3
,tab.region_code        HRI_P_GEO_REG_CN
,tab.country_code       HRI_P_CHAR2_GA
,'''||l_drill_url||'''
                    HRI_P_CHAR1_GA
FROM
 hri_dbi_cl_geo_region_v  rgn
,(SELECT
   bc.vby_id              region_code
  ,:HRI_COUNTRY_CODE      country_code
  ,-bc.curr_hdc_end       order_by
  ,bc.curr_hdc_end        wmv_curr
  ,bc.comp_hdc_end        wmv_prev
  ,bc.curr_sal_end        sal_curr
  ,DECODE(bc.curr_hdc_end,
            0, bc.curr_sal_end,
          bc.curr_sal_end / bc.curr_hdc_end)
                          avg_sal
  ,bc.comp_sal_end        sal_prev
  ,SUM(bc.curr_hdc_end) OVER ()  tot_wmv_curr
  ,SUM(bc.curr_sal_end) OVER ()  tot_sal_curr
  ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
  ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
  FROM
   (' || l_wrkfc_fact_sql || ')   bc
  WHERE (bc.curr_hdc_end > 0
      OR bc.comp_hdc_end > 0
      OR bc.curr_sal_end > 0
      OR bc.comp_sal_end > 0)
 ) tab
WHERE tab.region_code = rgn.id
' || l_security_clause || '
ORDER BY
 HRI_P_ORDER_BY_1
,HRI_P_MEASURE4
,HRI_P_MEASURE1';

  x_custom_sql := l_SQLText ;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COUNTRY_CODE';
  l_custom_rec.attribute_value := l_country_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END get_sql_rgn2;
--
--****************************************************************************
--* RE-ARCH                                                                  *
--* AK SQL For Headcount and Salary by City                                  *
--* AK City : HRI_P_WMV_SAL_CIT_SUP                                          *
--****************************************************************************
--
  PROCEDURE get_sql_cit2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                        ,x_custom_sql  OUT NOCOPY VARCHAR2
                        ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                        )
         IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Pre-calculations */
  l_drill_url             VARCHAR2(1000);

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_debug_header          VARCHAR(550);
  l_country_code          VARCHAR2(240);
  l_region_code           VARCHAR(240);

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

/* Get parameter values for geography */
  l_region_code := ltrim(rtrim(l_bind_tab('GEOGRAPHY+REGION').sql_bind_string
                                ,'''')
                         ,'''');

  l_country_code := ltrim(rtrim(l_bind_tab('GEOGRAPHY+COUNTRY').sql_bind_string
                                ,'''')
                         ,'''');

/* bug 3330395 */
  IF (l_region_code = '-1') THEN
      l_region_code := 'NA_EDW';
  END IF; /* bug 3330395 */

/* Set l_drill_url to null to turnoff drill  Drilling to Rearch Report*/
  l_drill_url := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&'||
                 'HRI_P_GEO_CIT_CN=HRI_P_GEO_CIT_CN&'||
                 'HRI_P_GEO_REG_CN=HRI_P_CHAR3_GA&'||
                 'HRI_P_CHAR4_GA=HRI_P_CHAR4_GA&'||
                 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&pParamIds=Y';

/* Force city view by */
  l_parameter_rec.view_by := 'GEOGRAPHY+CITY';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_PVT.GET_SQL_CIT2');

/* Format SQL Query for report */
l_SQLText :=
    ' -- Headcount and Salary by City Status
SELECT
 tab.order_by           HRI_P_ORDER_BY_1
,cty.value              HRI_P_MEASURE1
,tab.wmv_curr,0)        HRI_P_WMV_SUM_MV
,tab.wmv_prev,0)        HRI_P_WMV_SUM_PREV_MV
,tab.sal_curr,0)        HRI_P_MEASURE2
,tab.sal_prev,0)        HRI_P_MEASURE3
,tab.avg_sal            HRI_P_MEASURE4 ' || g_rtn ||
/* Test whether tot_wmv_prev or tot_sal_prev is zero */
',DECODE(DECODE(tab.tot_wmv_prev, 0, 0,
                tab.tot_sal_prev / tab.tot_wmv_prev), ' || g_rtn ||
/* If either is zero then return 0 if the total salary is zero otherwise 100 */
'              0, DECODE(tab.tot_sal_curr, 0, 0, 100), ' || g_rtn ||
/* Otherwise if tot_sal_prev <> 0 and tot_wmv_prev <> 0 */
'            ((DECODE(tab.tot_wmv_curr, 0, 0,
                      (tab.tot_sal_curr / tab.tot_wmv_curr)
                     ) -
               (tab.tot_sal_prev / tab.tot_wmv_prev)
              ) /
              (tab.tot_sal_prev / tab.tot_wmv_prev)
             ) * 100)   HRI_P_GRAND_TOTAL1
,DECODE(tab.tot_wmv_curr,
          0, tab.tot_sal_curr,
        tab.tot_sal_curr/tab.tot_wmv_curr)
                        HRI_P_GRAND_TOTAL2
,DECODE(tab.tot_wmv_prev, 0, 100,
        ((tab.tot_wmv_curr - tab.tot_wmv_prev) * 100 / tab.tot_wmv_prev)
                        HRI_P_GRAND_TOTAL3
,tab.country_code       HRI_P_CHAR4_GA
,tab.region_code        HRI_P_CHAR3_GA
,cty.id                 HRI_P_GEO_CIT_CN
,'''||l_drill_url||'''  HRI_P_CHAR1_GA
FROM(
 hri_dbi_cl_geo_city_v  cty
,(SELECT
   bc.vby_id              city_cid
  ,:HRI_COUNTRY_CODE      country_code
  ,:HRI_REGION_CODE       region_code
  ,-bc.curr_hdc_end       order_by
  ,bc.curr_hdc_end        wmv_curr
  ,bc.comp_hdc_end        wmv_prev
  ,bc.curr_sal_end        sal_curr
  ,DECODE(bc.curr_hdc_end,
            0, bc.curr_sal_end,
          bc.curr_sal_end / bc.curr_hdc_end)
                          avg_sal
  ,bc.comp_sal_end        sal_prev
  ,SUM(bc.curr_hdc_end) OVER ()  tot_wmv_curr
  ,SUM(bc.curr_sal_end) OVER ()  tot_sal_curr
  ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
  ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
  FROM
   (' || l_wrkfc_fact_sql || ')   bc
  WHERE (bc.curr_hdc_end > 0
      OR bc.comp_hdc_end > 0
      OR bc.curr_sal_end > 0
      OR bc.comp_sal_end > 0)
 ) tab
WHERE tab.city_cid = cty.id
' || l_security_clause || '
ORDER BY
 HRI_P_ORDER_BY_1
,HRI_P_MEASURE4
,HRI_P_MEASURE1';

  x_custom_sql :=  l_SQLText ;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_COUNTRY_CODE';
  l_custom_rec.attribute_value := l_country_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':HRI_REGION_CODE';
  l_custom_rec.attribute_value := l_region_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

END get_sql_cit2;

--
--****************************************************************************
--* RE-ARCH                                                                  *
--* AK SQL For Headcount and Salary by Job Function                          *
--* AK City : HRI_P_WMV_SAL_JFM_SUP                                          *
--****************************************************************************
--
PROCEDURE get_sql_jfm2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext          VARCHAR2(32767) ;
  l_security_clause  VARCHAR2(4000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Pre-calculations */

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

/* Force view by to job level 1 */
  l_parameter_rec.view_by := 'JOB+JOB_FUNCTION';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_PVT.GET_SQL_JFM2');

/* Format SQL Query for report */
  l_sqltext :=
'SELECT -- Salary by Job Function Status
 tab.order_by            HRI_P_ORDER_BY_1
,jfn.value               HRI_P_JOB_FAMILY_CN
,tab.wmv_curr            HRI_P_WMV_SUM_MV
,tab.sal_curr            HRI_P_SAL_ANL_CUR_PARAM_SUM_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.sal_prev',
        p_current_col  => 'tab.sal_curr') || '
                         HRI_P_MEASURE5
,tab.avg_sal_curr        HRI_P_MEASURE1
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.avg_sal_prev',
        p_current_col  => 'tab.avg_sal_curr') || '
                         HRI_P_MEASURE2
,tab.avg_sal_prev        HRI_P_MEASURE3
,tab.tot_sal_prev        HRI_P_MEASURE4
,tab.tot_wmv_curr        HRI_P_GRAND_TOTAL1
,tab.tot_sal_curr        HRI_P_GRAND_TOTAL2
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.tot_sal_prev',
        p_current_col  => 'tab.tot_sal_curr') || '
                         HRI_P_GRAND_TOTAL7
,DECODE(tab.tot_wmv_curr, 0, to_number(null),
        tab.tot_sal_curr / tab.tot_wmv_curr)
                         HRI_P_GRAND_TOTAL3
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col =>
 'DECODE(tab.tot_wmv_prev, 0, 0, tab.tot_sal_prev/tab.tot_wmv_prev)',
        p_current_col  =>
'DECODE(SUM(tab.wmv_curr) over(), 0, to_number(null),
 (SUM(tab.sal_curr) over() / SUM(tab.wmv_curr) over()))') || '
                         HRI_P_GRAND_TOTAL4
,decode(tab.tot_wmv_prev,
          0, to_number(null),
        tab.tot_sal_prev/tab.tot_wmv_prev)
                         HRI_P_GRAND_TOTAL5
,tab.tot_sal_prev        HRI_P_GRAND_TOTAL6
,tab.job_fnctn_code      HRI_P_CHAR1_GA
FROM
 hri_cl_job_function_v  jfn
,(SELECT
   bc.vby_id              job_fnctn_code
  ,-bc.curr_hdc_end       order_by
  ,bc.curr_hdc_end        wmv_curr
  ,bc.comp_hdc_end        wmv_prev
  ,bc.curr_sal_end        sal_curr
  ,DECODE(bc.curr_hdc_end,
            0, to_number(null),
          bc.curr_sal_end / bc.curr_hdc_end)
                          avg_sal_curr
  ,DECODE(bc.comp_hdc_end,
            0, to_number(null),
          bc.comp_sal_end / bc.comp_hdc_end)
                          avg_sal_prev
  ,bc.comp_sal_end        sal_prev
  ,SUM(bc.curr_hdc_end) OVER ()  tot_wmv_curr
  ,SUM(bc.curr_sal_end) OVER ()  tot_sal_curr
  ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
  ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
  FROM
   (' || l_wrkfc_fact_sql || ')   bc
  WHERE (bc.curr_hdc_end > 0
      OR bc.comp_hdc_end > 0
      OR bc.curr_sal_end > 0
      OR bc.comp_sal_end > 0)
 ) tab
WHERE tab.job_fnctn_code = jfn.id
' || l_security_clause || '
&ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END get_sql_jfm2;

--
--****************************************************************************
--* RE-ARCH                                                                  *
--* AK SQL For Headcount and Salary by Job Family                            *
--* AK City : HRI_P_WMV_SAL_JFMFN_SUP                                        *
--****************************************************************************
--
PROCEDURE get_sql_jfmfn2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         x_custom_sql  OUT NOCOPY VARCHAR2,
                         x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767) ;
  l_security_clause       VARCHAR2(4000);
  l_job_family_condition  VARCHAR2(100);

  l_custom_rec BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Pre-calculations */

  l_job_function_code    VARCHAR2(240);

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

/* Get the job level 1 parameter, if set */
  BEGIN
    l_job_function_code := ltrim(rtrim(l_bind_tab('JOB+JOB_FUNCTION').sql_bind_string
                                    ,'''')
                              ,'''');
  EXCEPTION WHEN OTHERS THEN
    null;
  END;

/* Set job family value for Unassigned */
  IF (l_job_function_code = '-1') THEN
    l_job_function_code := 'NA_EDW';
  END IF;

/* Force view by to job level 2 */
  l_parameter_rec.view_by := 'JOB+JOB_FAMILY';

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_PVT.GET_SQL_JFMFN2');

/* Format SQL Query for report */
  l_sqltext :=
'SELECT -- Salary by Job Family Status
 tab.order_by         HRI_P_ORDER_BY_1
,jfm.value            HRI_P_JOB_LVL2_CN
,tab.wmv_curr         HRI_P_WMV_SUM_MV
,tab.sal_curr         HRI_P_SAL_ANL_CUR_PARAM_SUM_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.sal_prev',
        p_current_col  => 'tab.sal_curr') || '
                      HRI_P_MEASURE5
,tab.avg_sal_curr     HRI_P_MEASURE1
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.avg_sal_prev',
        p_current_col  => 'tab.avg_sal_curr') || '
                      HRI_P_MEASURE2
,tab.avg_sal_prev     HRI_P_MEASURE3
,tab.tot_sal_prev     HRI_P_MEASURE4
,tab.tot_wmv_curr     HRI_P_GRAND_TOTAL1
,tab.tot_sal_curr     HRI_P_GRAND_TOTAL2
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.tot_sal_prev',
        p_current_col  => 'tab.tot_sal_curr') || '
                      HRI_P_GRAND_TOTAL7
,DECODE(tab.tot_wmv_curr, 0, to_number(null),
        tab.tot_sal_curr / tab.tot_wmv_curr)
                      HRI_P_GRAND_TOTAL3
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col =>
 'DECODE(tab.tot_wmv_prev, 0, to_number(null), tab.tot_sal_prev/tab.tot_wmv_prev)',
        p_current_col  =>
'DECODE(SUM(tab.wmv_curr) over(), 0, to_number(null),
 (SUM(tab.sal_curr) over() / SUM(tab.wmv_curr) over()))') || '
                      HRI_P_GRAND_TOTAL4
,decode(tab.tot_wmv_prev,
          0, to_number(null),
        tab.tot_sal_prev/tab.tot_wmv_prev)
                      HRI_P_GRAND_TOTAL5
,tab.tot_sal_prev     HRI_P_GRAND_TOTAL6
,:HRI_JOB_FUNCTION    HRI_P_CHAR1_GA
,tab.job_fmly_code    HRI_P_CHAR2_GA
FROM
 hri_cl_job_family_v  jfm
,(SELECT
   bc.vby_id              job_fmly_code
  ,-bc.curr_hdc_end       order_by
  ,bc.curr_hdc_end        wmv_curr
  ,bc.comp_hdc_end        wmv_prev
  ,bc.curr_sal_end        sal_curr
  ,DECODE(bc.curr_hdc_end,
            0, to_number(null),
          bc.curr_sal_end / bc.curr_hdc_end)
                          avg_sal_curr
  ,DECODE(bc.comp_hdc_end,
            0, to_number(null),
          bc.comp_sal_end / bc.comp_hdc_end)
                          avg_sal_prev
  ,bc.comp_sal_end        sal_prev
  ,SUM(bc.curr_hdc_end) OVER ()  tot_wmv_curr
  ,SUM(bc.curr_sal_end) OVER ()  tot_sal_curr
  ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
  ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
  FROM
   (' || l_wrkfc_fact_sql || ')   bc
  WHERE (bc.curr_hdc_end > 0
      OR bc.comp_hdc_end > 0
      OR bc.curr_sal_end > 0
      OR bc.comp_sal_end > 0)
 ) tab
WHERE tab.job_fmly_code = jfm.id
' || l_security_clause || '
&ORDER_BY_CLAUSE';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_JOB_FUNCTION';
  l_custom_rec.attribute_value := l_job_function_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
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

END get_sql_jfmfn2;

END HRI_OLTP_PMV_WMV_SAL_SUP_PVT;

/
