--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_ABS_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_ABS_DTL" AS
/* $Header: hriopabsdt.pkb 120.9 2008/01/06 10:11:40 vjaganat noship $ */

g_rtn                VARCHAR2(30) := '
';

g_unassigned         VARCHAR2(50) := HRI_OLTP_VIEW_MESSAGE.get_unassigned_msg;

g_abs_cat_cl_view    VARCHAR2(30) :=
     hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab('HRI_ABSNC+HRI_ABSNC_CAT').viewby_table;
g_abs_rsn_cl_view    VARCHAR2(30) :=
     hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab('HRI_ABSNC+HRI_ABSNC_RSN').viewby_table;
g_abs_per_per_cl_view    VARCHAR2(30) := 'hri_dbi_cl_per_n_v';
g_abs_per_sup_cl_view    VARCHAR2(30) := 'hri_dbi_cl_per_n_v';

/******************************************************************************/
/* Absence detail for Staff = Directs                                         */
/******************************************************************************/
PROCEDURE get_abs_detail_directs
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

  -- functional decision (JC) default to days
  l_dynmc_drtn_prd      VARCHAR2(100) := 'factM.abs_drtn_days_prd';
  l_dynmc_drtn          VARCHAR2(100) := 'abs_cs.abs_drtn_days';

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Set security clause */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

    IF (l_parameter_name = 'HRI_ABSNC+HRI_ABSNC_CAT' ) THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause ||
'AND abs_cs.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                 (l_parameter_name).fact_viewby_col  ||
' IN (' || p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);
  END LOOP;

  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure profile option                                    */
    IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
         l_dynmc_drtn_prd := 'factM.abs_drtn_days_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_days';
    ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
         l_dynmc_drtn_prd := 'factM.abs_drtn_hrs_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_hrs';
    ELSE -- functional decision (JC) default to days
         l_dynmc_drtn_prd := 'factM.abs_drtn_days_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_days';
    END IF;



/* Formulate query */
  l_sqltext :=
