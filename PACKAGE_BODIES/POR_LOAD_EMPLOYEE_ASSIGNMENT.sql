--------------------------------------------------------
--  DDL for Package Body POR_LOAD_EMPLOYEE_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_LOAD_EMPLOYEE_ASSIGNMENT" as
/* $Header: PORLEMAB.pls 115.6 2002/11/19 00:36:52 jjessup ship $ */

PROCEDURE insert_update_employee_asg (
        x_person_id IN NUMBER,
        x_business_group_id IN NUMBER,
        x_location_name IN VARCHAR2,
        x_assignment_number IN OUT NOCOPY VARCHAR2,
        x_default_employee_account IN VARCHAR2,
        x_set_of_books_name IN VARCHAR2,
        x_job_name IN VARCHAR2,
        x_supervisor_emp_number IN VARCHAR2,
        x_effective_start_date IN DATE,
        x_effective_end_date IN DATE)

IS

 l_person_id NUMBER;
 l_assignment_id NUMBER;
 l_object_version_number NUMBER;
 l_effective_start_date DATE;
 l_effective_end_date DATE;
 l_comment_id    NUMBER;
 l_location_id NUMBER;
 l_assignment_sequence  NUMBER;
 l_name_combination_warning BOOLEAN;
 l_assign_payroll_warning  BOOLEAN;
 l_business_group_id NUMBER;
 l_employee_number NUMBER;
 l_set_of_books_id NUMBER;
 l_concatenated_segments VARCHAR2(20);
 l_cagr_grade_def_id NUMBER;
 l_cagr_concatenated_segments VARCHAR2(20);
 l_soft_coding_keyflex_id NUMBER;
 l_people_group_id NUMBER;
 l_other_manager_warning BOOLEAN;
 l_no_managers_warning BOOLEAN;
 l_chart_of_accounts_id NUMBER;
 l_ccid NUMBER;
 l_job_id NUMBER;
 l_supervisor_id NUMBER;
 l_group_name VARCHAR2(10);
 l_address_id NUMBER;
 l_employment_category  VARCHAR2(20);
 l_spp_delete_warning BOOLEAN;
 l_entries_changed_warning VARCHAR2(20);
 l_tax_district_changed_warning  BOOLEAN;
 l_special_ceiling_step_id NUMBER;

 BEGIN

  l_set_of_books_id := get_set_of_books_id(x_set_of_books_name);

  l_chart_of_accounts_id := get_chart_of_accounts_id(l_set_of_books_id);

  l_ccid := get_ccid(l_chart_of_accounts_id,x_default_employee_account);

  if (x_job_name IS NOT NULL) THEN

    l_job_id := get_job_id(x_job_name,x_business_group_id);

  END IF;

  IF (x_supervisor_emp_number IS NOT NULL) THEN

   l_supervisor_id := get_supervisor_id(x_supervisor_emp_number);

  END IF;

  IF (x_location_name IS NOT NULL) THEN

    l_location_id := get_location_id(x_location_name);

  END IF;

  get_assignment_exists(x_person_id,x_effective_start_date,x_effective_end_date,l_assignment_id,l_object_version_number);

          hr_assignment_api.update_emp_asg (
	    p_validate => FALSE
           ,p_datetrack_update_mode => 'CORRECTION'
	   ,p_effective_date => x_effective_start_date
	   ,p_concatenated_segments  => l_concatenated_segments
	   ,p_cagr_grade_def_id => l_cagr_grade_def_id
	   ,p_cagr_concatenated_segments  => l_cagr_concatenated_segments
	   ,p_assignment_id  => l_assignment_id
	   ,p_soft_coding_keyflex_id  =>  l_soft_coding_keyflex_id
	   ,p_object_version_number => l_object_version_number
	   ,p_assignment_number => x_assignment_number
	   ,p_effective_start_date =>  l_effective_start_date
	   ,p_effective_end_date =>  l_effective_end_date
	   ,p_comment_id  => l_comment_id
	   ,p_other_manager_warning => l_other_manager_warning
           ,p_no_managers_warning => l_no_managers_warning
           ,p_set_of_books_id => l_set_of_books_id
           ,p_default_code_comb_id => l_ccid
	   ,p_supervisor_id => l_supervisor_id
	  );


          hr_assignment_api.update_emp_asg_criteria (
           p_validate => FALSE
          ,p_datetrack_update_mode => 'CORRECTION'
          ,p_assignment_id  => l_assignment_id
          ,p_object_version_number => l_object_version_number
          ,p_special_ceiling_step_id => l_special_ceiling_step_id
	  ,p_effective_date => x_effective_start_date
          ,p_job_id => l_job_id
          ,p_location_id => l_location_id
          ,p_group_name => l_group_name
          ,p_employment_category => l_employment_category
          ,p_effective_start_date => l_effective_start_date
          ,p_effective_end_date =>  l_effective_end_date
          ,p_people_group_id => l_people_group_id
          ,p_org_now_no_manager_warning => l_no_managers_warning
          ,p_other_manager_warning => l_other_manager_warning
          ,p_spp_delete_warning => l_spp_delete_warning
          ,p_entries_changed_warning => l_entries_changed_warning
          ,p_tax_district_changed_warning => l_tax_district_changed_warning
          );


  commit;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN
    RETURN;

  WHEN OTHERS THEN
    RAISE;


