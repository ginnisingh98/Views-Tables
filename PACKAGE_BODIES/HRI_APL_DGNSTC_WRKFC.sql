--------------------------------------------------------
--  DDL for Package Body HRI_APL_DGNSTC_WRKFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_DGNSTC_WRKFC" AS
/* $Header: hriadgwf.pkb 120.14 2006/12/05 09:24:37 smohapat noship $ */

-- Returns a list of continuous periods by salary currency
-- where the conversion rate for primary/secondary currency
-- is missing
FUNCTION get_missing_rates_sql(p_parameter_value   IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_sql_stmt        VARCHAR2(32000);
  l_rate_type_code  VARCHAR2(240);
  l_currency_code   VARCHAR2(240);

BEGIN

  IF (p_parameter_value = 'PRIMARY') THEN
    l_rate_type_code := fnd_profile.value('BIS_PRIMARY_RATE_TYPE');
    l_currency_code  := fnd_profile.value('BIS_PRIMARY_CURRENCY_CODE');
  ELSE
    l_rate_type_code := fnd_profile.value('BIS_SECONDARY_RATE_TYPE');
    l_currency_code  := fnd_profile.value('BIS_SECONDARY_CURRENCY_CODE');
  END IF;

  l_sql_stmt :=
'SELECT -- Missing conversion rates
 cur.from_currency      from_currency
,''' || l_currency_code || '''                  to_currency
,cal.id                 start_date
-- End date is one day before next conversion rate exists
-- or period end date
,(SELECT NVL(MIN(rate.conversion_date) - 1, :p_end_date)
  FROM gl_daily_rates rate
  WHERE rate.to_currency = ''' || l_currency_code || '''
  AND rate.from_currency = cur.from_currency
  AND rate.conversion_date > cal.id)
                        end_date
,null                   col5
FROM
 fii_time_day_v  cal
,(SELECT DISTINCT
   pet.input_currency_code  from_currency
  FROM
   per_pay_bases            ppb
  ,pay_input_values_f       piv
  ,pay_element_types_f      pet
  WHERE ppb.input_value_id = piv.input_value_id
  AND piv.element_type_id = pet.element_type_id
  AND trunc(SYSDATE) BETWEEN piv.effective_start_date
                     AND piv.effective_end_date
  AND trunc(SYSDATE) BETWEEN pet.effective_start_date
                     AND pet.effective_end_date
  AND pet.input_currency_code <> ''' || l_currency_code || '''
 ) cur
WHERE cal.id BETWEEN :p_start_date
             AND :p_end_date
-- No conversion rate exists
AND NOT EXISTS
 (SELECT null
  FROM gl_daily_rates  rate
  WHERE rate.to_currency = ''' || l_currency_code || '''
  AND rate.from_currency = cur.from_currency
  AND rate.conversion_type = ''' || l_rate_type_code || '''
  AND rate.conversion_date = cal.id)
-- Filter out consecutive days where no conversion rate exists
AND (cal.id = :p_start_date
  OR EXISTS
   (SELECT null
    FROM gl_daily_rates  rate
    WHERE rate.to_currency = ''' || l_currency_code || '''
    AND rate.from_currency = cur.from_currency
    AND rate.conversion_type = ''' || l_rate_type_code || '''
    AND rate.conversion_date = cal.id - 1))
ORDER BY 1,3';

  RETURN l_sql_stmt;

END get_missing_rates_sql;

-- Returns currently active users whose linked employees are
-- not in the supervisor hierarchy
FUNCTION get_user_not_in_suph
    RETURN VARCHAR2 IS

  l_sql_stmt   VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 usr.user_name
,usr.start_date
,null col3
,null col4
,null col5
FROM
 fnd_user                  usr
,wf_user_role_assignments  waur
,wf_local_roles            wlr
,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
AND resp.responsibility_key in (''HR_LINE_MANAGER'',''DAILY_HR_INTELLIGENCE'')
AND wlr.orig_system = ''FND_RESP''
AND usr.user_name = waur.user_name
AND waur.role_name = wlr.name
AND usr.employee_id IS NOT NULL
AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date,hr_general.end_of_time)
AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)
AND NOT EXISTS
 (SELECT null
  FROM hri_cs_suph sup
  WHERE sup.sub_person_id = usr.employee_id)';

  RETURN l_sql_stmt;

END get_user_not_in_suph;

-- Returns currently active users who do not have a linked employee
FUNCTION get_user_unassigned
    RETURN VARCHAR2 IS

  l_sql_stmt   VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 usr.user_name
,usr.start_date
,null col3
,null col4
,null col5
FROM
 fnd_user                  usr
,wf_user_role_assignments  waur
,wf_local_roles            wlr
,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
AND resp.responsibility_key IN (''HR_LINE_MANAGER'',''DAILY_HR_INTELLIGENCE'')
AND wlr.orig_system = ''FND_RESP''
AND usr.user_name = waur.user_name
AND waur.role_name = wlr.name
AND usr.employee_id IS NULL
AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date,hr_general.end_of_time)
AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)';

  RETURN l_sql_stmt;

END get_user_unassigned;

-- CWKs who do not have a primary assignment with a projected end date
FUNCTION get_no_asg_proj_end_date
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(per) */ DISTINCT
 per.full_name
,pop.date_start
,per.npw_number
,bgr.name  business_group_name
,NULL col5
FROM
 per_all_assignments_f        asg
