--------------------------------------------------------
--  DDL for Package Body EDW_HR_PERSON_M_SIZING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PERSON_M_SIZING" AS
/* $Header: hriezpsn.pkb 120.1 2005/06/08 02:48:52 anmajumd noship $ */

/******************************************************************************/
/* Sets p_num_rows to the number of rows which would be collected between the */
/* given dates                                                                */
/******************************************************************************/
PROCEDURE count_source_rows( p_from_date IN  DATE,
                             p_to_date   IN  DATE,
                             p_row_count OUT NOCOPY NUMBER )
IS

  /* Selects count of rows from each union of collection view */
  CURSOR row_count_cur IS
  SELECT SUM(total)
  FROM (
    SELECT COUNT(*) total
    FROM ( SELECT DISTINCT peo.person_id
           FROM per_all_people_f peo
           ,hr_all_organization_units bgr
           WHERE peo.business_group_id = bgr.organization_id
           AND greatest( NVL(peo.last_update_date,to_date('01-01-2000','DD-MM-YYYY')),
                         NVL(bgr.last_update_date,to_date('01-01-2000','DD-MM-YYYY')))
           BETWEEN p_from_date AND p_to_date )
    UNION ALL
    SELECT  COUNT(*) total
    FROM ra_salesreps_all rs
    ,hr_all_organization_units org
    WHERE rs.org_id = org.organization_id (+)
    AND greatest( NVL( rs.last_update_date,to_date('01-01-2000','DD-MM-YYYY')),
                  NVL(org.last_update_date,to_date('01-01-2000','DD-MM-YYYY')))
    BETWEEN p_from_date AND p_to_date
    UNION ALL
    SELECT COUNT(*)
    FROM mtl_planners mp
    ,hr_all_organization_units org
    WHERE mp.organization_id = org.organization_id
    AND greatest( NVL(mp.last_update_date, to_date('01-01-2000','DD-MM-YYYY')),
                  NVL(org.last_update_date,to_date('01-01-2000','DD-MM-YYYY')))
    BETWEEN p_from_date AND p_to_date
  );

BEGIN

  OPEN row_count_cur;
  FETCH row_count_cur INTO p_row_count;
  CLOSE row_count_cur;

END count_source_rows;

/******************************************************************************/
/* Estimates row lengths. Because the union is likely to be heavily skewed    */
/* (since per_all_people_f is large and date-tracked) some attributes have    */
/* been averaged across the union to improve the accuracy of the estimation   */
/******************************************************************************/
PROCEDURE estimate_row_length( p_from_date       IN  DATE,
                               p_to_date         IN  DATE,
                               p_avg_row_length  OUT NOCOPY NUMBER )
IS

/* Used to calculate weighted average across union */
  x_peo_weight            NUMBER;
  x_ra_weight             NUMBER;
  x_mtl_weight            NUMBER;

/* Length of a date attribute */
  x_date                  NUMBER := 7;

/* Dimension attributes */
  x_assignment_pk         NUMBER := 0;
  x_business_group        NUMBER := 0;
  x_creation_date         NUMBER := x_date;
  x_end_date              NUMBER := x_date;
  x_instance              NUMBER := 0;
  x_last_update_date      NUMBER := x_date;
  x_name                  NUMBER := 0;
  x_start_date            NUMBER := x_date;
  x_national_identifier   NUMBER := 0;
  x_person_dp             NUMBER := 0;
  x_person_id             NUMBER := 0;
  x_person_num            NUMBER := 0;
  x_planner_code          NUMBER := 0;
  x_planner_flag          NUMBER := 0;
  x_previous_last_name    NUMBER := 0;
  x_region_of_birth       NUMBER := 0;
  x_rehire_rcmmndtn       NUMBER := 0;
  x_resume_exists         NUMBER := 0;
  x_resume_updated_date   NUMBER := x_date;
  x_salesrep_id           NUMBER := 0;
  x_sales_rep_flag        NUMBER := 0;
  x_student_status        NUMBER := 0;
  x_sys_gen_flag          NUMBER := 0;
  x_title                 NUMBER := 0;
  x_town_of_birth         NUMBER := 0;
  x_buyer_flag            NUMBER := 0;
  x_country_of_birth      NUMBER := 0;
  x_crrspndnc_language    NUMBER := 0;
  x_date_emp_data_vrfd    NUMBER := x_date;
  x_date_of_birth         NUMBER := x_date;
  x_disability_flag       NUMBER := 0;
  x_effective_end_date    NUMBER := x_date;
  x_effective_start_date  NUMBER := x_date;
  x_email_address         NUMBER := 0;
  x_fast_path_employee    NUMBER := 0;
  x_first_name            NUMBER := 0;
  x_fte_capacity          NUMBER := 0;
  x_full_name             NUMBER := 0;
  x_gender                NUMBER := 0;
  x_global_person_id      NUMBER := 0;
  x_internal_location     NUMBER := 0;
  x_known_as              NUMBER := 0;
  x_last_name             NUMBER := 0;
  x_mailstop              NUMBER := 0;
  x_marital_status        NUMBER := 0;
  x_middle_names          NUMBER := 0;
  x_name_prefix           NUMBER := 0;
  x_name_suffix           NUMBER := 0;
  x_nationality           NUMBER := 0;
  x_employee_flag         NUMBER := 0;
  x_applicant_flag        NUMBER := 0;
  x_salesrep_number       NUMBER := 0;
  x_salesrep_name         NUMBER := 0;
  x_salesrep_org_id       NUMBER := 0;
  x_planner_description   NUMBER := 0;
  x_planner_org_id        NUMBER := 0;