END insert_update_employee_asg;


FUNCTION get_set_of_books_id (p_set_of_books_name IN VARCHAR2) RETURN NUMBER IS
  l_set_of_books_id NUMBER;
BEGIN

  SELECT set_of_books_id INTO l_set_of_books_id
  FROM gl_sets_of_books
  WHERE name = p_set_of_books_name;

  RETURN l_set_of_books_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_set_of_books_id;


FUNCTION get_location_id (p_location_name IN VARCHAR2) RETURN NUMBER IS
  l_location_id NUMBER;
BEGIN

  SELECT location_id INTO l_location_id
  FROM hr_locations_all
  WHERE location_code = p_location_name;

  RETURN l_location_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN -1;

END get_location_id;


FUNCTION get_chart_of_accounts_id (p_set_of_books_id IN NUMBER) RETURN NUMBER IS
  l_chart_of_accounts_id NUMBER;
BEGIN

  SELECT chart_of_accounts_id INTO l_chart_of_accounts_id
  FROM gl_sets_of_books
  WHERE set_of_books_id = p_set_of_books_id;

  RETURN l_chart_of_accounts_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_chart_of_accounts_id;


FUNCTION get_ccid (p_chart_of_accounts_id IN NUMBER,p_concatenated_segs IN VARCHAR2) RETURN NUMBER IS
  l_ccid NUMBER;
BEGIN



  l_ccid := fnd_flex_ext.get_ccid('SQLGL','GL#',p_chart_of_accounts_id, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),p_concatenated_segs);


  IF (l_ccid = 0) THEN
     RETURN NULL;
  ELSE
     RETURN l_ccid;

  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END get_ccid;

PROCEDURE get_assignment_exists(p_person_id IN NUMBER,p_effective_start_date IN DATE, p_effective_end_date IN DATE,l_assignment_id OUT NOCOPY NUMBER,l_object_version_number OUT NOCOPY NUMBER)
IS

BEGIN

   SELECT assignment_id, object_version_number INTO l_assignment_id, l_object_version_number FROM per_all_assignments_f
   WHERE person_id = p_person_id and trunc(effective_start_date) <= trunc(p_effective_start_date);

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN;

END get_assignment_exists;

FUNCTION get_job_id (p_job_name IN VARCHAR2, p_business_group_id IN NUMBER) RETURN NUMBER IS
     l_job_id NUMBER;
BEGIN

    SELECT job_id INTO l_job_id FROM per_jobs job
    WHERE  job.name  = p_job_name
    AND    job.business_group_id = p_business_group_id;

    RETURN l_job_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN -1;

END get_job_id;


FUNCTION get_supervisor_id(x_supervisor_emp_num IN VARCHAR2) RETURN NUMBER IS
     l_supervisor_id NUMBER;
BEGIN

     SELECT person_id INTO l_supervisor_id FROM per_all_people_f
     WHERE employee_number = x_supervisor_emp_num;

     RETURN l_supervisor_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN -1;

END get_supervisor_id;

FUNCTION get_address_exists(p_person_id IN NUMBER) RETURN NUMBER IS
     l_address_id NUMBER;
BEGIN

     SELECT address_id INTO l_address_id
     FROM per_addresses
     WHERE person_id = p_person_id
     AND primary_flag = 'Y';

     RETURN l_address_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN NULL;

END get_address_exists;

END POR_LOAD_EMPLOYEE_ASSIGNMENT;

/