,per_all_people_f             per
,per_periods_of_placement     pop
,per_assignment_status_types  ast
,hr_all_organization_units_tl bgr
WHERE asg.effective_end_date >= :p_start_date
AND asg.effective_start_date <= :p_end_date
AND per.person_id = asg.person_id
AND pop.person_id = asg.person_id
AND asg.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
AND asg.effective_start_date BETWEEN per.effective_start_date
                             AND per.effective_end_date
AND asg.assignment_type = ''C''
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND ast.per_system_status <>  ''TERM_ASSIGN''
AND NOT EXISTS
 (SELECT null
  FROM per_all_assignments_f asg1
  WHERE asg1.person_id = asg.person_id
  AND asg1.primary_flag = ''Y''
  AND asg1.projected_assignment_end IS NOT NULL)
ORDER BY 4, 1, 2';

  RETURN l_sql_stmt;

END get_no_asg_proj_end_date;

-- Count of secondary assignments by person type
-- Include all assignments in period
FUNCTION get_mul_asg_breakup
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(per) */
 ppt.user_person_type
,count(*) total
,NULL col3
,NULL col4
,NULL col5
FROM
 per_all_assignments_f asg
,per_all_people_f per
,per_assignment_status_types ast
,per_person_type_usages_f ppu
,per_person_types ppt
WHERE asg.effective_end_date >= :p_start_date
AND asg.effective_start_date <= :p_end_date
AND per.person_id = asg.person_id
AND GREATEST(asg.effective_start_date, :p_start_date)
  BETWEEN per.effective_start_date AND per.effective_end_date
AND asg.primary_flag = ''N''
AND asg.assignment_type IN (''E'', ''C'')
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND ast.per_system_status NOT IN (''TERM_ASSIGN'')
AND GREATEST(asg.effective_start_date, :p_start_date)
  BETWEEN ppu.effective_start_date AND ppu.effective_end_date
AND per.person_id = ppu.person_id
AND ppu.person_type_id = ppt.person_type_id
AND ppt.system_person_type IN (''EMP'', ''CWK'', ''EX_EMP'', ''EX_CWK'')
GROUP BY ppt.user_person_type';

  RETURN l_sql_stmt;

END get_mul_asg_breakup;

-- Total headcount by supervisor as of end date
FUNCTION get_total_hd
     RETURN VARCHAR2 IS

  l_sql_stmt       VARCHAR2(32000);
  l_wmv_type_code  VARCHAR2(30);
  l_wmv_type       VARCHAR2(240);

BEGIN

  -- Get the abv type
  l_wmv_type_code := fnd_profile.value('BIS_WORKFORCE_MEASUREMENT_TYPE');

  -- Default to headcount
  IF l_wmv_type_code IS NULL THEN
    l_wmv_type_code := 'HEAD';
  END IF;

  -- Lookup the type
  l_wmv_type := hr_bis.bis_decode_lookup('BUDGET_MEASUREMENT_TYPE', l_wmv_type_code);

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(suph) */
 per.full_name person
,''' || REPLACE(l_wmv_type, '''', '''''') || '''  abv_unit
,SUM(hri_bpl_abv.calc_abv
      (asg.assignment_id
      ,asg.business_group_id
      ,''' || l_wmv_type_code || '''
      ,:p_end_date
      ,asg.primary_flag
      ,NULL) ) abv
,suph.sup_level suplevel
,NULL col5
FROM
 per_all_people_f per
,hri_cs_suph suph
,per_all_assignments_f asg
,per_assignment_status_types  ast
WHERE :p_end_date BETWEEN suph.effective_start_date
                  AND suph.effective_end_date
AND asg.assignment_type IN (''E'', ''C'')
AND asg.supervisor_id = suph.sub_person_id
AND per.person_id = suph.sup_person_id
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND ast.per_system_status <> ''TERM_ASSIGN''
AND :p_end_date BETWEEN asg.effective_start_date
                AND asg.effective_end_date
AND :p_end_date BETWEEN per.effective_start_date
                AND per.effective_end_date
GROUP BY
 per.full_name
,suph.sup_level
ORDER BY suph.sup_level, 1';

  RETURN l_sql_stmt;

END get_total_hd;

-- Count of current users who are assigned HR DBI responsibilities
FUNCTION get_user_valid_setup
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT count(*)
FROM
 fnd_user                  usr
,wf_user_role_assignments  waur
,wf_local_roles            wlr
,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
AND resp.responsibility_key IN (''HR_LINE_MANAGER'', ''DAILY_HR_INTELLIGENCE'')
AND wlr.orig_system = ''FND_RESP''
AND usr.user_name = waur.user_name
AND waur.role_name = wlr.name
AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date, hr_general.end_of_time)
AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)';

  RETURN l_sql_stmt;

END get_user_valid_setup;

-- Total salaries by supervisor as at end date
FUNCTION get_total_sal
     RETURN VARCHAR2 IS

  l_sql_stmt       VARCHAR2(32000);
  l_currency_name  VARCHAR2(240);
  l_currency_code  VARCHAR2(240);
  l_rate_type      VARCHAR2(80);

  CURSOR currency_csr IS
  SELECT name meaning
  FROM fnd_currencies_active_v
  WHERE currency_code = bis_common_parameters.get_currency_code;

BEGIN

  -- Get currency name
  OPEN currency_csr;
  FETCH currency_csr INTO l_currency_name;
  CLOSE currency_csr;

  -- Get currency code and rate type
  l_currency_code := bis_common_parameters.get_currency_code;
  l_rate_type := bis_common_parameters.get_rate_type;

  l_sql_stmt :=
'SELECT
 per.full_name person
