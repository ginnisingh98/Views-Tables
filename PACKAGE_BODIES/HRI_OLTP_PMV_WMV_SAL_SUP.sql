--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SAL_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SAL_SUP" AS
/* $Header: hriopsbm.pkb 120.6 2005/11/16 03:12:02 cbridge noship $ */

g_rtn VARCHAR2(200) := '
';

PROCEDURE get_sql2(p_page_parameter_tbl  IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql          OUT NOCOPY VARCHAR2,
                   x_custom_output       OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext               VARCHAR2(32767);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec            BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Selective drill url feature */
  l_drill_url1            VARCHAR2(300);
  l_drill_url2            VARCHAR2(300);
  l_drill_url3            VARCHAR2(300);

/* Direct reports string */
  l_direct_reports_string VARCHAR2(240);

/* Dynamic SQL controls */
  l_wrkfc_fact_params    hri_bpl_fact_sup_wrkfc_sql.wrkfc_fact_param_type;
  l_wrkfc_fact_sql       VARCHAR2(10000);

BEGIN

/* Initialize out parameters */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Set direct reports string */
  l_direct_reports_string := hri_oltp_view_message.get_direct_reports_msg;

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* selective drill across urls */
  l_drill_url1 := 'pFunctionName=HRI_P_WRKFC_TRN_SUMMARY_PVT&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'pParamIds=Y';

  l_drill_url2 := 'pFunctionName=HRI_P_WMV_SAL_JFM_SUP&' ||
                 'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                 'VIEW_BY_NAME=VIEW_BY_ID&' ||
                 'pParamIds=Y';

  l_drill_url3 := 'pFunctionName=HRI_P_WMV_SAL_SUP_DTL&' ||
                  'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                  'VIEW_BY_NAME=VIEW_BY_ID&' ||
                  'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                  'pParamIds=Y';

/* substitute for VIEWBY in order by clause */
  l_parameter_rec.order_by := hri_oltp_pmv_util_pkg.set_default_order_by
                (p_order_by_clause => l_parameter_rec.order_by);

/* Get SQL for workforce fact */
  l_wrkfc_fact_params.bind_format := 'PMV';
  l_wrkfc_fact_params.include_comp := 'Y';
  l_wrkfc_fact_params.include_hdc := 'Y';
  l_wrkfc_fact_params.include_sal := 'Y';
  l_wrkfc_fact_sql := hri_bpl_fact_sup_wrkfc_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_wrkfc_params   => l_wrkfc_fact_params,
    p_calling_module => 'HRI_OLTP_PMV_WMV_SAL_SUP.GET_SQL2');

  l_sqltext :=
'SELECT  -- Headcount and Salary Portlet
 tab.mgr_id                         VIEWBYID
,DECODE(tab.direct_ind , 0, ''Y'', ''N'')  DRILLPIVOTVB
,tab.mgr_value                      VIEWBY
,tab.order_by                       HRI_P_ORDER_BY_1
,tab.mgr_value                      HRI_P_CHAR2_GA
,DECODE(tab.direct_ind,
          ''1'', ''' || l_drill_url3 || ''',
        ''' || l_drill_url1 || ''') HRI_P_DRILL_URL1
,tab.curr_hdc                       HRI_P_WMV_SUM_MV
,tab.curr_sal                       HRI_P_SAL_ANL_CUR_PARAM_SUM_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.comp_sal',
        p_current_col  => 'tab.curr_sal') || '
                                    HRI_P_MEASURE5
,tab.curr_avg_sal                   HRI_P_MEASURE1
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.comp_avg_sal',
        p_current_col  => 'tab.curr_avg_sal') || '
                                    HRI_P_MEASURE2
,tab.comp_avg_sal                   HRI_P_MEASURE3
,tab.comp_total_sal                 HRI_P_MEASURE4
,tab.curr_total_hdc                 HRI_P_GRAND_TOTAL1
,tab.curr_total_sal                 HRI_P_GRAND_TOTAL2
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.comp_total_sal',
        p_current_col  => 'tab.curr_total_sal') || '
                                    HRI_P_GRAND_TOTAL7
,tab.curr_total_avg_sal             HRI_P_GRAND_TOTAL3
,tab.comp_total_avg_sal             HRI_P_GRAND_TOTAL5
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.comp_total_avg_sal',
        p_current_col  => 'tab.curr_total_avg_sal') || '
                                    HRI_P_GRAND_TOTAL4
,tab.comp_total_sal                 HRI_P_GRAND_TOTAL6
,DECODE(tab.direct_ind,
          ''0'', '''|| l_drill_url2 ||''',
        '''')                       HRI_P_CHAR1_GA
,DECODE(tab.direct_ind,
          ''0'', '''',
        ''N'')                      HRI_P_SUPH_RO_CA
