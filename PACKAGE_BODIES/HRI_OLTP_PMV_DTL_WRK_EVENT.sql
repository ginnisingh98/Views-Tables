--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_DTL_WRK_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_DTL_WRK_EVENT" AS
/* $Header: hriopwev.pkb 120.17 2005/12/19 07:43:58 jrstewar noship $ */

  g_rtn                VARCHAR2(30) := '
';

/******************************************************************************/
/* The following drills:                                                      */
/*       - HIRE                                                               */
/*       - TRANSFER IN                                                        */
/*       - TRANSFER OUT                                                       */
/*       - TERMINATION / TURNOVER                                             */
/* in order to match the figure on the headcount/turnover portlets should be  */
/* derived from the INSERTs into the table HRI_DBI_**_WMV_CHGS. This SQL can  */
/* be found in the calc_events_** procedures of the headcount changes package */
/* HRI_DBI_WMV_CHANGES (hriwvch.pkb).                                         */
/******************************************************************************/

/******************************************************************************/
/* Returns the number of hires which should match the figure where the drill  */
/* came from because it runs off the same DBI summary table.                  */
/*                                                                            */
/* All the lookup views are DBI specific for easy DBI maintenance             */
/******************************************************************************/

PROCEDURE get_hire_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                           x_custom_sql     OUT NOCOPY VARCHAR2,
                           x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);

  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
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

  /* Set WHERE clause for direct reports or not */
  IF (l_parameter_rec.peo_sup_rollup_flag = 'Y' ) THEN

  l_select_clause :=