,''' || REPLACE(l_currency_name, '''', '''''') || '''   currency
,SUM(hri_bpl_sal.convert_amount
      (sal.currency_code
      ,''' || l_currency_code || '''
      ,:p_end_date
      ,sal.salary
      ,''' || l_rate_type || '''))  total_salary
,sal.sup_level suplevel
,NULL col5
FROM
 (SELECT /*+ use_hash(pro asg) parallel(pro) parallel(asg) parallel(suph)*/
   suph.sup_person_id
  ,CASE WHEN ppb.pay_annualization_factor IS NULL AND
             ppb.pay_basis = ''PERIOD''
        THEN pro.proposed_salary_n * hri_bpl_sal.get_perd_annualization_factor
                                      (asg.assignment_id, pro.change_date)
         ELSE pro.proposed_salary_n * ppb.pay_annualization_factor
   END salary
  ,pro.change_date change_date
  ,NVL(pro.pay_proposal_id, -1) pay_proposal_id
  ,NVL(pet.input_currency_code, ''NA_EDW'') currency_code
  ,asg.assignment_id
  ,suph.sup_level
  FROM
   per_all_assignments_f asg
  ,per_assignment_status_types ast
  ,per_pay_bases ppb
  ,per_pay_proposals pro
  ,pay_input_values_f piv
  ,pay_element_types_f pet
  ,hri_cs_suph suph
  WHERE pro.approved = ''Y''
  AND :p_end_date BETWEEN suph.effective_start_date
                  AND suph.effective_end_date
  AND asg.supervisor_id = suph.sub_person_id
  AND :p_end_date BETWEEN asg.effective_start_date
                  AND asg.effective_end_date
  AND asg.assignment_type = ''E''
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status <> ''TERM_ASSIGN''
  AND asg.assignment_id = pro.assignment_id
  AND asg.pay_basis_id = ppb.pay_basis_id
  AND ppb.input_value_id = piv.input_value_id
  AND piv.element_type_id = pet.element_type_id
  AND pro.change_date BETWEEN piv.effective_start_date
                      AND piv.effective_end_date
  AND pro.change_date BETWEEN pet.effective_start_date
                      AND pet.effective_end_date
  AND pro.change_date =
   (SELECT max(pro2.change_date)
    FROM per_pay_proposals pro2
    WHERE pro2.assignment_id = pro.assignment_id
    AND pro2.change_date <= :p_end_date
    AND pro2.approved = ''Y'' )
 ) sal
 ,per_all_people_f per
WHERE per.person_id = sal.sup_person_id
AND :p_end_date BETWEEN per.effective_start_date
                AND per.effective_end_date
GROUP BY
 per.full_name
,sal.sup_level
ORDER BY sal.sup_level, 1';

  RETURN l_sql_stmt;

END get_total_sal;


-- Employees who have no reviews in the period
FUNCTION get_no_review
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 per.full_name
,norev.effective_start_date
,norev.effective_end_date
,per.employee_number
,bgr.name  business_group_name
FROM
 per_all_people_f per
,hr_all_organization_units_tl  bgr
,(SELECT /*+ parallel(pos) parallel(ppr) parallel(papp) */
   pos.person_id
  ,pos.date_start effective_start_date
  ,least(NVL(min(ppr.review_date - 1)
            ,NVL(pos.actual_termination_date
                 ,hr_general.end_of_time))
        ,NVL(min(decode(papp.open, ''N'', papp.appraisal_date - 1, null))
            , NVL(pos.actual_termination_date
                 ,hr_general.end_of_time)))  effective_end_date
  FROM
   per_periods_of_service pos
  ,per_performance_reviews ppr
  ,per_appraisals papp
  WHERE NVL(pos.actual_termination_date, hr_general.end_of_time) >= :p_start_date
  AND pos.date_start <= :p_end_date
  AND pos.person_id = ppr.person_id (+)
  AND pos.person_id = papp.appraisee_person_id(+)
  GROUP BY
   pos.person_id
  ,pos.date_start
  ,pos.actual_termination_date
  HAVING NVL(min(ppr.review_date), hr_general.end_of_time) >
         greatest(pos.date_start, :p_start_date)
  AND NVL(min(decode(papp.open, ''N'',  papp.appraisal_date,  null))
         ,hr_general.end_of_time) >
      greatest(pos.date_start, :p_start_date)
 ) norev
WHERE norev.person_id = per.person_id
AND per.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
AND norev.effective_start_date BETWEEN per.effective_start_date
                               AND per.effective_end_date
AND norev.effective_end_date >= :p_end_date
ORDER BY 5, 1, 2';

  RETURN l_sql_stmt;

END get_no_review;

-- Total assignments as of period end
FUNCTION get_total_asg
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) */
 count(*) total
FROM
 per_all_assignments_f asg
,per_assignment_status_types ast
WHERE :p_end_date BETWEEN asg.effective_start_date
                  AND asg.effective_end_date