/* Selects the length of the instance code */
  CURSOR inst_cur IS
  SELECT avg(nvl(vsize(instance_code),0))
  FROM edw_local_instance;

/*************/
/* HR Source */
/*************/

/* Length of an organization name */
  CURSOR bgr_cur IS
  SELECT avg(nvl(vsize(name),0))
  FROM hr_all_organization_units
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

/* Length of person attributes - plus a count (weight) of size of table */
  CURSOR peo_cur IS
  SELECT
   avg(nvl(vsize(person_id),0))
  ,avg(nvl(vsize(last_name),0))
  ,avg(nvl(vsize(NVL(applicant_number,employee_number)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO',NVL(current_employee_flag,'N'))),0))
  ,avg(nvl(vsize(email_address),0))
  ,avg(nvl(vsize(first_name),0))
  ,avg(nvl(vsize(full_name),0))
  ,avg(nvl(vsize(known_as),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('MAR_STATUS',marital_status)),0))
  ,avg(nvl(vsize(middle_names),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('NATIONALITY',nationality)),0))
  ,avg(nvl(vsize(national_identifier),0))
  ,avg(nvl(vsize(previous_last_name),0))
  ,avg(nvl(vsize(sex),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('TITLE',title)),0))
  ,avg(nvl(vsize(fte_capacity),0))
  ,avg(nvl(vsize(internal_location),0))
  ,avg(nvl(vsize(mailstop),0))
  ,avg(nvl(vsize(pre_name_adjunct),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('STUDENT_STATUS',student_status)),0))
  ,avg(nvl(vsize(suffix),0))
  ,avg(nvl(vsize(town_of_birth),0))
  ,avg(nvl(vsize(region_of_birth),0))
  ,avg(nvl(vsize(country_of_birth),0))
  ,avg(nvl(vsize(global_person_id),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO',rehire_recommendation)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO',registered_disabled_flag)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO',resume_exists)),0))
  ,avg(nvl(vsize(hr_general.decode_lookup('YES_NO',fast_path_employee)),0))
  ,count(person_id)
  FROM
   per_all_people_f peo
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

/* Length of language */
  CURSOR lng_cur IS
  SELECT avg(nvl(vsize(nls_language),0))
  FROM fnd_languages
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

/*************/
/* RA Source */
/*************/

/* Length of salesrep attributes - plus a weight */
  CURSOR ra_cur IS
  SELECT
    avg(nvl(vsize(salesrep_id),0))
   ,avg(nvl(vsize(salesrep_number),0))
   ,avg(nvl(vsize(name),0))
   ,avg(nvl(vsize(org_id),0))
   ,count(salesrep_id)
  FROM ra_salesreps_all
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

/**************/
/* MTL Source */
/**************/

/* Lenghth of planner attributes - plus a weight */
  CURSOR mtl_cur IS
  SELECT
   avg(nvl(vsize(planner_code),0))
  ,avg(nvl(vsize(description),0))
  ,avg(nvl(vsize(organization_id),0))
  ,count(planner_code)
  FROM mtl_planners
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;


BEGIN


  OPEN inst_cur;
  FETCH inst_cur INTO x_instance;
  CLOSE inst_cur;

/*************/
/* HR Source */
/*************/

  OPEN bgr_cur;
  FETCH bgr_cur INTO x_business_group;
  CLOSE bgr_cur;

  OPEN peo_cur;
  FETCH peo_cur INTO
    x_person_id,
    x_last_name,
    x_person_num,
    x_employee_flag,
    x_email_address,
    x_first_name,
    x_full_name,
    x_known_as,
    x_marital_status,
    x_middle_names,
    x_nationality,
    x_national_identifier,
    x_previous_last_name,
    x_gender,
    x_title,
    x_fte_capacity,
    x_internal_location,
    x_mailstop,
    x_name_prefix,
    x_student_status,
    x_name_suffix,
    x_town_of_birth,
    x_region_of_birth,
    x_country_of_birth,
    x_global_person_id,
    x_rehire_rcmmndtn,
    x_disability_flag,
    x_resume_exists,
    x_fast_path_employee,
    x_peo_weight;
  CLOSE peo_cur;

  OPEN lng_cur;
  FETCH lng_cur INTO x_crrspndnc_language;
  CLOSE lng_cur;

  x_assignment_pk := x_person_id + x_instance;
  x_name          := x_full_name + x_person_num;


/* Yes-No flags should all be similar if the length of "Yes" and "No" is close */
  x_planner_flag    := x_employee_flag;
  x_sales_rep_flag  := x_employee_flag;
  x_sys_gen_flag    := x_employee_flag;
  x_buyer_flag      := x_employee_flag;
  x_applicant_flag  := x_employee_flag;

/*************/
/* RA Source */
/*************/
  OPEN ra_cur;
  FETCH ra_cur INTO
    x_salesrep_id,
    x_salesrep_number,
    x_salesrep_name,
    x_salesrep_org_id,
    x_ra_weight;
  CLOSE ra_cur;

  x_assignment_pk := GREATEST(x_assignment_pk,
                              x_salesrep_id + x_salesrep_org_id + x_instance);
  x_name          := (((x_name*x_peo_weight)
                   + ((x_salesrep_name + x_business_group)*x_ra_weight))
                   / (x_peo_weight + x_ra_weight));
  x_full_name     := (((x_full_name*x_peo_weight)
                   + (x_salesrep_name*x_ra_weight))
                   / (x_peo_weight + x_ra_weight));


/**************/
/* MTL Source */
/**************/
  OPEN mtl_cur;
  FETCH mtl_cur INTO
    x_planner_code,
    x_planner_description,
    x_planner_org_id,
    x_mtl_weight;
  CLOSE mtl_cur;

  x_assignment_pk := GREATEST(x_assignment_pk,
                              x_planner_code + x_planner_org_id + x_instance);
  x_full_name     := (((x_full_name*(x_peo_weight+x_ra_weight))
                   + (x_planner_description*x_mtl_weight))
                   / (x_peo_weight + x_ra_weight + x_mtl_weight));
  x_name          := (((x_name*(x_peo_weight+x_ra_weight))
                   + ((x_planner_code + x_business_group)*x_mtl_weight))
                   / (x_peo_weight + x_ra_weight + x_mtl_weight));
  x_person_dp     := x_name;

  p_avg_row_length :=
  ( NVL(ceil(x_assignment_pk + 1), 0)
  + NVL(ceil(x_business_group + 1), 0)
  + NVL(ceil(x_creation_date + 1), 0)
  + NVL(ceil(x_end_date + 1), 0)
  + NVL(ceil(x_instance + 1), 0)
  + NVL(ceil(x_last_update_date + 1), 0)
  + NVL(ceil(x_name + 1), 0)
  + NVL(ceil(x_start_date + 1), 0)
  + NVL(ceil(x_national_identifier + 1), 0)
  + NVL(ceil(x_person_dp + 1), 0)
  + NVL(ceil(x_person_id + 1), 0)
  + NVL(ceil(x_person_num + 1), 0)
  + NVL(ceil(x_planner_code + 1), 0)
  + NVL(ceil(x_planner_flag + 1), 0)
  + NVL(ceil(x_previous_last_name + 1), 0)
  + NVL(ceil(x_region_of_birth + 1), 0)
  + NVL(ceil(x_rehire_rcmmndtn + 1), 0)
  + NVL(ceil(x_resume_exists + 1), 0)
  + NVL(ceil(x_resume_updated_date + 1), 0)
  + NVL(ceil(x_salesrep_id + 1), 0)
  + NVL(ceil(x_sales_rep_flag + 1), 0)
  + NVL(ceil(x_student_status + 1), 0)
  + NVL(ceil(x_sys_gen_flag + 1), 0)
  + NVL(ceil(x_title + 1), 0)
  + NVL(ceil(x_town_of_birth + 1), 0)
  + NVL(ceil(x_buyer_flag + 1), 0)
  + NVL(ceil(x_country_of_birth + 1), 0)
  + NVL(ceil(x_crrspndnc_language + 1), 0)
  + NVL(ceil(x_date_emp_data_vrfd + 1), 0)
  + NVL(ceil(x_date_of_birth + 1), 0)
  + NVL(ceil(x_disability_flag + 1), 0)
  + NVL(ceil(x_effective_end_date + 1), 0)
  + NVL(ceil(x_effective_start_date + 1), 0)
  + NVL(ceil(x_email_address + 1), 0)
  + NVL(ceil(x_fast_path_employee + 1), 0)
  + NVL(ceil(x_first_name + 1), 0)
  + NVL(ceil(x_fte_capacity + 1), 0)
  + NVL(ceil(x_full_name + 1), 0)
  + NVL(ceil(x_gender + 1), 0)
  + NVL(ceil(x_global_person_id + 1), 0)
  + NVL(ceil(x_internal_location + 1), 0)
  + NVL(ceil(x_known_as + 1), 0)
  + NVL(ceil(x_last_name + 1), 0)
  + NVL(ceil(x_mailstop + 1), 0)
  + NVL(ceil(x_marital_status + 1), 0)
  + NVL(ceil(x_middle_names + 1), 0)
  + NVL(ceil(x_name_prefix + 1), 0)
  + NVL(ceil(x_name_suffix + 1), 0)
  + NVL(ceil(x_nationality + 1), 0)
  + NVL(ceil(x_employee_flag + 1), 0)
  + NVL(ceil(x_applicant_flag + 1), 0) );

  END estimate_row_length;

END edw_hr_person_m_sizing;

/
