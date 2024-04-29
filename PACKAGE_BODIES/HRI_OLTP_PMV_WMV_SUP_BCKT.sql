--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SUP_BCKT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SUP_BCKT" AS
/* $Header: hriophrp.pkb 120.5 2005/10/26 07:53:52 jrstewar noship $ */

  g_rtn   VARCHAR2(5) := '
';

TYPE dynamic_sql_rec_type IS RECORD
 (viewby_condition       VARCHAR2(1000),
  wrkfc_outer_join       VARCHAR2(5),
  drill_mgr_sup          VARCHAR2(1000),
  drill_to_detail        VARCHAR2(1000),
  display_row_condition  VARCHAR2(1000),
  order_by               VARCHAR2(1000),
  wkth_wktyp_sk_fk       VARCHAR2(10),
  drill_url2             VARCHAR2(1000),
  drill_url3             VARCHAR2(1000),
  drill_url4             VARCHAR2(1000),
  drill_url5             VARCHAR2(1000),
  drill_url6             VARCHAR2(1000),
  drill_url7             VARCHAR2(1000),
  drill_url8             VARCHAR2(1000),
  drill_url9             VARCHAR2(1000),
  drill_url10            VARCHAR2(1000)
);


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


/* Dynamically changes report SQL depending on parameters */
PROCEDURE set_dynamic_sql
      (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
       p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
       p_bucket_dim     IN VARCHAR2,
       p_dynsql_rec     OUT NOCOPY dynamic_sql_rec_type) IS

  l_drill_to_function     VARCHAR2(40);
  l_drill_to_function_direct
                          VARCHAR2(40);
  l_wkth_wktyp_sk_fk      VARCHAR2(10);
  l_parameter_count       PLS_INTEGER;
  l_parameter_name        VARCHAR2(80);

BEGIN

/* Set the order by */
  p_dynsql_rec.order_by :=  hri_oltp_pmv_util_pkg.set_default_order_by
                             (p_order_by_clause => p_parameter_rec.order_by);

