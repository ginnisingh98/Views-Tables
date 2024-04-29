--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_ABS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_ABS_PVT" AS
/* $Header: hriopabspvt.pkb 120.5 2005/11/17 07:20 jrstewar noship $ */
g_rtn                VARCHAR2(30) := '
';
--
--****************************************************************************
--* AK SQL For Absence Summary Status                                        *
--* AK Region : HRI_P_ABS_PVT                                                *
--****************************************************************************
--
PROCEDURE get_sql(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL
                 ,x_custom_sql  OUT NOCOPY VARCHAR2
                 ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
       IS

  l_SQLText               VARCHAR2(32000);
  l_security_clause       VARCHAR2(4000);
  l_custom_rec BIS_QUERY_ATTRIBUTES ;

/* Dynamic SQL Controls */
  l_abs_fact_params       hri_bpl_fact_abs_sql.abs_fact_param_type;
  l_abs_fact_sql          VARCHAR2(10000);
  l_parameter_name        VARCHAR2(100);
  l_dynmc_drtn_curr       VARCHAR2(100) DEFAULT 'curr_abs_drtn_days';
  l_dynmc_drtn_comp       VARCHAR2(100) DEFAULT 'comp_abs_drtn_days';
  l_drill_abs_detail      VARCHAR2(1000);
  l_dynsql_order_by       VARCHAR2(100);

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

/* Drill URL's for Manager and Direct Reports */
  l_drill_abs_detail :='pFunctionName=HRI_P_ABS_SUP_DTL&' ||
                     'VIEW_BY=HRI_PERSON+HRI_PER_USRDR_H&' ||
                     'VIEW_BY_NAME=VIEW_BY_ID&' ||
                     'HRI_P_SUPH_RO_CA=HRI_P_SUPH_RO_CA&' ||
                     'pParamIds=Y';

/* Set order by */
   l_dynsql_order_by :=  hri_oltp_pmv_util_pkg.set_default_order_by
                                (p_order_by_clause => l_parameter_rec.order_by);


  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure paramter selection  Default Days                */

      IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days     := 'Y';
      ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
        l_dynmc_drtn_curr := 'curr_abs_drtn_hrs';
        l_dynmc_drtn_comp := 'comp_abs_drtn_hrs';
        l_abs_fact_params.include_abs_drtn_hrs      := 'Y';
      ELSE -- functional decision (JC) default to days
        l_dynmc_drtn_curr := 'curr_abs_drtn_days';
        l_dynmc_drtn_comp := 'comp_abs_drtn_days';
        l_abs_fact_params.include_abs_drtn_days     := 'Y';
      END IF;


/* Get SQL for workforce fact */
  l_abs_fact_params.bind_format := 'PMV';
  l_abs_fact_params.include_abs_in_period     := 'Y';
  l_abs_fact_params.include_abs_ntfctn_period := 'Y';
  l_abs_fact_params.include_comp              := 'Y';
  l_abs_fact_params.kpi_mode                  := 'N';
  l_abs_fact_sql := hri_bpl_fact_abs_sql.get_sql
   (p_parameter_rec  => l_parameter_rec,
    p_bind_tab       => l_bind_tab,
    p_abs_params     => l_abs_fact_params,
    p_calling_module => 'HRI_P_ABS_PVT');

l_SQLText :=
    ' -- Absence Summary Status  by Category only 70C
SELECT
 babs.vby_id						VIEWBYID
,babs.value			         		VIEWBY '|| g_rtn
/* Absence  */ || g_rtn ||'
,NVL(babs.curr_abs_in_period,to_number(NULL))    	HRI_P_MEASURE1
,NVL(babs.comp_abs_in_period,to_number(NULL))           HRI_P_MEASURE2'|| g_rtn
/* Total Notification  */ || g_rtn ||'
,NVL(babs.curr_abs_ntfctn_period,to_number(NULL))       HRI_P_MEASURE3
,NVL(babs.comp_abs_ntfctn_period,to_number(NULL))       HRI_P_MEASURE4'|| g_rtn
/* Average Notification  */ || g_rtn ||'
,NVL(curr_abs_avg_ntfctn_period,to_number(NULL))        HRI_P_MEASURE5
,NVL(comp_abs_avg_ntfctn_period,to_number(NULL))        HRI_P_MEASURE6'|| g_rtn
/* Change - Average Notification  */ || g_rtn ||'
,'|| hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'comp_abs_avg_ntfctn_period',
          p_current_col  => 'curr_abs_avg_ntfctn_period') || '
                                                        HRI_P_MEASURE5_MP'|| g_rtn
