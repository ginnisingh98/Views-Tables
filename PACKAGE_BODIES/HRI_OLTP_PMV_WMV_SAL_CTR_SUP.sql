--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_WMV_SAL_CTR_SUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_WMV_SAL_CTR_SUP" AS
/* $Header: hriopwsc.pkb 120.3 2006/01/10 07:22:43 cbridge noship $ */

  g_rtn   VARCHAR2(30) := '
';

--* AK SQL For Headcount and Salary by Country                               *
--* AK Region : HRI_P_WMV_SAL_CTR_SUP                                        *
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

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* translate 'others' string */
   l_others_string := hri_oltp_view_message.get_others_msg;

/* Set l_drill_url to null to turn off drill to regions report */
  l_drill_url := '' ; -- bug 3696662, turned off drill url for Oracle GSI.

  -- 'pFunctionName=HRI_P_WMV_SAL_RGN_SUP&' ||
  --               'HRI_P_GEO_CTY_CN=HRI_P_GEO_CTY_CN&' ||
  --               'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
  --               'pParamIds=Y';

/* Force view by country */
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
    p_calling_module => 'HRI_OLTP_PMV_WMV_SAL_CTR_SUP.GET_SQL2');

l_SQLText :=
'SELECT -- Headcount and Salary by Country
 tab.order_by                   HRI_P_ORDER_BY_1
,DECODE(tab.vby_id,''NA_OTHERS'',''' || l_others_string || ''', ctr.value)
                                HRI_P_MEASURE1
,NVL(tab.wmv_curr,0)            HRI_P_WMV_SUM_MV
,NVL(tab.wmv_prev,0)            HRI_P_WMV_SUM_PREV_MV
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.wmv_prev',
        p_current_col  => 'tab.wmv_curr') || '
                                HRI_P_WMV_CHNG_PCT_SUM_MV
,NVL(tab.sal_curr,0)            HRI_P_MEASURE2
,NVL(tab.sal_prev,0)            HRI_P_MEASURE3
,tab.avg_sal                    HRI_P_MEASURE4
,tab.avg_sal_prev               HRI_P_MEASURE5
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.avg_sal_prev',
        p_current_col  => 'tab.avg_sal') || '
                                HRI_P_MEASURE6
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
    (p_previous_col => 'DECODE(tab.tot_wmv_prev, 0, NULL,
 tab.tot_sal_prev/tab.tot_wmv_prev)',
     p_current_col  => 'DECODE(SUM(tab.wmv_curr) over(), 0, NULL,
 (SUM(tab.sal_curr) over() / SUM(tab.wmv_curr) over()))') || '
                                HRI_P_GRAND_TOTAL1
,DECODE(sum(tab.wmv_curr) over(),
          0, sum(tab.avg_sal) over (),
        sum(tab.sal_curr) over ()/sum(tab.wmv_curr) over ())
                                HRI_P_GRAND_TOTAL2
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
       (p_previous_col => 'tab.tot_wmv_prev',
        p_current_col  => '(sum(tab.wmv_curr) over ())') || '
                                HRI_P_GRAND_TOTAL3
,DECODE(tab.vby_id,''NA_OTHERS'',''' || l_others_string || ''', tab.country_code)   HRI_P_GEO_CTY_CN
,DECODE(tab.vby_id,''NA_OTHERS'',''''
       , ''' || l_drill_url || ''')
                                HRI_P_CHAR1_GA
FROM
 hri_dbi_cl_geo_country_v   ctr
,(SELECT' || g_rtn ||
/* Bug 4068969 - Order by rank putting OTHERS group last */
'   DECODE(SUM(wmv_curr),
            NULL, to_number(NULL),
          DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
                   -1, :HRI_NO_COUNTRIES_TO_SHOW + 1,
                 rnk))    order_by' || g_rtn ||
/* Use country name for all except OTHERS group */
'  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_OTHERS'',
          country)        vby_id' || g_rtn ||
/* Use unassigned country to join to the country view */
'  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_EDW'',
          country)        country_code
  ,SUM(wmv_curr)          wmv_curr
  ,SUM(wmv_prev)          wmv_prev
  ,SUM(sal_curr)          sal_curr
  ,SUM(avg_sal)           avg_sal
  ,SUM(sal_prev)          sal_prev
  ,tot_wmv_prev           tot_wmv_prev
  ,MAX(tot_sal_prev)      tot_sal_prev
  ,DECODE(SUM(wmv_prev),
            0, NULL,
          SUM(sal_prev) / SUM(wmv_prev))
                          avg_sal_prev
  FROM
   (SELECT' || g_rtn ||
/* Bug 4068969 - Rank by descending headcount, descending average salary, */
/* then ascending country name */
'     (RANK() OVER (ORDER BY curr_hdc_end DESC NULLS LAST
                           , bc.vby_id))
                             rnk
     ,bc.vby_id              country
     ,bc.curr_hdc_end        wmv_curr
     ,bc.comp_hdc_end        wmv_prev
     ,bc.curr_sal_end        sal_curr
     ,DECODE(bc.curr_hdc_end,
               0, NULL,
             bc.curr_sal_end / bc.curr_hdc_end)
                             avg_sal
     ,bc.comp_sal_end        sal_prev
     ,SUM(bc.comp_total_hdc_end) OVER ()  tot_wmv_prev
     ,SUM(bc.comp_total_sal_end) OVER ()  tot_sal_prev
    FROM
     (' || l_wrkfc_fact_sql || ')   bc
    WHERE (bc.curr_hdc_end > 0
        OR bc.comp_hdc_end > 0
        OR bc.curr_sal_end > 0
        OR bc.comp_sal_end > 0)
   ) qry
  GROUP BY
   DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, :HRI_NO_COUNTRIES_TO_SHOW + 1,
          rnk)
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_OTHERS'',
          country)
  ,DECODE(SIGN(:HRI_NO_COUNTRIES_TO_SHOW - rnk),
            -1, ''NA_EDW'',
          country)
  ,tot_wmv_prev
 ) tab
WHERE tab.country_code = ctr.id
' || l_security_clause || '
ORDER BY
 HRI_P_ORDER_BY_1
,HRI_P_MEASURE4
,HRI_P_MEASURE1';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := ':HRI_NO_COUNTRIES_TO_SHOW';
  l_custom_rec.attribute_value := g_no_countries_to_show;
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

END get_sql2;

END HRI_OLTP_PMV_WMV_SAL_CTR_SUP;

/
