--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_DTL_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_DTL_SALARY" AS
/* $Header: hriopsdt.pkb 120.15 2006/01/20 06:29:50 jrstewar noship $ */

g_rtn                VARCHAR2(30) := '
';

g_unassigned         VARCHAR2(50) := HRI_OLTP_VIEW_MESSAGE.get_unassigned_msg;


/******************************************************************************/
/* Salary detail for Staff = Directs                                          */
/******************************************************************************/
PROCEDURE get_salary_detail_directs
  (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_lnk_emp_name   IN VARCHAR2,
   p_lnk_mgr_name   IN VARCHAR2,
   x_custom_sql     OUT NOCOPY VARCHAR2,
   x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Variable to return SQL query for report */
  l_sqltext             VARCHAR2(32000);
  l_params_header       VARCHAR2(10000);
  l_lnk_profile_chk     VARCHAR2(4000);

/* Table of custom parameters */
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

/* Security clause */
  l_security_clause     VARCHAR2(1000);

/* Variables for dynamic part of SQL query */
  l_parameter_name      VARCHAR2(100);
  l_column              VARCHAR2(100);
  l_where_clause        VARCHAR2(1000);
  l_lnk_emp_name        VARCHAR2(4000);
  l_lnk_mgr_name        VARCHAR2(4000);
  l_pow_factor          NUMBER;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Set drill URLS */
  l_lnk_emp_name := p_lnk_emp_name;
  l_lnk_mgr_name := p_lnk_mgr_name;

/* Set security clause */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

  /* Initialize column to null */
    l_column := NULL;

  /* Check parameters */
    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA') THEN

    /* Form parameter condition */
      l_column := 'geog.' || REPLACE(hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                                      (l_parameter_name).fact_viewby_col, 'geo_');

    ELSIF (l_parameter_name = 'JOB+JOB_FAMILY' OR
           l_parameter_name = 'JOB+JOB_FUNCTION') THEN

    /* Form parameter condition */
      l_column := 'jobh.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                              (l_parameter_name).fact_viewby_col;

    ELSIF (l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
           l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

    /* Form parameter condition */
      l_column := 'asgn.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                              (l_parameter_name).fact_viewby_col;

    END IF;

    IF (l_column IS NOT NULL) THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause || 'AND ' || l_column || ' IN (' ||
             p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Check for worker type parameter */
    IF (l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN

    /* Staff = Direct Reports - add join and condition on dimension table */
      l_where_clause := l_where_clause ||
'AND ptyp.wkth_wktyp_code IN (' ||
  p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (p_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
     l_pow_factor := 1;
  ELSE
     l_pow_factor := 12;
  END IF;

/* Formulate query */
  l_sqltext :=
'SELECT -- Employee / Contingent Directs Detail' || g_rtn ||
/* View by name of person */
' peo.value                VIEWBY ' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by             HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Name of person */
',peo.value                HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                   HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                           HRI_P_DRILL_URL1' || g_rtn ||
/* Manager of person as of effective date */
',sup.value                HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                   HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                           HRI_P_DRILL_URL2' || g_rtn ||
/* assignment organization */
',org.value                HRI_P_ORG_CN ' || g_rtn ||
/* assignment country */
',ctr.value                HRI_P_GEO_CTY_CN ' || g_rtn ||
/* assignment job name (using default display configuration) */
',hri_oltp_view_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)        HRI_P_JOB_CN ' || g_rtn ||
',asgn.anl_slry            HRI_P_SAL_ANL_CUR_PARAM_SUM_MV ' || g_rtn ||
',DECODE(asgn.anl_slry_currency,
           ''NA_EDW'','''',
           NULL, '''',
         asgn.anl_slry_currency)
                           HRI_P_CHAR1_GA ' || g_rtn ||
',hri_oltp_view_currency.convert_currency_amount
      (asgn.anl_slry_currency
      ,:GLOBAL_CURRENCY
      ,&BIS_CURRENT_ASOF_DATE
      ,asgn.anl_slry
      ,:GLOBAL_RATE)       HRI_P_MEASURE2 ' || g_rtn ||
',:GLOBAL_CURRENCY         HRI_P_CHAR2_GA ' || g_rtn ||
/* Total period of work in years (current period) */
',ROUND(months_between(&BIS_CURRENT_ASOF_DATE, asgn.pow_start_date_adj) / :POW_FACTOR
       ,2)                 HRI_P_MEASURE1' || g_rtn ||
/* Performance Rating - for future use */
',to_number(null)          HRI_P_CHAR3_GA
,pow.value                 HRI_P_CHAR5_GA
,prf.value                 HRI_P_CHAR6_GA
,asgn.pow_start_date_adj   HRI_P_DATE1_GA
,hri_bpl_dbi_calc_period.get_term_date
    (asgn.assignment_id
    ,peo.id)
                           HRI_P_DATE2_GA
FROM
 hri_mb_asgn_events_ct      asgn
,hri_cs_geo_lochr_ct        geog
,hri_cs_jobh_ct             jobh
,hri_cs_prsntyp_ct          ptyp
,hri_dbi_cl_per_n_v         peo
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_job_v           job
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_pow_all_band_v  pow
,hri_cl_prfmnc_rtng_x_v     prf
WHERE asgn.supervisor_id = &HRI_PERSON+HRI_PER_USRDR_H
AND &BIS_CURRENT_ASOF_DATE BETWEEN asgn.effective_change_date
                           AND asgn.effective_change_end_date
AND asgn.SUMMARIZATION_RQD_IND = 1
AND asgn.worker_term_ind = 0
AND asgn.pre_sprtn_asgn_end_ind = 0
AND asgn.headcount > 0
AND asgn.person_id = peo.id
AND asgn.supervisor_id = sup.id
AND asgn.organization_id = org.id
AND geog.country_code = ctr.id
AND asgn.location_id = geog.location_id
AND asgn.job_id = job.id
AND asgn.job_id = jobh.job_id
AND asgn.prsntyp_sk_fk = ptyp.prsntyp_sk_pk
AND asgn.pow_band_sk_fk = pow.id
AND asgn.perf_band = prf.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date
                           AND sup.effective_end_date
AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.effective_start_date
                           AND peo.effective_end_date ' || g_rtn ||
  l_where_clause ||
  l_security_clause || g_rtn ||
'&ORDER_BY_CLAUSE ';

  x_custom_sql := l_sqltext;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := p_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := p_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':POW_FACTOR';
  l_custom_rec.attribute_value := l_pow_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END get_salary_detail_directs;

/******************************************************************************/
/* Salary detail for Staff = All                                              */
/******************************************************************************/
PROCEDURE get_salary_detail_all
  (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_lnk_emp_name   IN VARCHAR2,
   p_lnk_mgr_name   IN VARCHAR2,
   x_custom_sql     OUT NOCOPY VARCHAR2,
   x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Variable to return SQL query for report */
  l_sqltext             VARCHAR2(32000);
  l_params_header       VARCHAR2(10000);
  l_lnk_profile_chk     VARCHAR2(4000);

/* Table of custom parameters */
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

/* Security clause */
  l_security_clause     VARCHAR2(1000);

/* Variables for dynamic part of SQL query */
  l_parameter_name      VARCHAR2(100);
  l_where_clause        VARCHAR2(1000);
  l_lnk_emp_name        VARCHAR2(4000);
  l_lnk_mgr_name        VARCHAR2(4000);
  l_pow_factor          NUMBER;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Set drill URLS */
  l_lnk_emp_name := p_lnk_emp_name;
  l_lnk_mgr_name := p_lnk_mgr_name;

/* Set security clause */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause ||
'AND sup_asg.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                    (l_parameter_name).fact_viewby_col  ||
' IN (' || p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);
  END LOOP;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (p_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause ||
          'AND sup_asg.wkth_wktyp_code = ''EMP'' ' || g_rtn;
     l_pow_factor := 12;
  ELSIF (p_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause ||
          'AND sup_asg.wkth_wktyp_code = ''CWK'' ' || g_rtn;
     l_pow_factor := 1;
  ELSE
     l_pow_factor := 12;
  END IF;

/* Formulate query */
  l_sqltext :=
'SELECT -- Employee / Contingent Detail' || g_rtn ||
/* View by name of person */
' peo.value                VIEWBY ' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by             HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Name of person */
',peo.value                HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                   HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                           HRI_P_DRILL_URL1' || g_rtn ||
/* Manager of person as of effective date */
',sup.value                HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                   HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                           HRI_P_DRILL_URL2' || g_rtn ||
/* assignment organization */
',org.value                HRI_P_ORG_CN ' || g_rtn ||
/* assignment country */
',ctr.value                HRI_P_GEO_CTY_CN ' || g_rtn ||
/* assignment job name (using default display configuration) */
',hri_oltp_view_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)        HRI_P_JOB_CN ' || g_rtn ||
',sup_asg.anl_slry_value   HRI_P_SAL_ANL_CUR_PARAM_SUM_MV ' || g_rtn ||
',DECODE(sup_asg.anl_slry_currency,
           ''NA_EDW'','''',
           NULL, '''',
         sup_asg.anl_slry_currency)
                           HRI_P_CHAR1_GA ' || g_rtn ||
',hri_oltp_view_currency.convert_currency_amount
      (sup_asg.anl_slry_currency
      ,:GLOBAL_CURRENCY
      ,&BIS_CURRENT_ASOF_DATE
      ,sup_asg.anl_slry_value
      ,:GLOBAL_RATE)       HRI_P_MEASURE2 ' || g_rtn ||
',:GLOBAL_CURRENCY         HRI_P_CHAR2_GA ' || g_rtn ||
/* Total period of work in years (current period) */
',ROUND(months_between(&BIS_CURRENT_ASOF_DATE, sup_asg.pow_start_date) / :POW_FACTOR
       ,2)                 HRI_P_MEASURE1' || g_rtn ||
/* Performance Rating - for future use */
',to_number(null)          HRI_P_CHAR3_GA
,pow.value                 HRI_P_CHAR5_GA
,prf.value                 HRI_P_CHAR6_GA
,sup_asg.pow_start_date    HRI_P_DATE1_GA
,hri_bpl_dbi_calc_period.get_term_date
    (sup_asg.assignment_id
    ,peo.id)
                           HRI_P_DATE2_GA
FROM
 hri_map_sup_wrkfc_asg  sup_asg
,hri_dbi_cl_per_n_v         peo
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_job_v           job
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_pow_all_band_v  pow
,hri_cl_prfmnc_rtng_x_v     prf
WHERE sup_asg.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup_asg.effective_date
                           AND sup_asg.effective_end_date
AND sup_asg.SUMMARIZATION_RQD_IND = 1
AND sup_asg.headcount_value > 0
AND sup_asg.metric_adjust_multiplier = 1
AND sup_asg.person_id = peo.id
AND sup_asg.direct_supervisor_person_id = sup.id
AND sup_asg.organization_id = org.id
AND sup_asg.geo_country_code = ctr.id
AND sup_asg.job_id = job.id
AND sup_asg.pow_band_sk_fk = pow.id
AND sup_asg.perf_band = prf.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date
                           AND sup.effective_end_date
AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.effective_start_date
                           AND peo.effective_end_date ' || g_rtn ||
  l_where_clause ||
  l_security_clause || g_rtn ||
'&ORDER_BY_CLAUSE ';

  x_custom_sql := l_sqltext;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := p_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := p_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':POW_FACTOR';
  l_custom_rec.attribute_value := l_pow_factor;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.numeric_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END get_salary_detail_all;

/******************************************************************************/
/* Worker Detail report                                                       */
/******************************************************************************/
PROCEDURE GET_SALARY_DETAIL2(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                             x_custom_sql         OUT NOCOPY VARCHAR2,
                             x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Variables for dynamic part of SQL query */
  l_lnk_profile_chk     VARCHAR2(4000);
  l_lnk_emp_name        VARCHAR2(4000);
  l_lnk_mgr_name        VARCHAR2(4000);

BEGIN

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Activite Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk
                        (p_parameter_rec  => l_parameter_rec
                        ,p_bind_tab       => l_bind_tab);

  IF (l_lnk_profile_chk = 1 AND
      l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
    l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_PER_ID&OAPB=FII_HR_BRAND_TEXT';
    l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
  END IF ;

/* Check supervisor hierarchy rollup */
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N') THEN

  /* Call directs only function to get the SQL */
    get_salary_detail_directs
     (p_parameter_rec => l_parameter_rec,
      p_bind_tab      => l_bind_tab,
      p_lnk_emp_name  => l_lnk_emp_name,
      p_lnk_mgr_name  => l_lnk_mgr_name,
      x_custom_sql    => x_custom_sql,
      x_custom_output => x_custom_output);

  ELSE

  /* Call all staff function to get the SQL */
    get_salary_detail_all
     (p_parameter_rec => l_parameter_rec,
      p_bind_tab      => l_bind_tab,
      p_lnk_emp_name  => l_lnk_emp_name,
      p_lnk_mgr_name  => l_lnk_mgr_name,
      x_custom_sql    => x_custom_sql,
      x_custom_output => x_custom_output);

  END IF;

END get_salary_detail2;

/******************************************************************************/
/* HR Detail                                                                  */
/******************************************************************************/
PROCEDURE get_hr_detail
  (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
   x_custom_sql         OUT NOCOPY VARCHAR2,
   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

/* Variable to return SQL query for report */
  l_sqltext             VARCHAR2(32000);
  l_params_header       VARCHAR2(10000);
  l_lnk_profile_chk     VARCHAR2(4000);

/* Table of custom parameters */
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Security clause */
  l_security_clause     VARCHAR2(1000);

/* Variables for dynamic part of SQL query */
  l_parameter_name      VARCHAR2(100);
  l_where_clause        VARCHAR2(1000);
  l_lnk_emp_name        VARCHAR2(4000);
  l_lnk_mgr_name        VARCHAR2(4000);
  l_pow_factor          NUMBER;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Activite Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk(p_parameter_rec  => l_parameter_rec
                                                            ,p_bind_tab       => l_bind_tab);

  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
	l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_PER_ID&OAPB=FII_HR_BRAND_TEXT';
	l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
  ELSE
    l_lnk_emp_name := '';
	l_lnk_mgr_name := '';
  END IF ;

/* Set security clause */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Loop through parameters that have been set */
  l_parameter_name := l_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause ||
'AND sup_asg.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                    (l_parameter_name).fact_viewby_col  ||
' IN (' || l_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := l_bind_tab.NEXT(l_parameter_name);
  END LOOP;

  /* Check supervisor hierarchy rollup */
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N') THEN
    l_where_clause := l_where_clause ||
'AND sup_asg.direct_ind = 1' || g_rtn;
  END IF;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          ||'AND sup_asg.wkth_wktyp_code = ''EMP'' ';
     l_pow_factor := 12;
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause || g_rtn
          || 'AND sup_asg.wkth_wktyp_code = ''CWK'' ';
     l_pow_factor := 1;
  ELSE
      l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1 ';
     l_pow_factor := 12;
  END IF;

/* Formulate query */
  l_sqltext :=
'SELECT -- HR Employee Detail' || g_rtn ||
/* View by name of person */
' peo.value                VIEWBY ' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by             HRI_P_ORDER_BY_1 ' || g_rtn ||
/* Name of person */
',peo.value                HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                   HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                           HRI_P_DRILL_URL1' || g_rtn ||
/* Manager of person as of effective date */
',sup.value                HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                   HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                           HRI_P_DRILL_URL2' || g_rtn ||
/* assignment organization */
',org.value                HRI_P_ORG_CN ' || g_rtn ||
/* assignment country */
',ctr.value                HRI_P_GEO_CTY_CN ' || g_rtn ||
/* assignment job name (using default display configuration) */
',hri_oltp_view_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)        HRI_P_JOB_CN ' || g_rtn ||
/* Total period of work in years (current period) */
',to_number(null)          HRI_P_MEASURE1' || g_rtn ||
/* Performance Rating - for future use */
',to_number(null)          HRI_P_CHAR3_GA
,to_char(null)             HRI_P_CHAR5_GA
,to_char(null)             HRI_P_CHAR6_GA
,sup_asg.pow_start_date    HRI_P_DATE1_GA
,sysdate                   HRI_P_DATE2_GA
FROM
 hri_map_sup_wrkfc_asg  sup_asg
,hri_dbi_cl_per_n_v         peo
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_job_v           job
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_geo_country_v   ctr
WHERE sup_asg.supervisor_person_id = NVL(hri_bpl_security.get_apps_signin_person_id, -1)
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup_asg.effective_date
                           AND sup_asg.effective_end_date
AND sup_asg.SUMMARIZATION_RQD_IND = 1
AND sup_asg.headcount_value > 0
AND sup_asg.metric_adjust_multiplier = 1
AND sup_asg.person_id = peo.id
AND sup_asg.direct_supervisor_person_id = sup.id
AND sup_asg.organization_id = org.id
AND sup_asg.geo_country_code = ctr.id
AND sup_asg.job_id = job.id
AND sup_asg.primary_job_role_code = ''HR''
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date
                           AND sup.effective_end_date
AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.effective_start_date
                           AND peo.effective_end_date ' || g_rtn ||
  l_where_clause ||
  l_security_clause || g_rtn ||
'&ORDER_BY_CLAUSE ';

  x_custom_sql := l_sqltext;

END get_hr_detail;

END HRI_OLTP_PMV_DTL_SALARY ;

/