/* Total Absence Duration */ || g_rtn ||'
,NVL(babs.curr_abs_drtn,to_number(NULL))    	        HRI_P_MEASURE7
,NVL(babs.comp_abs_drtn,to_number(NULL)) 	    	HRI_P_MEASURE8'|| g_rtn
/* Change - Total Absence Duration  */ || g_rtn ||'
,'|| hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_abs_drtn',
          p_current_col  => 'babs.curr_abs_drtn') || '  HRI_P_MEASURE7_MP'|| g_rtn
/* Average Absence Duration  */ || g_rtn ||'
,DECODE(babs.curr_abs_in_period,0,to_number(NULL)
       ,(babs.curr_abs_drtn / babs.curr_abs_in_period)
	   )                                            HRI_P_MEASURE9
,DECODE(babs.comp_abs_in_period,0,to_number(NULL)
       ,(babs.curr_abs_drtn / babs.comp_abs_in_period)
	   )                                            HRI_P_MEASURE10'|| g_rtn
/* Total Absence  */ || g_rtn ||'
,NVL(babs.curr_tot_abs_in_period,to_number(NULL))       HRI_P_GRAND_TOTAL1
,NVL(babs.comp_tot_abs_in_period,to_number(NULL))       HRI_P_GRAND_TOTAL2'|| g_rtn
/* Total Notification  */ || g_rtn ||'
,NVL(babs.curr_tot_abs_ntfctn_period,to_number(NULL))   HRI_P_GRAND_TOTAL3
,NVL(babs.comp_tot_abs_ntfctn_period,to_number(NULL))   HRI_P_GRAND_TOTAL4'|| g_rtn
/* Total Average Notification */ || g_rtn ||'
,NVL(babs.curr_tot_avg_abs_ntfctn_period,to_number(NULL))
                                                        HRI_P_GRAND_TOTAL5
,NVL(babs.comp_tot_avg_abs_ntfctn_period,to_number(NULL))
                                                        HRI_P_GRAND_TOTAL6'|| g_rtn
/* Change Total - Total  Average Notification  */ || g_rtn ||'
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_tot_avg_abs_ntfctn_period',
          p_current_col  => 'babs.curr_tot_avg_abs_ntfctn_period') || '
                                                        HRI_P_GRAND_TOTAL5_MP'|| g_rtn
/* Total Absence Duration */ || g_rtn ||'
,NVL(babs.curr_tot_abs_drtn,to_number(NULL))		HRI_P_GRAND_TOTAL7
,NVL(babs.comp_tot_abs_drtn,to_number(NULL))		HRI_P_GRAND_TOTAL8'|| g_rtn
/* Change Total - Total Absence Duration  */ || g_rtn ||'
,' || hri_oltp_pmv_util_pkg.get_change_percent_sql
         (p_previous_col => 'babs.comp_tot_abs_drtn',
          p_current_col  => 'babs.curr_tot_abs_drtn') || '
                                                        HRI_P_GRAND_TOTAL7_MP'|| g_rtn
/* Total Average Absence Duration  */  || g_rtn ||'
,DECODE(babs.curr_tot_abs_in_period,0,to_number(NULL)
       ,(babs.curr_tot_abs_drtn  / babs.curr_tot_abs_in_period)
	   )                                            HRI_P_GRAND_TOTAL9