'SELECT -- Employee Absence Detail (Direct Reports)' || g_rtn ||
' peo.value                VIEWBY ' || g_rtn ||
',peo.order_by             HRI_P_ORDER_BY_1 ' || g_rtn ||
',peo.value                HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                   HRI_P_PER_ID ' || g_rtn ||
',''' || p_lnk_emp_name || ''' HRI_P_DRILL_URL1' || g_rtn ||
',sup.value                HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                   HRI_P_SUP_ID ' || g_rtn ||
',''' || p_lnk_mgr_name || ''' HRI_P_DRILL_URL2' || g_rtn ||
',abs_cs.abs_start_date    HRI_P_DATE1_GA' || g_rtn ||
',DECODE(abs_cs.abs_end_date,
           to_date(''' || to_char(hr_general.end_of_time, 'DD-MM-YYYY') ||
                   ''', ''DD-MM-YYYY''), to_date(NULL),
         abs_cs.abs_end_date
        )      HRI_P_DATE2_GA' || g_rtn ||
',abs_cat.value            HRI_P_CHAR1_GA' || g_rtn ||
',pabstyp.name             HRI_P_CHAR2_GA' || g_rtn ||
',abs_rsn.value            HRI_P_CHAR3_GA' || g_rtn ||
','||l_dynmc_drtn_prd||'   HRI_P_MEASURE1' || g_rtn ||
','||l_dynmc_drtn||'       HRI_P_MEASURE2' || g_rtn ||
'FROM
-- inner query
 (SELECT /*+ NO_MERGE */
   fact.abs_person_id
  ,suph.sup_person_id             supervisor_person_id
  ,fact.absence_sk_fk
  ,abs_cs.absence_category_code   absence_category_code
  ,SUM(fact.abs_drtn_days)        abs_drtn_days_prd
  ,SUM(fact.abs_drtn_hrs)         abs_drtn_hrs_prd
  FROM hri_mb_utl_absnc_ct  fact
      ,hri_cs_suph          suph
      ,HRI_CS_ABSENCE_CT    abs_cs
  WHERE suph.sup_person_id = &HRI_PERSON+HRI_PER_USRDR_H
  AND fact.effective_date BETWEEN suph.effective_start_date
                          AND suph.effective_end_date
  AND suph.sub_invalid_flag_code = ''N''
  AND suph.sub_relative_level = 1
  AND suph.sub_person_id = fact.abs_person_id
  AND fact.absence_sk_fk = abs_cs.absence_sk_pk
  AND fact.abs_person_id = abs_cs.abs_person_id
  AND fact.effective_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                          AND &BIS_CURRENT_EFFECTIVE_END_DATE
-- dynamic where conditions' || g_rtn ||
l_where_clause|| g_rtn ||
'-- end of dynamic where conditions
  GROUP BY
   fact.abs_person_id
  ,suph.sup_person_id
  ,fact.absence_sk_fk
  ,abs_cs.absence_category_code
 ) factM
, hri_cs_absence_ct abs_cs
, per_absence_attendance_types pabstyp
, hri_cl_absnc_cat_v abs_cat
, hri_cl_absnc_rsn_v abs_rsn
, hri_dbi_cl_per_n_v peo
, hri_dbi_cl_per_n_v sup
, per_all_assignments_f asg
WHERE
    factM.absence_sk_fk = abs_cs.absence_sk_pk
AND abs_cs.absence_attendance_type_id  = pabstyp.absence_attendance_type_id
AND abs_cs.absence_category_code = abs_cat.id
AND abs_cs.absence_reason_code = abs_rsn.id
AND factM.abs_person_id = peo.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.start_date and peo.end_date
AND factM.abs_person_id = asg.person_id
AND abs_cs.abs_start_date BETWEEN asg.effective_start_date and asg.effective_end_date
AND asg.primary_flag = ''Y''
AND asg.supervisor_id = sup.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN sup.start_date and sup.end_date' || g_rtn ||
 l_security_clause || g_rtn ||
'&ORDER_BY_CLAUSE ';

  x_custom_sql := l_sqltext;

END get_abs_detail_directs;

/******************************************************************************/
/* Absence (Employee) Detail for Staff = All                                  */
/******************************************************************************/
PROCEDURE get_abs_detail_all
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

   -- functional decision (JC) default to days
  l_dynmc_drtn_prd      VARCHAR2(100) := 'factM.abs_drtn_days_prd';
  l_dynmc_drtn          VARCHAR2(100) := 'abs_cs.abs_drtn_days';

BEGIN

/* Initialize table/record variables */
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Set security clause */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

    IF (l_parameter_name = 'HRI_ABSNC+HRI_ABSNC_CAT' ) THEN

    /* Dynamically set conditions for parameter */
      l_where_clause := l_where_clause ||
'AND fact.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                    (l_parameter_name).fact_viewby_col  ||
' IN (' || p_bind_tab(l_parameter_name).pmv_bind_string || ')' || g_rtn;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);
  END LOOP;

  /* formulate the dynmaic column selection based on Absence Duration
     unit of measure profile option                                    */
    IF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'DAYS') THEN
         l_dynmc_drtn_prd := 'factM.abs_drtn_days_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_days';
    ELSIF (hri_bpl_utilization.get_abs_durtn_profile_vl = 'HOURS') THEN
         l_dynmc_drtn_prd := 'factM.abs_drtn_hrs_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_hrs';
    ELSE -- functional decision (JC) default to days
         l_dynmc_drtn_prd := 'factM.abs_drtn_days_prd';
         l_dynmc_drtn     := 'abs_cs.abs_drtn_days';
    END IF;


/* Formulate query */
  l_sqltext :=
'SELECT -- Employee Absence Detail (All Staff)' || g_rtn ||
' peo.value                VIEWBY ' || g_rtn ||
',peo.order_by             HRI_P_ORDER_BY_1 ' || g_rtn ||
',peo.value                HRI_P_PER_LNAME_CN ' || g_rtn ||
',peo.id                   HRI_P_PER_ID ' || g_rtn ||
',''' || p_lnk_emp_name || ''' HRI_P_DRILL_URL1' || g_rtn ||
',sup.value                HRI_P_PER_SUP_LNAME_CN ' || g_rtn ||
',sup.id                   HRI_P_SUP_ID ' || g_rtn ||
',''' || p_lnk_mgr_name || ''' HRI_P_DRILL_URL2' || g_rtn ||
',abs_cs.abs_start_date    HRI_P_DATE1_GA' || g_rtn ||
',DECODE(abs_cs.abs_end_date,
           to_date(''' || to_char(hr_general.end_of_time, 'DD-MM-YYYY') ||
                   ''', ''DD-MM-YYYY''), to_date(NULL),
         abs_cs.abs_end_date
        )      HRI_P_DATE2_GA' || g_rtn ||
',abs_cat.value            HRI_P_CHAR1_GA' || g_rtn ||
',pabstyp.name             HRI_P_CHAR2_GA' || g_rtn ||
',abs_rsn.value            HRI_P_CHAR3_GA' || g_rtn ||
','||l_dynmc_drtn_prd||'   HRI_P_MEASURE1' || g_rtn ||
','||l_dynmc_drtn||'       HRI_P_MEASURE2' || g_rtn ||
'FROM
-- inner query
 (SELECT /*+ NO_MERGE */
   fact.abs_person_id
  ,fact.supervisor_person_id
  ,fact.absence_sk_fk
  ,SUM(fact.abs_drtn_days)        abs_drtn_days_prd
  ,SUM(fact.abs_drtn_hrs)         abs_drtn_hrs_prd
  FROM
   hri_mdp_sup_absnc_occ_ct fact
  WHERE fact.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
  AND fact.effective_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                          AND &BIS_CURRENT_EFFECTIVE_END_DATE
-- dynamic where conditions' || g_rtn ||
l_where_clause|| g_rtn ||
'-- end of dynamic where conditions
  GROUP BY
   fact.abs_person_id
  ,fact.supervisor_person_id
  ,fact.absence_sk_fk
 ) factM
 -- end of inner query
, hri_cs_absence_ct abs_cs
, per_absence_attendance_types pabstyp
, hri_cl_absnc_cat_v abs_cat
, hri_cl_absnc_rsn_v abs_rsn
, hri_dbi_cl_per_n_v peo
, per_all_assignments_f asg
, hri_dbi_cl_per_n_v sup
WHERE factM.absence_sk_fk = abs_cs.absence_sk_pk
AND abs_cs.absence_attendance_type_id  = pabstyp.absence_attendance_type_id
AND abs_cs.absence_category_code = abs_cat.id
AND abs_cs.absence_reason_code = abs_rsn.id
AND factM.abs_person_id = peo.id
AND &BIS_CURRENT_ASOF_DATE BETWEEN peo.start_date and peo.end_date
AND factM.abs_person_id = asg.person_id
AND abs_cs.abs_start_date BETWEEN asg.effective_start_date and asg.effective_end_date
AND asg.primary_flag = ''Y''
AND asg.supervisor_id = sup.id
AND abs_cs.abs_start_date BETWEEN sup.start_date and sup.end_date' || g_rtn ||
 l_security_clause || g_rtn ||
'&ORDER_BY_CLAUSE ';

  x_custom_sql := l_sqltext;

END get_abs_detail_all;

/******************************************************************************/
/* Absence Detail report                                                      */
/******************************************************************************/
PROCEDURE GET_ABS_DETAIL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
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
    get_abs_detail_directs
     (p_parameter_rec => l_parameter_rec,
      p_bind_tab      => l_bind_tab,
      p_lnk_emp_name  => l_lnk_emp_name,
      p_lnk_mgr_name  => l_lnk_mgr_name,
      x_custom_sql    => x_custom_sql,
      x_custom_output => x_custom_output);

  ELSE

  /* Call all staff function to get the SQL */
    get_abs_detail_all
     (p_parameter_rec => l_parameter_rec,
      p_bind_tab      => l_bind_tab,
      p_lnk_emp_name  => l_lnk_emp_name,
      p_lnk_mgr_name  => l_lnk_mgr_name,
      x_custom_sql    => x_custom_sql,
      x_custom_output => x_custom_output);

  END IF;

END get_abs_detail;

END HRI_OLTP_PMV_ABS_DTL ;

/