FROM
(SELECT
/* View by */
  hsal.vby_id            mgr_id
 ,DECODE(hsal.direct_ind,
           1, ''' || l_direct_reports_string || ''',
         per.value)      mgr_value
 ,to_char(hsal.direct_ind) || per.order_by  order_by
 ,hsal.direct_ind    direct_ind
 ,hsal.curr_hdc_end  curr_hdc
 ,hsal.comp_hdc_end  comp_hdc
 ,hsal.curr_sal_end  curr_sal
 ,hsal.comp_sal_end  comp_sal
 ,DECODE(hsal.curr_hdc_end,
           0, to_number(null),
         hsal.curr_sal_end / hsal.curr_hdc_end)  curr_avg_sal
 ,DECODE(hsal.comp_hdc_end,
           0, to_number(null),
         hsal.comp_sal_end / hsal.comp_hdc_end)  comp_avg_sal
 ,SUM(hsal.curr_hdc_end) OVER ()        curr_total_hdc
 ,SUM(hsal.comp_total_hdc_end) OVER ()  comp_total_hdc
 ,SUM(hsal.curr_sal_end) OVER ()        curr_total_sal
 ,SUM(hsal.comp_total_sal_end) OVER ()  comp_total_sal
 ,DECODE(SUM(hsal.curr_hdc_end) OVER (), 0, to_number(null),
         SUM(hsal.curr_sal_end) OVER () /
         SUM(hsal.curr_hdc_end) OVER ())        curr_total_avg_sal
 ,DECODE(SUM(hsal.comp_total_hdc_end) OVER (), 0, to_number(null),
         SUM(hsal.comp_total_sal_end) OVER () /
         SUM(hsal.comp_total_hdc_end) OVER ())  comp_total_avg_sal
 FROM
  hri_dbi_cl_per_n_v        per
 ,(' || l_wrkfc_fact_sql || ') hsal
 WHERE per.id = hsal.vby_id
 AND (hsal.curr_hdc_end > 0
   OR hsal.curr_sal_end > 0
   OR hsal.direct_ind = 1)
 AND &BIS_CURRENT_ASOF_DATE BETWEEN per.effective_start_date
                            AND per.effective_end_date
 )  tab
WHERE 1 = 1
' || l_security_clause || '
ORDER BY ' || l_parameter_rec.order_by;

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

END get_sql2;
--
-- ----------------------------------------------------------------------
-- Procedure to fetch the salary KPI
-- It fetched the values for the following KPIs
--  1. Total  Salary
--  2. Previous Total Salary
--  3. Average Salary
--  4. Previous Average Salary
-- ----------------------------------------------------------------------
--
PROCEDURE get_sal_kpi(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql         OUT NOCOPY VARCHAR2,
                      x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
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
  -- Set the parameters for getting the inner SQL
  --
  l_wrkfc_params.bind_format   := 'PMV';
  l_wrkfc_params.include_comp  := 'Y';
  l_wrkfc_params.include_hdc   := 'Y';
  l_wrkfc_params.include_sal   := 'Y';
  l_wrkfc_params.kpi_mode      := 'Y';
  l_wrkfc_params.bucket_dim    := '';
  --
  -- Get the inner SQL
  --
  l_inn_sql := HRI_OLTP_PMV_QUERY_WRKFC.get_sql
                 (p_parameter_rec    => l_parameter_rec,
                  p_bind_tab         => l_bind_tab,
                  p_wrkfc_params     => l_wrkfc_params,
                  p_calling_module   => 'HRI_OLTP_PMV_WMV_SAL_SUP.get_sal_kpi');
  --
  -- Form the SQL
  --
  x_custom_sql :=
'SELECT -- Salary KPIs
 qry.vby_id              VIEWBYID
,qry.vby_id              VIEWBY
,qry.curr_sal_end        HRI_P_MEASURE1
,qry.comp_sal_end        HRI_P_MEASURE2
,DECODE(qry.curr_hdc_end,0, to_number(null),qry.curr_sal_end/qry.curr_hdc_end)
                         HRI_P_MEASURE4
,DECODE(qry.comp_hdc_end,0, to_number(null),qry.comp_sal_end/qry.comp_hdc_end)
                         HRI_P_MEASURE5
,qry.curr_sal_end        HRI_P_GRAND_TOTAL1
,qry.comp_sal_end        HRI_P_GRAND_TOTAL2
,DECODE(qry.curr_hdc_end, 0, to_number(null),qry.curr_sal_end / qry.curr_hdc_end)
                         HRI_P_GRAND_TOTAL4
,DECODE(qry.comp_hdc_end,0, to_number(null),qry.comp_sal_end / qry.comp_hdc_end)
                         HRI_P_GRAND_TOTAL5
FROM
('||l_inn_sql||') qry
WHERE 1=1
' || l_security_clause;
 --
 -- Set value for global currency
 --
 l_custom_rec.attribute_name      := ':GLOBAL_CURRENCY';
 l_custom_rec.attribute_value     := l_parameter_rec.currency_code;
 l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
 l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
 x_custom_output.extend;
 x_custom_output(1)               := l_custom_rec;
 --
 -- Set the value for global rate
 --
 l_custom_rec.attribute_name      := ':GLOBAL_RATE';
 l_custom_rec.attribute_value     := l_parameter_rec.rate_type;
 l_custom_Rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
 l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
 x_custom_output.extend;
 x_custom_output(2)               := l_custom_rec;
 --
END get_sal_kpi;

END HRI_OLTP_PMV_WMV_SAL_SUP ;


/