/* View by Person */
/******************/
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN

    IF (p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_LOW' OR
        p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_LOW_PVT') THEN
      l_drill_to_function := 'HRI_P_WMV_BCKT_LOW_PVT';
      l_drill_to_function_direct := 'HRI_P_WMV_SAL_SUP_DTL';
    ELSIF (p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_PERF' OR
           p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_PERF_PVT') THEN
      l_drill_to_function := 'HRI_P_WMV_BCKT_PERF_PVT';
      l_drill_to_function_direct := 'HRI_P_WMV_SAL_SUP_DTL';
    ELSIF (p_parameter_rec.bis_region_code = 'HRI_P_WMV_C_BCKT_LOP_SUP' OR
           p_parameter_rec.bis_region_code = 'HRI_P_WMV_C_BCKT_LOP_PVT') THEN
      l_drill_to_function := 'HRI_P_WMV_C_BCKT_LOP_PVT';
      l_drill_to_function_direct := 'HRI_P_WMV_C_SUP_DTL';
    END IF;

  /* Set drill URLs */
    p_dynsql_rec.drill_mgr_sup := 'pFunctionName=' || l_drill_to_function || '&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'pParamIds=Y';

    p_dynsql_rec.drill_to_detail := 'pFunctionName=' || l_drill_to_function_direct || '&' ||
                                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                                  'pParamIds=Y';

    p_dynsql_rec.viewby_condition :=
'  AND &BIS_CURRENT_ASOF_DATE BETWEEN vby.start_date AND vby.end_date' || g_rtn;

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

  /* Only display rows with current headcount */
    p_dynsql_rec.display_row_condition :=
'AND (qry.curr_hdc > 0
  OR qry.direct_ind = 1)' || g_rtn;

  END IF;

  /* format the dynamic drill urls for certain regions only */
  IF (   p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_LOW_PVT'
      or p_parameter_rec.bis_region_code = 'HRI_P_WMV_C_BCKT_LOP_PVT') THEN

       /* set the corresponding drill to detail region code function */
       IF  p_parameter_rec.bis_region_code = 'HRI_P_WMV_BCKT_LOW_PVT' THEN
         l_drill_to_function_direct := 'HRI_P_WMV_SAL_SUP_DTL';
       ELSIF p_parameter_rec.bis_region_code = 'HRI_P_WMV_C_BCKT_LOP_PVT' THEN
         l_drill_to_function_direct := 'HRI_P_WMV_C_SUP_DTL';
       END IF;

       /* format the additional common dynamic drill urls */
       p_dynsql_rec.drill_url2 := 'pFunctionName='||l_drill_to_function_direct ||'&'||
                                   'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&'||
                                   'VIEW_BY_NAME=VIEW_BY_ID&'||
                                   'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'||
                                   'HRI_LOW+HRI_LOW_BAND_X='||
                                     convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                               ,1  -- bucket
                                                               ,p_parameter_rec.wkth_wktyp_sk_fk)
                                       ||'&'||
                                   'pParamIds=Y';
       p_dynsql_rec.drill_url3 := 'pFunctionName='||l_drill_to_function_direct ||'&'||
                                   'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&'||
                                   'VIEW_BY_NAME=VIEW_BY_ID&'||
                                   'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'||
                                   'HRI_LOW+HRI_LOW_BAND_X='||
                                     convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                               ,2  -- bucket
                                                               ,p_parameter_rec.wkth_wktyp_sk_fk)
                                       ||'&'||
                                   'pParamIds=Y';
       p_dynsql_rec.drill_url4 := 'pFunctionName='||l_drill_to_function_direct ||'&'||
                                   'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&'||
                                   'VIEW_BY_NAME=VIEW_BY_ID&'||
                                   'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'||
                                   'HRI_LOW+HRI_LOW_BAND_X='||
                                     convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                               ,3  -- bucket
                                                               ,p_parameter_rec.wkth_wktyp_sk_fk)
                                       ||'&'||
                                   'pParamIds=Y';
       p_dynsql_rec.drill_url5 := 'pFunctionName='||l_drill_to_function_direct ||'&'||
                                   'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&'||
                                   'VIEW_BY_NAME=VIEW_BY_ID&'||
                                   'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'||
                                   'HRI_LOW+HRI_LOW_BAND_X='||
                                     convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                               ,4  -- bucket
                                                               ,p_parameter_rec.wkth_wktyp_sk_fk)
                                       ||'&'||
                                   'pParamIds=Y';
       p_dynsql_rec.drill_url6 := 'pFunctionName='||l_drill_to_function_direct ||'&'||
                                   'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&'||
                                   'VIEW_BY_NAME=VIEW_BY_ID&'||
                                   'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&'||
                                   'HRI_LOW+HRI_LOW_BAND_X='||
                                     convert_low_bckt_to_sk_fk('HRI_LOW+HRI_LOW_BAND_X'
                                                               ,5  -- bucket
                                                               ,p_parameter_rec.wkth_wktyp_sk_fk)
                                       ||'&'||
                                   'pParamIds=Y';
  END IF;


END set_dynamic_sql;


/* Entry point for Headcount for Performance Band SQL */
PROCEDURE get_sql_bckt_perf
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Return information */
  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Dynamic SQL support */
  l_dynsql_rec        dynamic_sql_rec_type;
  l_security_clause   VARCHAR2(4000);
  l_direct_reports_string  VARCHAR2(100);

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Parameter values */
  l_parameter_rec       hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec => l_parameter_rec,
         p_bind_tab => l_bind_tab);

/* Set the dynamic sql portion */
  set_dynamic_sql(p_parameter_rec => l_parameter_rec,
                  p_bind_tab      => l_bind_tab,
                  p_bucket_dim    => 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X',
                  p_dynsql_rec    => l_dynsql_rec);

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.bucket_dim := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_BCKT.GET_SQL_BCKT_PERF');

  l_sqltext :=
'SELECT  -- Employee Headcount Ratio for Perf Band
 qry.id               VIEWBYID