'SELECT -- headcount hire detail' || g_rtn ||
/* View by name of person hired */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person hired */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Manager of person hired as of hire date */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL2' || g_rtn ||
/* Organization person hired into */
',org.value              HRI_P_ORG_CN ' || g_rtn ||
/* Country where person was hired */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Job person was hired into (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN ' || g_rtn ||
/* Person type on hire date */
', null                  HRI_P_CHAR1_GA ' || g_rtn ||
/* Hire Date converted to chars */
',tch.effective_date     HRI_P_DATE1_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR2_GA ' || g_rtn ||
/* Order by default name sort order */
',peo.order_by           HRI_P_ORDER_BY_1';

l_from_clause :=
 'FROM hri_mdp_sup_wcnt_chg_asg_mv  tch
   , hri_mb_asgn_events_ct        hri_asg
   , hri_cs_geo_lochr_ct          geo
   , hri_dbi_cl_job_n_v           job
   , hri_dbi_cl_org_n_v           org
   , hri_dbi_cl_per_n_v           sup
   , hri_dbi_cl_per_n_v           peo
   , hri_dbi_cl_geo_country_v     ctr';

 l_where_clause :=
 'WHERE
      tch.supervisor_person_id   =  &HRI_PERSON+HRI_PER_USRDR_H
  AND hri_asg.supervisor_id   = sup.id
  AND tch.person_id       = peo.id
  AND tch.assignment_id   = hri_asg.assignment_id
  AND tch.effective_date  = hri_asg.effective_change_date
  AND hri_asg.organization_id = org.id
  AND hri_asg.job_id          = job.id (+)
  AND hri_asg.location_id     = geo.location_id
  AND geo.country_code    = ctr.id
  AND tch.change_type_id  = 1
  AND tch.hire_hdc > 0
  AND tch.direct_record_ind = 0
  AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.effective_start_date   AND peo.effective_end_date
  AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date   AND sup.effective_end_date
  AND tch.effective_date
      BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE  AND &BIS_CURRENT_EFFECTIVE_END_DATE';

  ELSE

  l_select_clause :=
'SELECT -- headcount hire detail' || g_rtn ||
/* View by name of person hired */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person hired */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Manager of person hired as of hire date */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL2' || g_rtn ||
/* Organization person hired into */
',org.value              HRI_P_ORG_CN ' || g_rtn ||
/* Country where person was hired */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Job person was hired into (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN ' || g_rtn ||
/* Person type on hire date */
', null                  HRI_P_CHAR1_GA ' || g_rtn ||
/* Hire Date converted to chars */
',hri_asg.effective_change_date     HRI_P_DATE1_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR2_GA ' || g_rtn ||
/* Order by default name sort order */
',peo.order_by           HRI_P_ORDER_BY_1';

l_from_clause :=
 'FROM
     hri_mb_asgn_events_ct        hri_asg
   , hri_cs_geo_lochr_ct          geo
   , hri_dbi_cl_job_n_v           job
   , hri_dbi_cl_org_n_v           org
   , hri_dbi_cl_per_n_v           sup
   , hri_dbi_cl_per_n_v           peo
   , hri_dbi_cl_geo_country_v     ctr';

 l_where_clause :=
 'WHERE
      hri_asg.supervisor_id   =  &HRI_PERSON+HRI_PER_USRDR_H
  AND hri_asg.supervisor_id   = sup.id
  AND hri_asg.person_id       = peo.id
  AND hri_asg.organization_id = org.id
  AND hri_asg.job_id          = job.id (+)
  AND hri_asg.location_id     = geo.location_id
  AND geo.country_code    = ctr.id
  AND (hri_asg.worker_hire_ind = 1
    OR hri_asg.post_hire_asgn_start_ind = 1)
  AND hri_asg.headcount > 0
  AND hri_asg.summarization_rqd_ind = 1
  AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.effective_start_date   AND peo.effective_end_date
  AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.effective_start_date   AND sup.effective_end_date
  AND hri_asg.effective_change_date
      BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE  AND &BIS_CURRENT_EFFECTIVE_END_DATE';

  END IF; -- where clause

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          ||'AND hri_asg.contingent_ind = 0';
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause || g_rtn
          || 'AND hri_asg.contingent_ind = 1';
  ELSE
      l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1';
  END IF;

 /* get security clause for Manager based security */
 l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');
 l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_hire_detail2;

/**
 * Returns the number of terms which should match the figure where the drill
 * came from
 *
 * All the lookup views are DBI specific for easy DBI maintenance
**/
PROCEDURE get_term_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                 x_custom_sql     OUT NOCOPY VARCHAR2,
                                 x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_mgr_name       VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Activite Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk(p_parameter_rec  => l_parameter_rec
                                                       ,p_bind_tab       => l_bind_tab);

  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
	l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
  ELSE
	l_lnk_mgr_name := '';
  END IF ;

/* Set WHERE clause for direct reports or not */
IF (l_parameter_rec.peo_sup_rollup_flag = 'Y' ) THEN

  l_select_clause :=
'SELECT -- headcount terminations detail' || g_rtn ||
/* View by name of person terminated */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person terminated */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
/* Manager of person terminated as of termination date */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Organization person terminated from */
',org.value              HRI_P_ORG_CN ' || g_rtn ||
/* Country where person was terminated */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Job person was terminated from (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN ' || g_rtn ||
/* Person type on termination date */
',''''                   HRI_P_CHAR1_GA ' || g_rtn ||
/* bug 3147015 Most recent hire date of terminated person */
',hri_asg.pow_start_date_adj     HRI_P_DATE1_GA ' || g_rtn ||
/* Termination Date */
',tch.effective_date-1   HRI_P_DATE2_GA ' || g_rtn ||
/* Termination Reason */
',decode(hri_asg.worker_term_ind
         , 1, hrl.meaning
         , to_char(null))      HRI_P_CHAR2_GA ' || g_rtn ||
/* Period of work in years
Length of Service is defined as the number of years (in decimal format) between an employee's
most recent hire date and the event date (termination date)
*/
',DECODE(tch.wkth_wktyp_sk_fk,''EMP'',pow_days_on_event_date/365
        ,DECODE(tch.wkth_wktyp_sk_fk,''CWK'',pow_months_on_event_date
               ,0)
        )                HRI_P_MEASURE1 '|| g_rtn ||
/* Performance Band */
',prf.value              HRI_P_CHAR3_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR4_GA' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM hri_mdp_sup_wcnt_chg_asg_mv  tch
     ,hri_mb_asgn_events_ct      hri_asg
     ,hri_cs_geo_lochr_ct        geo
     ,hri_cl_prfmnc_rtng_x_v     prf
     ,hri_dbi_cl_geo_country_v   ctr
     ,hri_dbi_cl_job_n_v         job
     ,hri_dbi_cl_org_n_v         org
     ,hri_dbi_cl_per_n_v         sup
     ,hri_dbi_cl_per_n_v         peo
     ,hr_standard_lookups        hrl';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
  AND tch.change_type_id  = 4
  AND tch.termination_hdc > 0
  AND hri_asg.summarization_rqd_ind = 1
  AND tch.direct_record_ind = 0
  AND tch.person_id       = peo.id
  AND tch.assignment_id   = hri_asg.assignment_id
  AND tch.effective_date  = hri_asg.effective_change_date
  AND hri_asg.supervisor_prv_id = sup.id
  AND hri_asg.organization_prv_id = org.id
  AND hri_asg.job_prv_id      = job.id (+)
  AND hri_asg.location_prv_id = geo.location_id
  AND hri_asg.perf_band_prv = prf.id (+)
  AND geo.country_code    = ctr.id
  AND tch.effective_date-1
       BETWEEN peo.effective_start_date AND peo.effective_end_date
  AND tch.effective_date-1
       BETWEEN sup.effective_start_date AND sup.effective_end_date
  AND tch.effective_date
       BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_EFFECTIVE_END_DATE
  AND hri_asg.leaving_reason_code = hrl.lookup_code (+)';

ELSE

l_select_clause :=
'SELECT -- headcount terminations detail' || g_rtn ||
/* View by name of person terminated */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person terminated */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
/* Manager of person terminated as of termination date */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Organization person terminated from */
',org.value              HRI_P_ORG_CN ' || g_rtn ||
/* Country where person was terminated */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Job person was terminated from (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)     HRI_P_JOB_CN ' || g_rtn ||
/* Person type on termination date */
',null                  HRI_P_CHAR1_GA ' || g_rtn ||
/* bug 3147015 Most recent hire date of terminated person */
',hri_asg.pow_start_date_adj     HRI_P_DATE1_GA ' || g_rtn ||
/* Termination Date */
',hri_asg.effective_change_date-1      HRI_P_DATE2_GA ' || g_rtn ||
/* Termination Reason */
',decode(hri_asg.worker_term_ind
         , 1, hrl.meaning
         , to_char(null))      HRI_P_CHAR2_GA ' || g_rtn ||
/* Period of work in years
Length of Service is defined as the number of years (in decimal format) between an employee's
most recent hire date and  the event date (termination date).
*/
',DECODE(tch.wkth_wktyp_sk_fk,''EMP'',pow_days_on_event_date/365
        ,DECODE(tch.wkth_wktyp_sk_fk,''CWK'',pow_months_on_event_date
               ,0)
        )
                         HRI_P_MEASURE1 '|| g_rtn ||
/* Performance Band */
',prf.value              HRI_P_CHAR3_GA ' ||
/* Event Type - for future use */
',null                   HRI_P_CHAR4_GA' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by           HRI_P_ORDER_BY_1 ' ;
l_from_clause :=
'FROM hri_mdp_sup_wcnt_chg_asg_mv  tch
     ,hri_mb_asgn_events_ct      hri_asg
     ,hri_cs_geo_lochr_ct        geo
     ,hri_dbi_cl_geo_country_v   ctr
     ,hri_dbi_cl_job_n_v         job
     ,hri_dbi_cl_org_n_v         org
     ,hri_dbi_cl_per_n_v         sup
     ,hri_dbi_cl_per_n_v         peo
     ,hri_cl_prfmnc_rtng_x_v     prf
     ,hr_standard_lookups        hrl';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
  AND tch.change_type_id  = 4
  AND tch.termination_hdc > 0
  AND hri_asg.summarization_rqd_ind = 1
  AND tch.direct_record_ind = 1
  AND tch.person_id       = peo.id
  AND tch.assignment_id   = hri_asg.assignment_id
  AND tch.effective_date  = hri_asg.effective_change_date
  AND hri_asg.supervisor_prv_id = sup.id
  AND hri_asg.organization_prv_id = org.id
  AND hri_asg.job_prv_id      = job.id (+)
  AND hri_asg.location_prv_id = geo.location_id
  AND hri_asg.perf_band_prv = prf.id (+)
  AND geo.country_code    = ctr.id
  AND tch.effective_date-1
       BETWEEN peo.effective_start_date AND peo.effective_end_date
  AND tch.effective_date-1
       BETWEEN sup.effective_start_date AND sup.effective_end_date
  AND tch.effective_date
       BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_EFFECTIVE_END_DATE
  AND hri_asg.leaving_reason_code = hrl.lookup_code (+)';

END IF; -- where clause

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.wkth_wktyp_sk_fk = ''EMP''' || g_rtn
          || 'AND hrl.lookup_type (+) = ''LEAV_REAS''';
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.wkth_wktyp_sk_fk = ''CWK''' || g_rtn
          || 'AND hrl.lookup_type (+) = ''HR_CWK_TERMINATION_REASONS''';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;


END get_term_detail2;

/**
 * Returns the number of transfers in which should match the figure where the
 * drill came from .
 *
 * All the lookup views are DBI specific for easy DBI maintenance
**/
PROCEDURE get_trans_in_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_custom_sql     OUT NOCOPY VARCHAR2,
                                     x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
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

  l_select_clause :=
'SELECT -- headcount transfers in detail' || g_rtn ||
/* View by name of person transferred */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person transferred */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Transfer to Manager */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL2' || g_rtn ||
/* Transfer from Organization */
',org_prev.value         HRI_P_ORG_CN ' || g_rtn ||
/* Transfer to Organization */
',org.value              HRI_P_CHAR1_GA ' || g_rtn ||
/* Transfer to country */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Transfer to job (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN ' || g_rtn ||
/* Person type on hire date */
',null                   HRI_P_CHAR2_GA ' || g_rtn ||
/* Most Recent Hire Date */
', to_char(null)         HRI_P_DATE1_GA ' || g_rtn ||
/* Transfer (In) Date */
',tch.effective_date     HRI_P_DATE2_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR3_GA ' || g_rtn ||
/* Order by default name sort order */
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM
 hri_mb_asgn_events_ct      asg_to
,hri_mb_asgn_events_ct      asg_from
,hri_mdp_sup_wcnt_chg_asg_mv   tch
,hri_cs_geo_lochr_ct        geo
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_job_n_v         job
,hri_dbi_cl_org_n_v         org_prev
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_per_n_v         peo';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND tch.effective_date
    BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND tch.change_type_id        = 2
AND tch.transfer_in_hdc       > 0
AND tch.transfer_within_count = 1  -- to exclude transfers within
AND tch.assignment_id         = asg_to.assignment_id
AND tch.effective_date  BETWEEN asg_to.effective_change_date AND asg_to.effective_change_end_date
AND tch.assignment_id         = asg_from.assignment_id
AND tch.effective_date-1 BETWEEN asg_from.effective_change_date AND asg_from.effective_change_end_date
AND asg_to.person_id          = peo.id
AND tch.effective_date  BETWEEN peo.effective_start_date AND peo.effective_end_date
AND asg_to.supervisor_id      = sup.id -- manager transferred into
AND tch.effective_date  BETWEEN sup.effective_start_date AND sup.effective_end_date
AND asg_from.organization_id  = org_prev.id
AND asg_to.organization_id    = org.id
AND asg_to.job_id             = job.id (+)
AND asg_to.location_id        = geo.location_id
AND geo.country_code          = ctr.id ';

  /* append to where clause a condition if for direct reports*/
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N' ) THEN
     -- add condition to restrict to directs only
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 1';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 0';
  END IF;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          ||'AND asg_to.contingent_ind = 0';
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause || g_rtn
          || 'AND asg_to.contingent_ind = 1';
  ELSE
      l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_trans_in_detail2;

/**
 * Returns the number of transfers out which should match the figure where the
 * drill came from .
 *
 * All the lookup views are DBI specific for easy DBI maintenance
**/
PROCEDURE get_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql     OUT NOCOPY VARCHAR2,
                                x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
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

  l_select_clause :=
'SELECT -- headcount transfers out detail' || g_rtn ||
/* View by name of person transferring out */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person transferred */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Transfer from manager */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL2' || g_rtn ||
/* Transfer from Organization */
',org_prev.value         HRI_P_ORG_CN ' || g_rtn ||
/* Transfer to Organization */
',org.value           HRI_P_CHAR1_GA ' || g_rtn ||
/* Transfer from Country */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Transfer from Job (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)     HRI_P_JOB_CN ' || g_rtn ||
/* Transfer from Person Type */
', null                  HRI_P_CHAR2_GA  ' || g_rtn ||
/* bug Most recent hire date of transferee */
', to_char(null)        HRI_P_DATE1_GA ' || g_rtn ||
/* Transfer Out Date */
', tch.effective_date    HRI_P_DATE2_GA ' || g_rtn ||
/* Period of work in years
Length of Service is defined as the number of years (in decimal format) between an employee's
most recent hire date up the event date (transfer out).
*/
',ROUND ( ( (asg_from.POW_DAYS_ON_EVENT_DATE +
            (tch.effective_date - asg_from.EFFECTIVE_CHANGE_DATE)
         )
          /365),2)
HRI_P_MEASURE1 '|| g_rtn ||
/* Performance Band */
',prf.value              HRI_P_CHAR3_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR4_GA ' || g_rtn ||
/* Order by default person name sort order */
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM
 hri_mb_asgn_events_ct      asg_to
,hri_mb_asgn_events_ct      asg_from
,hri_mdp_sup_wcnt_chg_asg_mv   tch
,hri_cs_geo_lochr_ct        geo
,hri_cl_prfmnc_rtng_x_v     prf
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_job_n_v         job
,hri_dbi_cl_org_n_v         org_prev
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_per_n_v         peo';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND tch.effective_date
    BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE    AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND tch.change_type_id   = 3
AND tch.transfer_out_hdc > 0
AND tch.transfer_within_count  = 1
AND tch.assignment_id = asg_to.assignment_id
AND tch.effective_date  BETWEEN asg_to.effective_change_date AND asg_to.effective_change_end_date
AND tch.assignment_id = asg_from.assignment_id
AND tch.effective_date-1  BETWEEN asg_from.effective_change_date AND asg_from.effective_change_end_date
AND asg_to.person_id    = peo.id
AND tch.effective_date  BETWEEN peo.effective_start_date AND peo.effective_end_date
AND asg_from.supervisor_id    = sup.id  -- manager who had the transfer out
AND tch.effective_date  BETWEEN sup.effective_start_date AND sup.effective_end_date
AND asg_from.organization_id = org_prev.id
AND asg_to.organization_id   = org.id
AND asg_to.job_id = job.id (+)
AND asg_to.location_id = geo.location_id
AND asg_from.perf_band = prf.id (+)
AND geo.country_code = ctr.id ';

  /* append to where clause a condition if for direct reports*/
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N' ) THEN
     -- add condition to restrict to directs only
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 1';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 0';
  END IF;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          ||'AND asg_from.contingent_ind = 0';
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause || g_rtn
          || 'AND asg_from.contingent_ind = 1';
  ELSE
      l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause :=  hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_trans_out_detail2;


PROCEDURE get_turnover_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                               x_custom_sql     OUT NOCOPY VARCHAR2,
                               x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_parameter_name        VARCHAR2(100);
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

/* Dynamic drill to emp dir */
  l_lnk_mgr_name        VARCHAR2(4000);
  l_lnk_profile_chk    VARCHAR2(4000);

/* Dynamic sql variables */
  l_sql_stmt           VARCHAR2(32000);
  l_security_clause    VARCHAR2(4000);
  l_fact_conditions    VARCHAR2(8000);

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
    l_fact_conditions := l_fact_conditions ||
          'AND fact.wkth_wktyp_sk_fk = ''EMP''' || g_rtn;
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_fact_conditions := l_fact_conditions ||
          'AND fact.wkth_wktyp_sk_fk = ''CWK''' || g_rtn;
  END IF;

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Activate Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk
                        (p_parameter_rec  => l_parameter_rec
                        ,p_bind_tab       => l_bind_tab);

/* Drill only possible on current date */
  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
    l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&' ||
                      'pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
  END IF;

/* Loop through parameters that have been set */
  l_parameter_name := l_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP
    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' OR
        l_parameter_name = 'HRI_REASON+HRI_RSN_SEP_X' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

    /* Dynamically set conditions for parameter */
      l_fact_conditions := l_fact_conditions ||
        'AND fact.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                        (l_parameter_name).fact_viewby_col ||
        ' IN (' || l_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := l_bind_tab.NEXT(l_parameter_name);
  END LOOP;

/* Add directs condition if rollup = 'N' */
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N') THEN
    l_fact_conditions := l_fact_conditions ||
         'AND fact.direct_ind = 1';
  END IF;

  l_sql_stmt :=
'SELECT -- turnover detail'  || g_rtn ||
/* Order by default person name sort order */
' peo.order_by                      HRI_P_ORDER_BY_1' || g_rtn ||
/* View by name of person terminated */
',peo.id                            VIEWBYID' || g_rtn ||
',peo.value                         VIEWBY' || g_rtn ||
/* Name of person terminated  */
',peo.value                         HRI_P_CHAR1_GA' || g_rtn ||
/* Manager of person terminated as of termination date */
',sup.value                         HRI_P_CHAR2_GA' || g_rtn ||
',sup.id                            HRI_P_SUP_ID' || g_rtn ||
',''' || l_lnk_mgr_name || '''      HRI_P_DRILL_URL1' || g_rtn ||
/* Organization person terminated from */
',org.value                         HRI_P_CHAR3_GA' || g_rtn ||
/* Country where person was terminated */
',ctr.value                         HRI_P_CHAR4_GA' || g_rtn ||
/* Job person was terminated from (using default display configuration) */
',hri_oltp_view_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)                 HRI_P_CHAR5_GA' || g_rtn ||
/* Most recent hire date of terminated person  */
',fact.pow_start_date               HRI_P_DATE1_GA' || g_rtn ||
/* Termination Date  */
',fact.effective_date - 1           HRI_P_DATE2_GA' || g_rtn ||
/* Termination Reason */
',rsn.value                         HRI_P_CHAR6_GA' || g_rtn ||
/* Period of work in years
Length of Service is defined as the number of years (in decimal format) between an employee's
most recent hire date and the  event_date (termination date).  */
',(fact.effective_date - fact.pow_start_date) / 365
                                    HRI_P_MEASURE1' || g_rtn ||
/* Performance Band */
',prf.value                         HRI_P_MEASURE2
FROM
 hri_mdp_sup_wcnt_term_asg_mv  fact
,hri_cs_geo_lochr_ct           geo
,hri_dbi_cl_geo_country_v      ctr
,hri_dbi_cl_job_n_v            job
,hri_dbi_cl_org_n_v            org
,hri_dbi_cl_per_n_v            sup
,hri_dbi_cl_per_n_v            peo
,hri_cl_prfmnc_rtng_x_v        prf
,hri_cl_rsn_sep_x_v            rsn
WHERE fact.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND fact.separation_hdc > 0
AND fact.person_id = peo.id
AND fact.direct_supervisor_person_id = sup.id
AND fact.organization_id = org.id
AND fact.job_id      = job.id (+)
AND fact.perf_band = prf.id (+)
AND fact.location_id = geo.location_id
AND fact.geo_country_code = ctr.id
AND fact.effective_date - 1 BETWEEN peo.effective_start_date
                            AND peo.effective_end_date
AND fact.effective_date - 1 BETWEEN sup.effective_start_date
                            AND sup.effective_end_date
AND fact.effective_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                        AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND fact.leaving_reason_code = rsn.id' || g_rtn ||
 l_fact_conditions ||
'&ORDER_BY_CLAUSE';

  x_custom_sql := l_sql_stmt;

END get_turnover_detail2;

PROCEDURE get_wf_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql     OUT NOCOPY VARCHAR2,
                                x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);
  l_lnk_mgr_to_name    VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Activite Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk(p_parameter_rec  => l_parameter_rec
                                                       ,p_bind_tab       => l_bind_tab);

  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
	l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_PER_ID&OAPB=FII_HR_BRAND_TEXT';
	l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
	l_lnk_mgr_to_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_TO_ID&OAPB=FII_HR_BRAND_TEXT';
  ELSE
    l_lnk_emp_name := '';
    l_lnk_mgr_name := '';
    l_lnk_mgr_to_name := '';
  END IF ;

  l_select_clause :=
'SELECT -- Staff transfers out detail' || g_rtn ||
/* View by name of person transferring out */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person transferred */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || ''' HRI_P_DRILL_URL1' || g_rtn ||
/* Transfer from manager */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''  HRI_P_DRILL_URL2' || g_rtn ||
/* Transfer To manager */
',supTo.value            HRI_P_PER_SUP_TO_LNAME_CN ' || g_rtn ||
',supTo.id               HRI_P_SUP_TO_ID ' || g_rtn ||
',''' || l_lnk_mgr_to_name || '''  HRI_P_DRILL_URL3' || g_rtn ||
/* Transfer from Organization */
',org_prev.value         HRI_P_ORG_CN' || g_rtn ||
/* Transfer to Organization */
',org.value              HRI_P_CHAR1_GA' || g_rtn ||
/* Transfer from Country */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Transfer from Job (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN'   || g_rtn ||
',tch.transfer_out_hdc   HRI_P_MEASURE1' || g_rtn ||
',prsnwtyp.value         HRI_P_CHAR3_GA' || g_rtn ||
',tch.effective_date     HRI_P_DATE2_GA' || g_rtn ||
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM
 hri_mb_asgn_events_ct      asg_to
,hri_mb_asgn_events_ct      asg_from
,hri_mdp_sup_wcnt_chg_asg_mv   tch
,hri_cs_geo_lochr_ct        geo
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_job_n_v         job
,hri_dbi_cl_org_n_v         org_prev
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_per_n_v         supTo
,hri_cl_wkth_wktyp_v        prsnwtyp
,hri_dbi_cl_per_n_v         peo';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND tch.effective_date
    BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE    AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND tch.change_type_id   = 3
AND tch.transfer_within_count  = 1
AND tch.transfer_out_hdc > 0    -- headcount greater than zero restriction
AND tch.assignment_id = asg_to.assignment_id
AND tch.effective_date  BETWEEN asg_to.effective_change_date AND asg_to.effective_change_end_date
AND tch.assignment_id = asg_from.assignment_id
AND tch.effective_date-1  BETWEEN asg_from.effective_change_date AND asg_from.effective_change_end_date
AND asg_to.person_id    = peo.id
AND tch.effective_date  BETWEEN peo.effective_start_date AND peo.effective_end_date
AND asg_from.supervisor_id    = sup.id  -- manager who had the transfer out
AND tch.effective_date  BETWEEN sup.effective_start_date AND sup.effective_end_date
AND asg_to.supervisor_id    = supTo.id  -- manager who had the transfer in
AND tch.effective_date  BETWEEN supTo.effective_start_date AND supTo.effective_end_date
AND asg_from.organization_id = org_prev.id
AND asg_to.organization_id   = org.id
AND asg_to.job_id = job.id (+)
AND asg_to.location_id = geo.location_id
AND geo.country_code = ctr.id
AND tch.wkth_wktyp_sk_fk = prsnwtyp.id
';

  /* append to where clause a condition if for direct reports*/
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N' ) THEN
     -- add condition to restrict to directs only
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 1';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 0';
  END IF;

  /* Check Whether the Report is being run in Emp or CWK Mode */
  IF (l_parameter_rec.wkth_wktyp_sk_fk = 'EMP') THEN
     l_where_clause := l_where_clause || g_rtn
          ||'AND tch.wkth_wktyp_sk_fk = ''EMP''';
  ELSIF (l_parameter_rec.wkth_wktyp_sk_fk = 'CWK') THEN
    l_where_clause := l_where_clause || g_rtn
          || 'AND tch.wkth_wktyp_sk_fk = ''CWK''';
  ELSE
      l_where_clause := l_where_clause || g_rtn
          || 'AND 1 = 1';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause :=  hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_wf_trans_out_detail2;

PROCEDURE get_c_trans_out_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                x_custom_sql     OUT NOCOPY VARCHAR2,
                                x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);
  l_lnk_mgr_to_name    VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Activite Drill URL for Link to HR Employee Directory */
  l_lnk_profile_chk := hri_oltp_pmv_util_pkg.chk_emp_dir_lnk(p_parameter_rec  => l_parameter_rec
                                                       ,p_bind_tab       => l_bind_tab);

  IF (l_lnk_profile_chk = 1 AND l_parameter_rec.time_curr_end_date = TRUNC(SYSDATE)) THEN
	l_lnk_emp_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_PER_ID&OAPB=FII_HR_BRAND_TEXT';
	l_lnk_mgr_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_ID&OAPB=FII_HR_BRAND_TEXT';
	l_lnk_mgr_to_name := 'pFunctionName=HR_EMPDIR_EMPDTL_PROXY_SS&pId=HRI_P_SUP_TO_ID&OAPB=FII_HR_BRAND_TEXT';
  ELSE
    l_lnk_emp_name := '';
    l_lnk_mgr_name := '';
    l_lnk_mgr_to_name := '';
  END IF ;

  l_select_clause :=