AND asg.assignment_type IN (''E'', ''C'')
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND ast.per_system_status <> ''TERM_ASSIGN''';

  RETURN l_sql_stmt;

END get_total_asg;

-- Total assignments grouped by assignment type
FUNCTION get_total_asg_by_asgtype
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) */
 hr_bis.bis_decode_lookup(''EMP_APL'', asg.assignment_type)  meaning
,count(*) total
,null col3
,null col4
,null col5
FROM
 per_all_assignments_f asg
,per_assignment_status_types ast
WHERE :p_end_date BETWEEN asg.effective_start_date
                  AND asg.effective_end_date
AND asg.assignment_type IN (''E'', ''C'')
AND asg.assignment_status_type_id = ast.assignment_status_type_id
AND ast.per_system_status <> ''TERM_ASSIGN''
GROUP BY
 asg.assignment_type';

  RETURN l_sql_stmt;

END get_total_asg_by_asgtype;

-- Assignments with no supervisor within period
FUNCTION get_no_sprvsr
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(per) */
 per.full_name person
,asg.effective_start_date start_date
,asg.effective_end_date end_date
,asg.assignment_number
,bgr.name    business_group_name
FROM
 per_all_assignments_f asg
,per_all_people_f per
,hr_all_organization_units_tl  bgr
WHERE asg.effective_end_date >= :p_start_date
AND asg.effective_start_date <= :p_end_date
AND asg.assignment_type IN (''E'', ''C'')
AND asg.supervisor_id IS NULL
AND asg.person_id = per.person_id
AND asg.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
AND asg.effective_start_date BETWEEN per.effective_start_date
                             AND per.effective_end_date
ORDER BY 5, 1, 2';

  RETURN l_sql_stmt;

END get_no_sprvsr;

-- Secondary assignments in period
FUNCTION get_mul_asg
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 inner_q.person person
,min(inner_q.start_date) start_date
,max(inner_q.end_date) end_date
,inner_q.assignment_number assignment_number
,null col4
,null col5
FROM
 (SELECT /*+ parallel(asg) parallel(per) */
   per.full_name person
  ,asg.effective_start_date start_date
  ,asg.effective_end_date end_date
  ,asg.assignment_number assignment_number
  FROM
   per_all_assignments_f asg
  ,per_all_people_f per
  ,per_assignment_status_types ast
  WHERE asg.effective_end_date >= :p_start_date
  AND asg.effective_start_date <= :p_end_date
  AND per.person_id = asg.person_id
  AND asg.effective_start_date BETWEEN per.effective_start_date
                               AND per.effective_end_date
  AND asg.primary_flag = ''N''
  AND asg.assignment_type IN (''E'', ''C'')
  AND asg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status <>  ''TERM_ASSIGN''
 ) inner_q
GROUP BY
 inner_q.assignment_number
,inner_q.person
ORDER BY 1, 2';

  RETURN l_sql_stmt;

END get_mul_asg;

-- Terminated supervisors in period
FUNCTION get_term_sprvsr
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(per) parallel(sup_service) */
 per.full_name person
,greatest(sup_service.actual_termination_date + 1
         ,asg.effective_start_date) termination_date
,asg.effective_end_date end_date
,asg.assignment_number
,bgr.name      business_group_name
FROM
 per_all_assignments_f asg
,per_periods_of_service sup_service
,per_all_people_f per
,per_assignment_status_types  ast
,hr_all_organization_units_tl  bgr
WHERE asg.assignment_type IN (''E'', ''C'')
AND asg.supervisor_id = sup_service.person_id
AND sup_service.actual_termination_date < asg.effective_end_date
AND asg.person_id = per.person_id
AND asg.effective_start_date BETWEEN per.effective_start_date
                             AND per.effective_end_date
AND asg.effective_end_date >= :p_start_date
AND sup_service.actual_termination_date + 1 <= :p_end_date
AND asg.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
AND ast.assignment_status_type_id = asg.assignment_status_type_id
AND ast.per_system_status <> ''TERM_ASSIGN''
ORDER BY 5, 1, 2';

  RETURN l_sql_stmt;

END get_term_sprvsr;

-- Employees with no salary
FUNCTION get_no_sal
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ INDEX(per) INDEX(bgr) */
 per.full_name     person_name
,no_sal.asg_start  effective_start_date
,NVL(no_sal.earliest_salary, no_sal.asg_end)
                   effective_end_date
,no_sal.assignment_number
,bgr.name          business_group_name
FROM
 per_all_people_f per
,hr_all_organization_units_tl  bgr
,(SELECT /*+ NO_MERGE */
   asg.assignment_id
  ,asg.business_group_id
  ,asg.person_id
  ,asg.assignment_number
  ,MIN(ppp.change_date) earliest_salary
  ,MIN(asg.effective_start_date)  asg_start
  ,pos.actual_termination_date    asg_end
  FROM
   per_periods_of_service pos
  ,per_all_assignments_f  asg
  ,per_pay_proposals      ppp
  WHERE asg.assignment_type = ''E''
  AND pos.period_of_service_id = asg.period_of_service_id
  AND asg.effective_start_date >= pos.date_start
  AND asg.assignment_id = ppp.assignment_id (+)
  AND asg.effective_start_date <= ppp.change_date (+)
  AND ppp.approved (+) = ''Y''
  AND pos.date_start <= :p_end_date
  AND NVL(pos.actual_termination_date, :p_start_date) >= :p_start_date
  GROUP BY
   asg.assignment_id
  ,asg.business_group_id
  ,asg.person_id
  ,asg.assignment_number
  ,pos.actual_termination_date
  HAVING (MIN(ppp.change_date) > MIN(asg.effective_start_date) OR
          MIN(ppp.change_date) IS NULL))  no_sal
WHERE no_sal.person_id = per.person_id
AND TRUNC(SYSDATE) BETWEEN per.effective_start_date
                   AND per.effective_end_date
AND no_sal.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
ORDER BY 5, 1, 2';

  RETURN l_sql_stmt;

END get_no_sal;

-- People with headcount or fte > 1
FUNCTION get_dbl_cnt_abv
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ INDEX(per per_people_f_pk) */
 per.full_name
,MIN(dbl_cnt.effective_date)   START_DATE
,MAX(dbl_cnt.effective_date)   END_DATE
,NVL(employee_number, npw_number)  emp_or_cwk_number
,bgr.name       business_group_name
--,per.person_id
FROM
 per_all_people_f  per
,hr_all_organization_units_tl  bgr
,(SELECT
   evt.person_id
  ,SUM(evt.headcount)   headcount
  ,SUM(evt.fte)         fte
  ,tab.effective_date
  FROM
   hri_mb_asgn_events_ct  evt
  ,(SELECT /*+ NO_MERGE */ DISTINCT
     person_id
    ,CASE WHEN effective_change_date < :p_start_date
          THEN :p_start_date
          ELSE effective_change_date
     END             effective_date
    FROM hri_mb_asgn_events_ct evt_date
    WHERE
       (:p_start_date BETWEEN effective_change_date AND effective_change_end_date
     OR (effective_change_date BETWEEN :p_start_date AND :p_end_date AND
          (worker_hire_ind = 1
        OR post_hire_asgn_start_ind = 1
        OR fte_gain_ind = 1
        OR fte_loss_ind = 1
        OR headcount_gain_ind = 1
        OR headcount_loss_ind = 1)))
    AND worker_term_ind = 0
    AND pre_sprtn_asgn_end_ind = 0
    UNION ALL
    SELECT DISTINCT
     person_id
    ,:p_end_date
    FROM
     hri_mb_asgn_events_ct
    WHERE :p_end_date > effective_change_date
    AND :p_end_date <= effective_change_end_date
    AND worker_term_ind = 0
    AND pre_sprtn_asgn_end_ind = 0
   )  tab
  WHERE evt.person_id = tab.person_id
  AND tab.effective_date BETWEEN evt.effective_change_date
                         AND evt.effective_change_end_date
  GROUP BY
   evt.person_id
  ,tab.effective_date
  HAVING
   SUM(evt.headcount) > 1 OR SUM(evt.fte) > 1
 ) dbl_cnt
WHERE dbl_cnt.person_id = per.person_id
AND per.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
AND TRUNC(SYSDATE) BETWEEN per.effective_start_date
                   AND per.effective_end_date
GROUP BY
 bgr.name
,per.full_name
,employee_number
,npw_number
,per.person_id
ORDER BY 5, 1, 2';

  RETURN l_sql_stmt;

END get_dbl_cnt_abv;

-- Obsolete
FUNCTION get_smlt_abv
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);
  l_abv_unit  VARCHAR2(240);

BEGIN

  -- Get the abv type
  l_abv_unit := fnd_profile.value('BIS_WORKFORCE_MEASUREMENT_TYPE');

  -- Default to headcount
  IF l_abv_unit IS NULL THEN
    l_abv_unit := 'HEAD';
  END IF;

  l_sql_stmt :=
'SELECT /*+ parallel(per) */ DISTINCT
 per.full_name person
,abv.effective_start_date start_date
,least(abv.effective_end_date
      ,abv2.effective_end_date) end_date
,null col3
,null col4
,null col5
FROM
 per_assignment_budget_values_f abv
,per_all_assignments_f asg
,per_all_people_f per
,per_all_assignments_f asg2
,per_assignment_budget_values_f abv2
WHERE NOT (least(abv.effective_end_date
          ,abv2.effective_end_date)<:p_start_date
       OR abv.effective_start_date>:p_end_date)
AND abv.unit = ''' || l_abv_unit || '''
AND asg.assignment_id = abv.assignment_id
AND abv.effective_start_date BETWEEN asg.effective_start_date
                             AND asg.effective_end_date
AND asg.assignment_type IN (''E'', ''C'')
AND per.person_id = asg.person_id
AND asg.effective_start_date BETWEEN per.effective_start_date
                             AND per.effective_end_date
AND asg2.assignment_type IN (''E'', ''C'')
AND abv2.unit = ''' || l_abv_unit || '''
AND asg2.assignment_id = abv2.assignment_id
AND abv2.effective_start_date BETWEEN asg2.effective_start_date
                              AND asg2.effective_end_date
AND asg.person_id = asg2.person_id
AND asg.assignment_id <> asg2.assignment_id
AND abv.effective_start_date BETWEEN abv2.effective_start_date
                             AND abv2.effective_end_date
ORDER BY 1, 2, 3';

  RETURN l_sql_stmt;

END get_smlt_abv;

-- Obsolete
FUNCTION get_no_abv
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);
  l_abv_unit  VARCHAR2(240);

BEGIN

  -- Get the abv type
  l_abv_unit := fnd_profile.value('BIS_WORKFORCE_MEASUREMENT_TYPE');

  -- Default to headcount
  IF l_abv_unit IS NULL THEN
    l_abv_unit := 'HEAD';
  END IF;

  l_sql_stmt :=
'SELECT /*+ parallel(per)*/
 per.full_name person
,noabv_duration.noabv_starts
,noabv_duration.noabv_ends
,noabv_duration.assignment_number
,null col3
,null col4
FROM
 (SELECT /*+ parallel(asg) parallel(abv) */
   asg.person_id
  ,asg.assignment_number
  ,CASE WHEN LEAD(abv.effective_start_date, 1) OVER
              (PARTITION BY abv.assignment_id
               ORDER BY abv.effective_start_date) IS NULL
        THEN abv.effective_end_date+1
        WHEN LEAD(abv.effective_start_date, 1) OVER
              (PARTITION BY abv.assignment_id
               ORDER BY abv.effective_start_date) <>
                       abv.effective_end_date + 1
        THEN abv.effective_end_date+1
   END noabv_starts
  ,CASE WHEN LEAD(abv.effective_start_date, 1) OVER
              (PARTITION BY abv.assignment_id
               ORDER BY abv.effective_start_date) <>
                       abv.effective_end_date + 1
        THEN LEAD(abv.effective_start_date, 1) OVER
              (PARTITION BY abv.assignment_id
               ORDER BY abv.effective_start_date)-1
        WHEN LEAD(abv.effective_start_date, 1) OVER
              (PARTITION BY abv.assignment_id
               ORDER BY abv.effective_start_date) IS NULL
             AND abv.effective_end_date =
              (SELECT max(asg2.effective_end_date)
               FROM per_all_assignments_f asg2
               WHERE asg2.assignment_id = abv.assignment_id)
        THEN null
        ELSE (SELECT max(asg2.effective_end_date)
              FROM per_all_assignments_f asg2
              WHERE asg2.assignment_id = abv.assignment_id)
   END noabv_ends
  FROM
   per_assignment_budget_values_f abv
  ,per_all_assignments_f asg
  WHERE abv.unit = ''' || l_abv_unit || '''
  AND abv.assignment_id = asg.assignment_id
  AND abv.effective_start_date BETWEEN asg.effective_start_date
  AND asg.effective_end_date
  UNION
  SELECT
   asg_start.person_id
  ,asg_start.assignment_number
  ,asg_start.noabv_starts
  ,NVL(abv_start.start_date-1, asg_start.no_abv_ends)
  FROM
   (SELECT /*+ parallel(assg) */
     assg.person_id
    ,assg.assignment_id
    ,assg.assignment_number
    ,min(assg.effective_start_date) noabv_starts
    ,max(assg.effective_end_date) no_abv_ends
    FROM
     per_all_assignments_f assg
    GROUP BY
     assg.assignment_id
    ,assg.person_id
    ,assg.assignment_number
   ) asg_start
  ,(SELECT /*+ parallel(abv) */
     abv.assignment_id
    ,min(abv.effective_start_date) start_date
    FROM per_assignment_budget_values_f abv
    WHERE abv.unit = ''' || l_abv_unit || '''
    GROUP BY abv.assignment_id
   ) abv_start
  WHERE asg_start.assignment_id = abv_start.assignment_id(+)
  AND (asg_start.noabv_starts < abv_start.start_date
    OR abv_start.start_date IS NULL)
 ) noabv_duration
,per_all_people_f per
WHERE per.person_id = noabv_duration.person_id
AND noabv_duration.noabv_starts BETWEEN per.effective_start_date
                                AND per.effective_end_date
AND NOT (noabv_duration.noabv_ends<:p_start_date
      OR noabv_duration.noabv_starts>:p_end_date)
ORDER BY 1, 2, 3';

  RETURN l_sql_stmt;

END get_no_abv;

-- Employee separations with no leaving reason
FUNCTION get_no_term_rsn
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(pps) parallel(per) parallel(assg) */
 per.full_name person
,pps.actual_termination_date termination_date
,per.employee_number
,bgr.name   business_group_name
,null col5
FROM
 per_periods_of_service pps
,per_all_people_f per
,per_all_assignments_f assg
,hr_all_organization_units_tl  bgr
WHERE pps.actual_termination_date <= :p_end_date
AND pps.actual_termination_date + 1 >= :p_start_date
AND pps.person_id = per.person_id
AND pps.actual_termination_date+1 BETWEEN per.effective_start_date
                                  AND per.effective_end_date
AND pps.leaving_reason IS NULL
AND per.person_id = assg.person_id
AND assg.effective_end_date = pps.actual_termination_date
AND assg.assignment_type IN (''E'', ''C'')
AND assg.primary_flag = ''Y''
AND assg.business_group_id = bgr.organization_id
AND bgr.language = USERENV(''LANG'')
ORDER BY 4, 1, 2';

  RETURN l_sql_stmt;

END get_no_term_rsn;

-- Diagnose supervisor loops
FUNCTION get_sup_loop_details
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'set serveroutput on
DECLARE

  TYPE sup_cache_tab_type IS TABLE OF VARCHAR2(30)
                          INDEX BY BINARY_INTEGER;

  CURSOR sup_csr(p_psn_id   NUMBER,
                 p_date     DATE) IS
  SELECT
   sub.full_name       sub_person_name
  ,NVL(sub.employee_number, sub.npw_number)
                       sub_emp_cwk_number
  ,sup.full_name       sup_person_name
  ,NVL(sup.employee_number, sup.npw_number)
                       sup_emp_cwk_number
  ,assg.supervisor_id  supervisor_id
  FROM
   per_all_assignments_f        assg
  ,per_assignment_status_types  ast
  ,per_people_x                 sup
  ,per_people_x                 sub
  WHERE assg.person_id = p_psn_id
  AND p_date BETWEEN assg.effective_start_date
             AND assg.effective_end_date
  AND assg.assignment_status_type_id = ast.assignment_status_type_id
  AND ast.per_system_status <> ''TERM_ASSIGN''
  AND assg.primary_flag = ''Y''
  AND assg.assignment_type IN (''E'',''C'')
  AND assg.person_id = sub.person_id
  AND assg.supervisor_id = sup.person_id;

  l_sup_cache           sup_cache_tab_type;
  exit_loop             BOOLEAN;
  l_person_id           NUMBER;
  l_effective_date      DATE;
  l_supervisor_id       NUMBER;
  l_person_name         VARCHAR2(240);
  l_person_number       VARCHAR2(240);
  l_supervisor_name     VARCHAR2(240);
  l_supervisor_number   VARCHAR2(240);

BEGIN

  -- Loop variable - will be set to true when a loop is encountered
  --                 or when the end of the supervisor chains is reached
  exit_loop := FALSE;

  -- Person to sample manager of
  l_person_id := :person_id;
  l_effective_date := :effective_date;

  -- Update cache for encountering this person
  l_sup_cache(l_person_id) := ''Y'';

  -- Loop through supervisor levels
  WHILE NOT exit_loop LOOP

    -- Fetch supervisor details for current person
    OPEN sup_csr(l_person_id, l_effective_date);
    FETCH sup_csr INTO
      l_person_name,
      l_person_number,
      l_supervisor_name,
      l_supervisor_number,
      l_supervisor_id;

    -- If no rows are returned then exit the loop
    IF (sup_csr%NOTFOUND OR sup_csr%NOTFOUND IS NULL) THEN
      l_person_id := NULL;

    -- Otherwise set next supervisor id and output current link
    ELSE
      l_person_id := l_supervisor_id;

      -- Output link in supervisor chain
      dbms_output.put_line(l_person_name    || '' ('' ||
                           l_person_number || '') -> '' ||
                           l_supervisor_name    || '' ('' ||
                           l_supervisor_number || '')'');
    END IF;

    CLOSE sup_csr;

    -- Trap no data found when cache is tested for a new person
    BEGIN
      -- Exit loop if no supervisor or a repeated supervisor
      IF (l_person_id IS NULL) THEN
        exit_loop := TRUE;
      ELSIF (l_sup_cache(l_person_id) = ''Y'') THEN
        exit_loop := TRUE;
      ELSE
        RAISE NO_DATA_FOUND;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      l_sup_cache(l_person_id) := ''Y'';
    END;

  END LOOP;

END;
/';



  RETURN l_sql_stmt;

END get_sup_loop_details;

-- Find Incomplete Request Sets
FUNCTION get_incomplete_req_sets
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT user_request_set_name,
       description,
       null col3,
       null col4,
       null col5
FROM fnd_request_sets_vl
WHERE request_set_name IN (
  SELECT request_set_name
  FROM bis_request_set_objects obj
  WHERE obj.object_name IN (SELECT object_name
                    FROM bis_obj_properties
                    WHERE object_name like ''HRI%''
                    AND object_type = ''PAGE''
                    AND implementation_flag = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_DBI'') = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_OBIEE'')= ''Y''
                    UNION ALL
                    SELECT object_name
                    FROM bis_obj_properties
                    WHERE object_name like ''HRI%SUBJECTAREA''
                    AND object_type = ''REPORT''
                    AND implementation_flag = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_OBIEE'')= ''Y'')
  GROUP BY obj.request_set_name
  HAVING COUNT(*) < (SELECT COUNT(*)
                     FROM bis_obj_properties
                     WHERE implementation_flag = ''Y''
                     AND object_name IN (SELECT object_name
                    FROM bis_obj_properties
                    WHERE object_name like ''HRI%''
                    AND object_type = ''PAGE''
                    AND implementation_flag = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_DBI'') = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_OBIEE'')= ''Y''
                    UNION ALL
                    SELECT object_name
                    FROM bis_obj_properties
                    WHERE object_name like ''HRI%SUBJECTAREA''
                    AND object_type = ''REPORT''
                    AND implementation_flag = ''Y''
                    AND fnd_profile.value(''HRI_IMPL_OBIEE'')= ''Y'')
                    )
   )'

;

  RETURN l_sql_stmt;

END get_incomplete_req_sets;


-- Find Vacancies without Managers
FUNCTION get_vac_wtht_mngrs
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT vac.name
       ,vac.description
       ,vac.date_from
       ,vac.date_to
       ,null col5
 FROM per_all_vacancies vac,
      per_requisitions prq
 WHERE vac.requisition_id = prq.requisition_id
   AND vac.manager_id IS NULL
   AND DECODE(fnd_profile.value(''HRI_REC_USE_PUI_MGR_KEYS''),''Y'',vac.recruiter_id) IS NULL
   AND DECODE(fnd_profile.value(''HRI_REC_USE_PUI_MGR_KEYS''),''Y'',prq.person_id) IS NULL
   AND hri_bpl_ccmgr.get_ccmgr_id(vac.organization_id) = -1
   AND hri_bpl_ccmgr.get_ccmgr_id(vac.business_group_id) = -1
   AND vac.date_from >= :p_start_date
   AND NVL(vac.date_to, trunc(sysdate)) <= :p_end_date
 ORDER BY 1';

  RETURN l_sql_stmt;

END get_vac_wtht_mngrs;

-- Find Applicants not associated with any vacancy
FUNCTION get_applcnt_wtht_vac
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ parallel(asg) parallel(per) */
    per.full_name person
   ,asg.effective_start_date start_date
   ,asg.effective_end_date end_date
   ,bgr.name    business_group_name
   ,null col5
 FROM per_all_assignments_f asg
     ,per_all_people_f per
     ,hr_all_organization_units_tl  bgr
     ,per_applications apl
WHERE asg.assignment_type = ''A''
  AND asg.vacancy_id IS NULL
  AND asg.person_id = per.person_id
  AND asg.business_group_id = bgr.organization_id
  AND bgr.language = USERENV(''LANG'')
  AND asg.effective_start_date BETWEEN per.effective_start_date
                             AND per.effective_end_date
  AND asg.application_id = apl.application_id
  AND apl.date_received >= :p_start_date
  AND NVL(apl.date_end, trunc(sysdate)) <= :p_end_date
ORDER BY 4, 1, 2';

  RETURN l_sql_stmt;

END get_applcnt_wtht_vac;


-- Find USERS who have the ability to access PRODUCT
-- through the Line Manager responsibility but are not assigned to any user

FUNCTION get_user_linemgr_info
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT usr.user_name
       ,null col2
       ,null col3
       ,null col4
       ,null col5
FROM
   fnd_user                  usr
  ,wf_user_role_assignments  waur
  ,wf_local_roles            wlr
  ,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
  AND resp.responsibility_key = ''HRI_OBI_ALL_MGRH''
  AND wlr.orig_system = ''FND_RESP''
  AND usr.user_name = waur.user_name
  AND waur.role_name = wlr.name
  AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date, hr_general.end_of_time)
  AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)
  AND usr.employee_id IS NULL';

  RETURN l_sql_stmt;

END get_user_linemgr_info;


-- Find Users who have the ability to access PRODUCT through
-- the Human Resource Analyst by Manager responsibility but does not have
-- the profile option HRI:HR Analyst (Manager View) Top set .

FUNCTION get_user_anlstmgr_info
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT usr.user_name
       ,null col2
       ,null col3
       ,null col4
       ,null col5
 FROM
   fnd_user                  usr
  ,wf_user_role_assignments  waur
  ,wf_local_roles            wlr
  ,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
  AND resp.responsibility_key = ''HRI_OBIEE_WRKFC_MGRH''
  AND wlr.orig_system = ''FND_RESP''
  AND usr.user_name = waur.user_name
  AND waur.role_name = wlr.name
  AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date, hr_general.end_of_time)
  AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)
  AND FND_PROFILE.VALUE_SPECIFIC(''HRI_OBIEE_WRKFC_MGRH_TOP''
                                ,usr.user_id,resp.responsibility_id
                                ,resp.application_id) IS NULL' ;

  RETURN l_sql_stmt;

END get_user_anlstmgr_info;

-- Users who have the ability to access PRODUCT through the
-- Department Manager responsibility but does not have the
-- profile option HRI:Line Manager (Organization View) Top set

FUNCTION get_user_deptmgr_info
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT usr.user_name
       ,null col2
       ,null col3
       ,null col4
       ,null col5
 FROM
   fnd_user                  usr
  ,wf_user_role_assignments  waur
  ,wf_local_roles            wlr
  ,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
  AND resp.responsibility_key = ''HRI_OBI_ALL_ORGH''
  AND wlr.orig_system = ''FND_RESP''
  AND usr.user_name = waur.user_name
  AND waur.role_name = wlr.name
  AND TRUNC(SYSDATE) BETWEEN usr.start_date
                   AND NVL(usr.end_date, hr_general.end_of_time)
  AND TRUNC(SYSDATE) BETWEEN resp.start_date
                   AND NVL(resp.end_date, hr_general.end_of_time)
  AND FND_PROFILE.VALUE_SPECIFIC(''HRI_OBI_ALL_ORGH_TOP''
                               ,usr.user_id,resp.responsibility_id
                               , resp.application_id) IS NULL' ;

  RETURN l_sql_stmt;

END get_user_deptmgr_info;

-- Users who have the ability to access PRODUCT through
-- the Human Resource Analyst by Organization responsibility but does not have
-- the profile option HRI:HR Analyst (Organization View) Top set


FUNCTION get_user_orgmgr_info
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT usr.user_name
       ,null col2
       ,null col3
       ,null col4
       ,null col5
 FROM
   fnd_user                  usr
  ,wf_user_role_assignments  waur
  ,wf_local_roles            wlr
  ,fnd_responsibility        resp
WHERE resp.responsibility_id = wlr.orig_system_id
  AND resp.responsibility_key = ''HRI_OBIEE_WRKFC_ORGH''
  AND wlr.orig_system = ''FND_RESP''
  AND usr.user_name = waur.user_name
  AND waur.role_name = wlr.name
  AND TRUNC(SYSDATE) BETWEEN usr.start_date
      AND NVL(usr.end_date, hr_general.end_of_time)
  AND TRUNC(SYSDATE) BETWEEN resp.start_date
      AND NVL(resp.end_date, hr_general.end_of_time)
  AND FND_PROFILE.VALUE_SPECIFIC(''HRI_OBIEE_WRKFC_ORGH_TOP''
                                  ,usr.user_id,resp.responsibility_id
                                  ,resp.application_id) IS NULL';

  RETURN l_sql_stmt;

END get_user_orgmgr_info;


-- Get workers with unassigned gender for a Business group

FUNCTION get_unassg_gndr_info
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT per.full_name
       ,per.effective_start_date
       ,per.effective_end_date
       ,per.employee_number
       ,org.name
FROM per_all_people_f per,
  hr_all_organization_units_tl org
WHERE per.business_group_id = org.organization_id
 AND TRUNC(sysdate) BETWEEN per.effective_start_date AND per.effective_end_date
 AND org.LANGUAGE = userenv(''LANG'')
 AND per.sex IS NULL' ;

  RETURN l_sql_stmt;

END get_unassg_gndr_info;


END hri_apl_dgnstc_wrkfc;

/