,qry.value            VIEWBY
,DECODE(qry.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB' || g_rtn ||
/* Band 3 - High Performers */
',qry.curr_hdc_b3     HRI_P_MEASURE3
,DECODE(qry.curr_hdc, 0, 0,
         (qry.curr_hdc_b3/qry.curr_hdc)*100)
                          HRI_P_MEASURE3_MP
,qry.comp_hdc_b3      HRI_P_MEASURE8
,DECODE(qry.comp_hdc_b3, 0, to_number(NULL),
        (qry.curr_hdc_b3 - qry.comp_hdc_b3) * 100
       / qry.comp_hdc_b3) HRI_P_MEASURE8_MP' || g_rtn ||
/* Band 2 - Average Performers */
',qry.curr_hdc_b2     HRI_P_MEASURE2
,DECODE(qry.curr_hdc, 0, 0,
        (qry.curr_hdc_b2/qry.curr_hdc)*100)
                          HRI_P_MEASURE2_MP
,qry.comp_hdc_b2      HRI_P_MEASURE9
,DECODE(qry.comp_hdc_b2, 0, to_number(NULL),
        (qry.curr_hdc_b2 - qry.comp_hdc_b2) * 100
       / qry.comp_hdc_b2) HRI_P_MEASURE9_MP' || g_rtn ||
/* Band 1 - Low Performers */
',qry.curr_hdc_b1     HRI_P_MEASURE1
,DECODE(qry.curr_hdc, 0, 0,
        (qry.curr_hdc_b1/qry.curr_hdc)*100)
                          HRI_P_MEASURE1_MP
,qry.comp_hdc_b1      HRI_P_MEASURE10
,DECODE(qry.comp_hdc_b1, 0, to_number(NULL),
        (qry.curr_hdc_b1 - qry.comp_hdc_b1) * 100
       / qry.comp_hdc_b1) HRI_P_MEASURE10_MP' || g_rtn ||
/* Unassigned band - no performance rating */
',qry.curr_hdc_na        HRI_P_MEASURE6
,DECODE(qry.curr_hdc_na, 0, 0,
        (qry.curr_hdc_na/qry.curr_hdc)*100)
                          HRI_P_MEASURE6_MP
,qry.comp_hdc_na         HRI_P_MEASURE11
,DECODE(qry.comp_hdc_na, 0, to_number(NULL),
        (qry.curr_hdc_na - qry.comp_hdc_na) * 100
       / qry.comp_hdc_na)    HRI_P_MEASURE11_MP' || g_rtn ||
/* Row totals - Across all performance bands */
',qry.curr_hdc        HRI_P_MEASURE7
,qry.comp_hdc         HRI_P_MEASURE16' || g_rtn ||
/* Order by */
',qry.order_by              HRI_P_ORDER_BY_1' || g_rtn ||
/* Grand Totals */
',DECODE(qry.total_curr_hdc, 0, 0,
         (qry.total_curr_hdc_b3/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL1
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b2/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL2
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b1/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL3
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_na/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL4
,qry.total_comp_hdc_b3    HRI_P_GRAND_TOTAL5
,DECODE(qry.total_comp_hdc_b3, 0, 0,
        (qry.total_curr_hdc_b3 - qry.total_comp_hdc_b3) * 100/qry.total_comp_hdc_b3)
                          HRI_P_GRAND_TOTAL6
,qry.total_comp_hdc_b2    HRI_P_GRAND_TOTAL7
,DECODE(qry.total_comp_hdc_b2, 0, 0,
        (qry.total_curr_hdc_b2 - qry.total_comp_hdc_b2) * 100/qry.total_comp_hdc_b2)
                          HRI_P_GRAND_TOTAL8
,qry.total_comp_hdc_b1    HRI_P_GRAND_TOTAL9
,DECODE(qry.total_comp_hdc_b1, 0, 0,
        (qry.total_curr_hdc_b1 - qry.total_comp_hdc_b1) * 100/qry.total_comp_hdc_b1)
                          HRI_P_GRAND_TOTAL10
,qry.total_comp_hdc_na    HRI_P_GRAND_TOTAL11
,DECODE(qry.total_comp_hdc_na, 0, 0,
        (qry.total_curr_hdc_na - qry.total_comp_hdc_na) * 100/qry.total_comp_hdc_na)
                          HRI_P_GRAND_TOTAL12
,qry.total_comp_hdc       HRI_P_GRAND_TOTAL13
,DECODE(qry.direct_ind,0,'''',''N'') HRI_P_SUPH_RO_CA' || g_rtn ||
/* Drill URLs */
', DECODE(qry.direct_ind,
 0, ''' || l_dynsql_rec.drill_mgr_sup || ''',
 ''' || l_dynsql_rec.drill_to_detail || ''')  HRI_P_DRILL_URL1
FROM
(SELECT
/* View by */
  vby.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         vby.value)  value
 ,to_char(NVL(wmv.direct_ind, 0)) || vby.order_by  order_by
 ,NVL(wmv.curr_hdc_b1, 0)  curr_hdc_b1
 ,NVL(wmv.curr_hdc_b2, 0)  curr_hdc_b2
 ,NVL(wmv.curr_hdc_b3, 0)  curr_hdc_b3
 ,NVL(wmv.curr_hdc_na, 0)  curr_hdc_na
 ,NVL(wmv.curr_hdc_end, 0) curr_hdc
 ,NVL(wmv.comp_hdc_b1, 0)  comp_hdc_b1
 ,NVL(wmv.comp_hdc_b2, 0)  comp_hdc_b2
 ,NVL(wmv.comp_hdc_b3, 0)  comp_hdc_b3
 ,NVL(wmv.comp_hdc_na, 0)  comp_hdc_na
 ,NVL(wmv.comp_hdc_end, 0) comp_hdc
 ,NVL(SUM(wmv.curr_hdc_b1) OVER (), 0)  total_curr_hdc_b1
 ,NVL(SUM(wmv.curr_hdc_b2) OVER (), 0)  total_curr_hdc_b2
 ,NVL(SUM(wmv.curr_hdc_b3) OVER (), 0)  total_curr_hdc_b3
 ,NVL(SUM(wmv.curr_hdc_na) OVER (), 0)  total_curr_hdc_na
 ,NVL(SUM(wmv.curr_hdc_end) OVER (), 0) total_curr_hdc
 ,NVL(SUM(wmv.comp_total_hdc_b1) OVER (), 0)  total_comp_hdc_b1
 ,NVL(SUM(wmv.comp_total_hdc_b2) OVER (), 0)  total_comp_hdc_b2
 ,NVL(SUM(wmv.comp_total_hdc_b3) OVER (), 0)  total_comp_hdc_b3
 ,NVL(SUM(wmv.comp_total_hdc_na) OVER (), 0)  total_comp_hdc_na
 ,NVL(SUM(wmv.comp_total_hdc_end) OVER (), 0) total_comp_hdc
 ,NVL(wmv.direct_ind, 0)  direct_ind
 FROM
  ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || '  vby
,(' || l_wrkfc_fact_sql || ')  wmv
 WHERE wmv.vby_id ' || l_dynsql_rec.wrkfc_outer_join || ' = vby.id' || g_rtn ||
 l_dynsql_rec.viewby_condition ||
' ) qry
WHERE 1 = 1' || g_rtn ||
  l_dynsql_rec.display_row_condition ||
  l_security_clause || '
ORDER BY ' || l_dynsql_rec.order_by;

  x_custom_sql := l_SQLText;

END get_sql_bckt_perf;

/* Entry point for Headcount for Period of Work Band SQL */
PROCEDURE get_sql_bckt_low
      (p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql          OUT NOCOPY VARCHAR2,
       x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Return information */
  l_sqltext              VARCHAR2(32767);
  l_custom_rec           BIS_QUERY_ATTRIBUTES;

/* Dynamic SQL support */
  l_dynsql_rec     dynamic_sql_rec_type;
  l_security_clause      VARCHAR2(4000);
  l_direct_reports_string  VARCHAR2(100);

/* Parameter values */
  l_parameter_rec       hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab            hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic SQL Controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

/* Drill URLs for column drills on Headcount figure */
  l_drill_url2  VARCHAR2(1000) := '''''';
  l_drill_url3  VARCHAR2(1000) := '''''';
  l_drill_url4  VARCHAR2(1000) := '''''';
  l_drill_url5  VARCHAR2(1000) := '''''';
  l_drill_url6  VARCHAR2(1000) := '''''';

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec => l_parameter_rec,
         p_bind_tab => l_bind_tab);

  set_dynamic_sql(p_parameter_rec => l_parameter_rec,
                  p_bind_tab      => l_bind_tab,
                  p_bucket_dim    => 'HRI_LOW+HRI_LOW_BAND_X',
                  p_dynsql_rec    => l_dynsql_rec);

/* set the dynamic drill url AK region items */
  l_drill_url2 := l_dynsql_rec.drill_url2;
  l_drill_url3 := l_dynsql_rec.drill_url3;
  l_drill_url4 := l_dynsql_rec.drill_url4;
  l_drill_url5 := l_dynsql_rec.drill_url5;
  l_drill_url6 := l_dynsql_rec.drill_url6;

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.bucket_dim := 'HRI_LOW+HRI_LOW_BAND_X';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SUP_BCKT.GET_SQL_BCKT_LOW');

  l_sqltext :=
'SELECT  -- Headcount Ratio for LOW Band (Generic)
 qry.id               VIEWBYID
,qry.value            VIEWBY
,DECODE(qry.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB' || g_rtn ||
/* Band 1:  0 - 1 Years */
',qry.curr_hdc_b1     HRI_P_MEASURE1
,'''||l_drill_url2||'''   HRI_P_DRILL_URL2
,DECODE(qry.curr_hdc, 0, 0,
        (qry.curr_hdc_b1/qry.curr_hdc)*100)
                          HRI_P_MEASURE1_MP
,qry.comp_hdc_b1      HRI_P_MEASURE2
,DECODE(qry.comp_hdc_b1, 0, to_number(NULL),
        (qry.curr_hdc_b1 - qry.comp_hdc_b1) * 100
       / qry.comp_hdc_b1) HRI_P_MEASURE2_MP' || g_rtn ||
/* Band 2:  1 - 3 Years */
',qry.curr_hdc_b2     HRI_P_MEASURE3
,'''||l_drill_url3||'''   HRI_P_DRILL_URL3
,DECODE(qry.curr_hdc, 0, 0,
        (qry.curr_hdc_b2/qry.curr_hdc)*100)
                          HRI_P_MEASURE3_MP
,qry.comp_hdc_b2      HRI_P_MEASURE4
,DECODE(qry.comp_hdc_b2, 0, to_number(NULL),
        (qry.curr_hdc_b2 - qry.comp_hdc_b2) * 100
       / qry.comp_hdc_b2) HRI_P_MEASURE4_MP' || g_rtn ||
/* Band 3:  3 - 5 Years */
',qry.curr_hdc_b3     HRI_P_MEASURE5
,'''||l_drill_url4||'''   HRI_P_DRILL_URL4
,DECODE(qry.curr_hdc, 0, 0,
         (qry.curr_hdc_b3/qry.curr_hdc)*100)
                          HRI_P_MEASURE5_MP
,qry.comp_hdc_b3      HRI_P_MEASURE6
,DECODE(qry.comp_hdc_b3, 0, to_number(NULL),
        (qry.curr_hdc_b3 - qry.comp_hdc_b3) * 100
       / qry.comp_hdc_b3) HRI_P_MEASURE6_MP' || g_rtn ||
/* Band 4:  5 - 10 Years */
',qry.curr_hdc_b4        HRI_P_MEASURE7
,'''||l_drill_url5||'''   HRI_P_DRILL_URL5
,DECODE(qry.curr_hdc_b4, 0, 0,
        (qry.curr_hdc_b4/qry.curr_hdc)*100)
                          HRI_P_MEASURE7_MP
,qry.comp_hdc_b4         HRI_P_MEASURE8
,DECODE(qry.comp_hdc_b4, 0, to_number(NULL),
        (qry.curr_hdc_b4 - qry.comp_hdc_b4) * 100
       / qry.comp_hdc_b4)    HRI_P_MEASURE8_MP' || g_rtn ||
/* Band 5:  10 + Years */
',qry.curr_hdc_b5        HRI_P_MEASURE9
,'''||l_drill_url6||'''   HRI_P_DRILL_URL6
,DECODE(qry.curr_hdc_b5, 0, 0,
        (qry.curr_hdc_b5/qry.curr_hdc)*100)
                          HRI_P_MEASURE9_MP
,qry.comp_hdc_b5         HRI_P_MEASURE10
,DECODE(qry.comp_hdc_b5, 0, to_number(NULL),
        (qry.curr_hdc_b5 - qry.comp_hdc_b5) * 100
       / qry.comp_hdc_b5)    HRI_P_MEASURE10_MP' || g_rtn ||
/* Row totals - Across all performance bands */
',qry.curr_hdc        HRI_P_MEASURE11
,qry.comp_hdc         HRI_P_MEASURE12' || g_rtn ||
/* Order by */
',qry.order_by              HRI_P_ORDER_BY_1' || g_rtn ||
/* Grand Totals */
',DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b1/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL1
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b2/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL2
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b3/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL3
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b4/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL4
,DECODE(qry.total_curr_hdc, 0, 0,
        (qry.total_curr_hdc_b5/qry.total_curr_hdc) * 100)
                          HRI_P_GRAND_TOTAL5
,qry.total_comp_hdc_b1    HRI_P_GRAND_TOTAL6
,DECODE(qry.total_comp_hdc_b1, 0, 0,
        (qry.total_curr_hdc_b1 - qry.total_comp_hdc_b1) * 100/qry.total_comp_hdc_b1)
                          HRI_P_GRAND_TOTAL7
,qry.total_comp_hdc_b2    HRI_P_GRAND_TOTAL8
,DECODE(qry.total_comp_hdc_b2, 0, 0,
        (qry.total_curr_hdc_b2 - qry.total_comp_hdc_b2) * 100/qry.total_comp_hdc_b2)
                          HRI_P_GRAND_TOTAL9
,qry.total_comp_hdc_b3    HRI_P_GRAND_TOTAL10
,DECODE(qry.total_comp_hdc_b3, 0, 0,
        (qry.total_curr_hdc_b3 - qry.total_comp_hdc_b3) * 100/qry.total_comp_hdc_b3)
                          HRI_P_GRAND_TOTAL11
,qry.total_comp_hdc_b4    HRI_P_GRAND_TOTAL12
,DECODE(qry.total_comp_hdc_b4, 0, 0,
        (qry.total_curr_hdc_b4 - qry.total_comp_hdc_b4) * 100/qry.total_comp_hdc_b4)
                          HRI_P_GRAND_TOTAL13
,qry.total_comp_hdc_b5    HRI_P_GRAND_TOTAL14
,DECODE(qry.total_comp_hdc_b5, 0, 0,
        (qry.total_curr_hdc_b5 - qry.total_comp_hdc_b5) * 100/qry.total_comp_hdc_b5)
                          HRI_P_GRAND_TOTAL15
,qry.total_comp_hdc       HRI_P_GRAND_TOTAL16
,DECODE(qry.direct_ind,0,'''',''N'') HRI_P_SUPH_RO_CA' || g_rtn ||
/* Drill URLs */
', DECODE(qry.direct_ind,
 0, ''' || l_dynsql_rec.drill_mgr_sup || ''',
 ''' || l_dynsql_rec.drill_to_detail || ''')  HRI_P_DRILL_URL1
FROM
(SELECT
/* View by */
  vby.id
 ,DECODE(wmv.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         vby.value)  value
 ,to_char(NVL(wmv.direct_ind, 0)) || vby.order_by  order_by
 ,NVL(wmv.curr_hdc_b1, 0)  curr_hdc_b1
 ,NVL(wmv.curr_hdc_b2, 0)  curr_hdc_b2
 ,NVL(wmv.curr_hdc_b3, 0)  curr_hdc_b3
 ,NVL(wmv.curr_hdc_b4, 0)  curr_hdc_b4
 ,NVL(wmv.curr_hdc_b5, 0)  curr_hdc_b5
 ,NVL(wmv.curr_hdc_end, 0) curr_hdc
 ,NVL(wmv.comp_hdc_b1, 0)  comp_hdc_b1
 ,NVL(wmv.comp_hdc_b2, 0)  comp_hdc_b2
 ,NVL(wmv.comp_hdc_b3, 0)  comp_hdc_b3
 ,NVL(wmv.comp_hdc_b4, 0)  comp_hdc_b4
 ,NVL(wmv.comp_hdc_b5, 0)  comp_hdc_b5
 ,NVL(wmv.comp_hdc_end, 0) comp_hdc
 ,SUM(wmv.curr_hdc_b1) OVER ()  total_curr_hdc_b1
 ,SUM(wmv.curr_hdc_b2) OVER ()  total_curr_hdc_b2
 ,SUM(wmv.curr_hdc_b3) OVER ()  total_curr_hdc_b3
 ,SUM(wmv.curr_hdc_b4) OVER ()  total_curr_hdc_b4
 ,SUM(wmv.curr_hdc_b5) OVER ()  total_curr_hdc_b5
 ,SUM(wmv.curr_hdc_end) OVER () total_curr_hdc
 ,SUM(wmv.comp_total_hdc_b1) OVER ()  total_comp_hdc_b1
 ,SUM(wmv.comp_total_hdc_b2) OVER ()  total_comp_hdc_b2
 ,SUM(wmv.comp_total_hdc_b3) OVER ()  total_comp_hdc_b3
 ,SUM(wmv.comp_total_hdc_b4) OVER ()  total_comp_hdc_b4
 ,SUM(wmv.comp_total_hdc_b5) OVER ()  total_comp_hdc_b5
 ,SUM(wmv.comp_total_hdc_end) OVER () total_comp_hdc
 ,NVL(wmv.direct_ind, 0)  direct_ind
 FROM
  ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (l_parameter_rec.view_by).viewby_table || '  vby,
 (' || l_wrkfc_fact_sql || ')  wmv
 WHERE wmv.vby_id ' || l_dynsql_rec.wrkfc_outer_join || ' = vby.id' || g_rtn ||
  l_dynsql_rec.viewby_condition ||
' ) qry
WHERE 1 = 1' || g_rtn ||
  l_dynsql_rec.display_row_condition ||
  l_security_clause || '
ORDER BY ' || l_dynsql_rec.order_by;

  x_custom_sql := l_SQLText;

END get_sql_bckt_low;
--
-- ----------------------------------------------------------------------
-- Procedure to fetch the headcount by performance KPI
-- It fetched the values for the following KPIs
--  1. Headcount for High Band
--  2. Previous Headcount for High Band
--  3. Headcount for Mid Band
--  4. Previous Headcount for Mid Band
--  5. Headcount for Low Band
--  6. Previous Headcount for Low Band
--  7. Headcount for NA Band
--  8. Previous Headcount for NA Band
-- ----------------------------------------------------------------------
--
PROCEDURE get_wmv_perf_kpi
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
  l_wrkfc_params         hri_bpl_fact_sup_wrkfc_sql.WRKFC_FACT_PARAM_TYPE;
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
  --
  -- Set the parameters for getting the inner SQL
  --
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_comp  := 'Y';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.kpi_mode      := 'Y';
  l_wrkfc_params.bucket_dim    := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  --
  -- Get the inner SQL
  --
  l_inn_sql := HRI_OLTP_PMV_QUERY_WRKFC.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wrkfc_params     => l_wrkfc_params,
                  p_calling_module   => 'hri_oltp_pmv_wmv_sup_bckt.GET_WMV_PERF_KPI');
  --
  -- Form the SQL
  --
  x_custom_sql :=
'SELECT -- Headcount by Performance KPI
 qry.vby_id        VIEWBYID
,qry.vby_id        VIEWBY
,curr_hdc_b3       HRI_P_MEASURE1
,comp_hdc_b3       HRI_P_MEASURE2
,curr_hdc_b2       HRI_P_MEASURE4
,comp_hdc_b2       HRI_P_MEASURE5
,curr_hdc_b1       HRI_P_MEASURE7
,comp_hdc_b1       HRI_P_MEASURE8
,curr_hdc_na       HRI_P_MEASURE10
,comp_hdc_na       HRI_P_MEASURE11
,curr_hdc_b3       HRI_P_GRAND_TOTAL1
,comp_hdc_b3       HRI_P_GRAND_TOTAL2
,curr_hdc_b2       HRI_P_GRAND_TOTAL4
,comp_hdc_b2       HRI_P_GRAND_TOTAL5
,curr_hdc_b1       HRI_P_GRAND_TOTAL7
,comp_hdc_b1       HRI_P_GRAND_TOTAL8
,curr_hdc_na       HRI_P_GRAND_TOTAL10
,comp_hdc_na       HRI_P_GRAND_TOTAL11
FROM
('||l_inn_sql||') qry
WHERE 1=1
' || l_security_clause;
  --
END get_wmv_perf_kpi;


END hri_oltp_pmv_wmv_sup_bckt;

/