'SELECT -- Staff transfers out detail' || g_rtn ||
/* View by name of person transferring out */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person transferred */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || ''' HRI_P_DRILL_URL1' || g_rtn ||
/* Transfer from manager */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''  HRI_P_DRILL_URL2' || g_rtn ||
/* Transfer To manager */
',supTo.value            HRI_P_PER_SUP_TO_LNAME_CN ' || g_rtn ||
',supTo.id               HRI_P_SUP_TO_ID ' || g_rtn ||
',''' || l_lnk_mgr_to_name || '''  HRI_P_DRILL_URL3' || g_rtn ||
/* Transfer from Organization */
',org_prev.value         HRI_P_ORG_CN' || g_rtn ||
/* Transfer to Organization */
',org.value              HRI_P_CHAR1_GA' || g_rtn ||
/* Transfer from Country */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Transfer from Job (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN'   || g_rtn ||
',tch.transfer_out_hdc   HRI_P_MEASURE1' || g_rtn ||
',prsnwtyp.value         HRI_P_CHAR3_GA' || g_rtn ||
',asg_to.pow_start_date_adj  HRI_P_DATE1_GA' || g_rtn ||
',tch.effective_date     HRI_P_DATE2_GA' || g_rtn ||
',ROUND ( ( (asg_from.POW_DAYS_ON_EVENT_DATE +
            (tch.effective_date - asg_from.EFFECTIVE_CHANGE_DATE)
         )
          /30.42),2)     HRI_P_MEASURE2' || g_rtn ||
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM
 hri_mb_asgn_events_ct      asg_to
,hri_mb_asgn_events_ct      asg_from
,hri_mdp_sup_wcnt_chg_asg_mv   tch
,hri_cs_geo_lochr_ct        geo
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_job_n_v         job
,hri_dbi_cl_org_n_v         org_prev
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_per_n_v         supTo
,hri_cl_wkth_wktyp_v        prsnwtyp
,hri_dbi_cl_per_n_v         peo';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND tch.effective_date
    BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE    AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND tch.change_type_id   = 3
AND tch.transfer_within_count  = 1
AND tch.transfer_out_hdc > 0    -- headcount greater than zero restriction
AND tch.assignment_id = asg_to.assignment_id
AND tch.effective_date  BETWEEN asg_to.effective_change_date AND asg_to.effective_change_end_date
AND tch.assignment_id = asg_from.assignment_id
AND tch.effective_date-1  BETWEEN asg_from.effective_change_date AND asg_from.effective_change_end_date
AND asg_to.person_id    = peo.id
AND tch.effective_date  BETWEEN peo.effective_start_date AND peo.effective_end_date
AND asg_from.supervisor_id    = sup.id  -- manager who had the transfer out
AND tch.effective_date  BETWEEN sup.effective_start_date AND sup.effective_end_date
AND asg_to.supervisor_id    = supTo.id  -- manager who had the transfer in
AND tch.effective_date  BETWEEN supTo.effective_start_date AND supTo.effective_end_date
AND asg_from.organization_id = org_prev.id
AND asg_to.organization_id   = org.id
AND asg_to.job_id = job.id (+)
AND asg_to.location_id = geo.location_id
AND geo.country_code = ctr.id
AND tch.wkth_wktyp_sk_fk = prsnwtyp.id
AND tch.wkth_wktyp_sk_fk = ''CWK'' -- contingent workers only
';

  /* append to where clause a condition if for direct reports*/
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N' ) THEN
     -- add condition to restrict to directs only
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 1';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 0';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause :=  hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_c_trans_out_detail2;

PROCEDURE get_c_trans_in_detail2(p_param          IN  BIS_PMV_PAGE_PARAMETER_TBL,
                                     x_custom_sql     OUT NOCOPY VARCHAR2,
                                     x_custom_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_lnk_emp_name       VARCHAR2(4000);
  l_lnk_mgr_name       VARCHAR2(4000);
  l_select_clause      VARCHAR2(4000);
  l_from_clause        VARCHAR2(4000);
  l_where_clause       VARCHAR2(4000);
  l_orderby_clause     VARCHAR2(4000);
  l_security_clause    VARCHAR2(4000);

  l_lnk_profile_chk    VARCHAR2(4000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get parameters into a pl/sql record l_param_rec */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_param,
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

  l_select_clause :=
'SELECT -- headcount transfers in detail' || g_rtn ||
/* View by name of person transferred */
' peo.value              VIEWBY ' || g_rtn ||
/* Name of person transferred */
',peo.value              HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                 HRI_P_PER_ID ' || g_rtn ||
',''' || l_lnk_emp_name || '''
                         HRI_P_DRILL_URL1' || g_rtn ||
/* Transfer to Manager */
',sup.value              HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                 HRI_P_SUP_ID ' || g_rtn ||
',''' || l_lnk_mgr_name || '''
                         HRI_P_DRILL_URL2' || g_rtn ||
/* Transfer from Organization */
',org_prev.value         HRI_P_ORG_CN ' || g_rtn ||
/* Transfer to Organization */
',org.value           HRI_P_CHAR1_GA ' || g_rtn ||
/* Transfer to country */
',ctr.value              HRI_P_GEO_CTY_CN ' || g_rtn ||
/* Transfer to job (using default display configuration) */
',hri_bpl_job.get_job_display_name
        (job.id
        ,job.business_group_id
        ,job.value)      HRI_P_JOB_CN ' || g_rtn ||
/* Person type on hire date */
',null                  HRI_P_CHAR2_GA ' || g_rtn ||
/* Most Recent Hire Date */
', to_char(null)        HRI_P_DATE1_GA ' || g_rtn ||
/* Transfer (In) Date */
',tch.effective_date    HRI_P_DATE2_GA ' || g_rtn ||
/* Event Type - for future use */
',null                   HRI_P_CHAR3_GA ' || g_rtn ||
/* Order by default name sort order */
',peo.order_by           HRI_P_ORDER_BY_1 ';

l_from_clause :=
'FROM
 hri_mb_asgn_events_ct      asg_to
,hri_mb_asgn_events_ct      asg_from
,hri_mdp_sup_wcnt_chg_asg_mv   tch
,hri_cs_geo_lochr_ct        geo
,hri_dbi_cl_geo_country_v   ctr
,hri_dbi_cl_job_n_v         job
,hri_dbi_cl_org_n_v         org_prev
,hri_dbi_cl_org_n_v         org
,hri_dbi_cl_per_n_v         sup
,hri_dbi_cl_per_n_v         peo';

l_where_clause :=
'WHERE tch.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
AND tch.effective_date
    BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_EFFECTIVE_END_DATE
AND tch.change_type_id        = 2
AND tch.transfer_in_hdc       > 0
AND tch.transfer_within_count = 1  -- to exclude transfers within
AND tch.assignment_id         = asg_to.assignment_id
AND tch.effective_date  BETWEEN asg_to.effective_change_date AND asg_to.effective_change_end_date
AND tch.assignment_id         = asg_from.assignment_id
AND tch.effective_date-1 BETWEEN asg_from.effective_change_date AND asg_from.effective_change_end_date
AND asg_to.person_id          = peo.id
AND tch.effective_date  BETWEEN peo.effective_start_date AND peo.effective_end_date
AND asg_to.supervisor_id      = sup.id -- manager transferred into
AND tch.effective_date  BETWEEN sup.effective_start_date AND sup.effective_end_date
AND asg_from.organization_id  = org_prev.id
AND asg_to.organization_id    = org.id
AND asg_to.job_id             = job.id (+)
AND asg_to.location_id        = geo.location_id
AND geo.country_code          = ctr.id
AND tch.wkth_wktyp_sk_fk      = ''CWK'' '; --contingent workers only

  /* append to where clause a condition if for direct reports*/
  IF (l_parameter_rec.peo_sup_rollup_flag = 'N' ) THEN
     -- add condition to restrict to directs only
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 1';
  ELSE
     l_where_clause := l_where_clause || g_rtn
          || 'AND tch.direct_record_ind = 0';
  END IF;

  /* get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

  l_orderby_clause := '&ORDER_BY_CLAUSE';

  x_custom_sql := l_select_clause    || g_rtn
                ||l_from_clause      || g_rtn
                ||l_where_clause     || g_rtn
                ||l_security_clause  || g_rtn
                ||l_orderby_clause;

END get_c_trans_in_detail2;


END HRI_OLTP_PMV_DTL_WRK_EVENT;

/