,DECODE(babs.comp_tot_abs_in_period,0,to_number(NULL)
       ,(babs.comp_tot_abs_drtn  / babs.comp_tot_abs_in_period)
	   )                                            HRI_P_GRAND_TOTAL10' || g_rtn ||
/* Order by person name default sort order */
',babs.order_by                                         HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Whether the row is a supervisor rollup row */
',''''                                                  HRI_P_SUPH_RO_CA '|| g_rtn
/* Drill URLs */ || g_rtn ||'
,'''|| l_drill_abs_detail ||'''	                        HRI_P_DRILL_URL1
FROM
(
SELECT
/* Base Measures */
 vby.id                   		   vby_id
,vby.value                                 value
,vby.order_by                              order_by
,NVL(fact.'||l_dynmc_drtn_curr ||',0)      curr_abs_drtn
,NVL(fact.curr_abs_in_period,0)            curr_abs_in_period
,NVL(fact.'||l_dynmc_drtn_comp ||',0)      comp_abs_drtn
,NVL(fact.comp_abs_in_period,0)            comp_abs_in_period
,NVL(fact.curr_abs_ntfctn_period,0) 	   curr_abs_ntfctn_period
,NVL(fact.comp_abs_ntfctn_period,0) 	   comp_abs_ntfctn_period
,DECODE(fact.curr_abs_ntfctn_period,0,to_number(NULL)
       ,DECODE(fact.curr_abs_in_period,0,to_number(NULL)
	          ,(fact.curr_abs_ntfctn_period / fact.curr_abs_in_period)
	          )
       )                                   curr_abs_avg_ntfctn_period
,DECODE(fact.comp_abs_ntfctn_period,0,to_number(NULL)
       ,DECODE(fact.curr_abs_in_period,0,to_number(NULL)
	          ,(fact.comp_abs_ntfctn_period / fact.comp_abs_in_period)
	          )
      )                                    comp_abs_avg_ntfctn_period
,SUM(fact.'||l_dynmc_drtn_curr||') OVER()
                                           curr_tot_abs_drtn
,SUM(fact.curr_abs_in_period) OVER()       curr_tot_abs_in_period
,SUM(fact.'||l_dynmc_drtn_comp||') OVER()  comp_tot_abs_drtn
,SUM(fact.comp_abs_in_period) OVER()       comp_tot_abs_in_period
,SUM(fact.curr_abs_ntfctn_period) OVER()   curr_tot_abs_ntfctn_period
,SUM(fact.comp_abs_ntfctn_period) OVER()   comp_tot_abs_ntfctn_period
,DECODE(SUM(fact.curr_abs_ntfctn_period) OVER(),0,to_number(NULL)
       ,DECODE(SUM(fact.curr_abs_in_period) OVER(),0,to_number(NULL)
              ,(SUM(fact.curr_abs_ntfctn_period) OVER() / SUM(fact.curr_abs_in_period) OVER())
	          )
       )                                   curr_tot_avg_abs_ntfctn_period
,DECODE(SUM(fact.comp_abs_ntfctn_period) OVER(),0,to_number(NULL)
       ,DECODE(SUM(fact.comp_abs_in_period) OVER(),0,to_number(NULL)
              ,(SUM(fact.comp_abs_ntfctn_period) OVER() / SUM(fact.comp_abs_in_period) OVER())
	          )
       )                                   comp_tot_avg_abs_ntfctn_period
FROM
 hri_cl_absnc_cat_v  vby
,('|| l_abs_fact_sql ||') fact
WHERE
   vby.id = fact.vby_id
 ' || l_security_clause || ') babs
 ORDER BY '|| l_dynsql_order_by;

  x_custom_sql := l_SQLText ;

END get_sql;

--
--****************************************************************************
--* AK SQL For
--* AK Region :
--****************************************************************************
--
END HRI_OLTP_PMV_ABS_PVT;

/
