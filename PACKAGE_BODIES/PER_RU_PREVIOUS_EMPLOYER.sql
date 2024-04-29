--------------------------------------------------------
--  DDL for Package Body PER_RU_PREVIOUS_EMPLOYER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RU_PREVIOUS_EMPLOYER" as
/* $Header: perupemp.pkb 120.1 2006/09/20 14:34:33 mgettins noship $ */
PROCEDURE CREATE_RU_PREVIOUS_EMPLOYER(P_BUSINESS_GROUP_ID	NUMBER
				     ,P_PERSON_ID		NUMBER
				     ,P_START_DATE		DATE
				     ,P_END_DATE		DATE
				     ,P_PEM_INFORMATION_CATEGORY VARCHAR2) is
CURSOR c_prev_employer_list is
	select 'x' from PER_PREVIOUS_EMPLOYERS
	WHERE business_group_id = p_business_group_id
	AND   person_id = p_person_id
	AND   (start_date BETWEEN P_START_DATE AND P_END_DATE
           OR end_date BETWEEN P_START_DATE AND P_END_DATE
           OR P_START_DATE BETWEEN start_date and end_date
		   OR P_END_DATE BETWEEN start_date and end_date);

CURSOR c_prev_job_list is
	select 'x' from per_previous_jobs ppj, per_previous_employers ppe
	where   ppe.business_group_id=p_business_group_id
	AND     ppe.person_id=p_person_id
	AND     ppe.PREVIOUS_EMPLOYER_ID=ppj.PREVIOUS_EMPLOYER_ID
	AND     (ppj.START_DATE between p_start_date and p_end_date
        	OR ppj.end_date between p_start_date and p_end_date
	        OR P_START_DATE BETWEEN ppj.start_date and ppj.end_date
		    OR P_END_DATE BETWEEN ppj.start_date and ppj.end_date);

CURSOR c_current_employer IS
   select 'x' from per_all_assignments_f a, hr_soft_coding_keyflex s
   where a.business_group_id=p_business_group_id
   and a.person_id=p_person_id
   and a.assignment_status_type_id <> '3'
   and a.SOFT_CODING_KEYFLEX_ID = s.SOFT_CODING_KEYFLEX_ID(+)
   and (nvl(segment2, 'N') = 'N' OR a.SOFT_CODING_KEYFLEX_ID IS NULL)
   and (effective_start_date between p_start_date and p_end_date
        OR effective_end_date between p_start_date and p_end_date
		OR p_start_date between effective_start_date and effective_end_date
		OR p_end_date between effective_start_date and effective_end_date);

v_dummy		VARCHAR2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
--IF P_PEM_INFORMATION_CATEGORY='RU' THEN
	OPEN c_prev_employer_list;
	FETCH c_prev_employer_list INTO v_dummy;
	IF c_prev_employer_list%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_prev_employer_list;

	OPEN c_prev_job_list;
	FETCH c_prev_job_list INTO v_dummy;
	IF c_prev_job_list%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_prev_job_list;

	OPEN c_current_employer;
	FETCH c_current_employer INTO v_dummy;
	IF c_current_employer%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_current_employer;

  END IF;
END CREATE_RU_PREVIOUS_EMPLOYER;

PROCEDURE UPDATE_RU_PREVIOUS_EMPLOYER(P_PREVIOUS_EMPLOYER_ID	NUMBER
				     ,P_START_DATE		DATE
				     ,P_END_DATE		DATE
				     ,P_PEM_INFORMATION_CATEGORY VARCHAR2) is
CURSOR c_prev_employer_details is
	SELECT 'x' FROM PER_PREVIOUS_EMPLOYERS WHERE
	(person_id,business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers WHERE previous_employer_id=p_previous_employer_id)
	AND previous_employer_id <> P_PREVIOUS_EMPLOYER_ID
	AND   (start_date BETWEEN P_START_DATE AND P_END_DATE
	OR   end_date BETWEEN P_START_DATE AND P_END_DATE
    OR P_START_DATE BETWEEN start_date and end_date
    OR P_END_DATE BETWEEN start_date and end_date);

CURSOR c_prev_job_details is
	SELECT 'x' FROM PER_PREVIOUS_EMPLOYERS ppe, per_previous_jobs ppj WHERE
	(ppe.person_id,ppe.business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers WHERE previous_employer_id=p_previous_employer_id)
	AND   ppe.previous_employer_id=ppj.previous_employer_id
	AND   (ppj.start_date BETWEEN P_START_DATE AND P_END_DATE
	       OR ppj.end_date BETWEEN P_START_DATE AND P_END_DATE
           OR P_START_DATE BETWEEN ppj.start_date and ppj.end_date
		   OR P_END_DATE BETWEEN ppj.start_date and ppj.end_date);

CURSOR c_current_employer IS
   select 'x' from per_all_assignments_f a, hr_soft_coding_keyflex s
   where (person_id,business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers WHERE previous_employer_id=p_previous_employer_id)
   and assignment_status_type_id <> '3'
   and a.SOFT_CODING_KEYFLEX_ID = s.SOFT_CODING_KEYFLEX_ID(+)
   and (nvl(segment2, 'N') = 'N' OR a.SOFT_CODING_KEYFLEX_ID IS NULL)
   and (effective_start_date between p_start_date and p_end_date
        OR effective_end_date between p_start_date and p_end_date
		OR p_start_date between effective_start_date and effective_end_date
		OR p_end_date between effective_start_date and effective_end_date);


v_dummy		VARCHAR2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
    --
	OPEN c_prev_employer_details;
	FETCH c_prev_employer_details INTO v_dummy;
	IF c_prev_employer_details%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_prev_employer_details;

	OPEN c_prev_job_details;
	FETCH c_prev_job_details INTO v_dummy;
	IF c_prev_job_details%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_prev_job_details;

	OPEN c_current_employer;
	FETCH c_current_employer INTO v_dummy;
	IF c_current_employer%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_current_employer;
    --
  END IF;
END UPDATE_RU_PREVIOUS_EMPLOYER;

PROCEDURE CREATE_RU_PREVIOUS_JOB(P_PREVIOUS_EMPLOYER_ID NUMBER
				,P_START_DATE		DATE
				,P_END_DATE		DATE) is


CURSOR c_get_job is
	select 'x' from per_previous_jobs ppj, per_previous_employers ppe
	where   (ppe.person_id,ppe.business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers WHERE previous_employer_id=p_previous_employer_id)
	AND ppe.previous_employer_id = ppj.previous_employer_id (+)

	AND  (ppj.START_DATE between p_start_date and p_end_date
	      OR ppj.end_date between p_start_date and p_end_date
          OR ppe.START_DATE between p_start_date and p_end_date
	      OR  ppe.end_date between p_start_date and p_end_date
		  OR p_start_date between ppj.START_DATE and ppj.END_DATE
  		  OR p_end_date between ppj.START_DATE and ppj.END_DATE
  		  OR p_start_date between ppe.START_DATE and ppe.END_DATE
  		  OR p_end_date between ppe.START_DATE and ppe.END_DATE   );

CURSOR c_current_employer IS
   select 'x' from per_all_assignments_f a, hr_soft_coding_keyflex s
   where (person_id,business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers WHERE previous_employer_id=p_previous_employer_id)
   and assignment_status_type_id <> '3'
   and a.SOFT_CODING_KEYFLEX_ID = s.SOFT_CODING_KEYFLEX_ID(+)
   and (nvl(segment2, 'N') = 'N' OR a.SOFT_CODING_KEYFLEX_ID IS NULL)
   and (effective_start_date between p_start_date and p_end_date
        OR effective_end_date between p_start_date and p_end_date
		OR p_start_date between effective_start_date and effective_end_date
		OR p_end_date between effective_start_date and effective_end_date);

v_dummy varchar2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
    --
--   hr_utility.trace_on('Y','Russia');

--  hr_utility.trace('St Date : ' || p_start_date);
--   hr_utility.trace('End Date : ' || p_end_date);

	open c_get_job;
	FETCH c_get_job into v_dummy;
--  hr_utility.trace('v_dummy : ' || v_dummy);
	IF c_get_job%FOUND then
--	   hr_utility.trace('Inside IF');
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_get_job;

	OPEN c_current_employer;
	FETCH c_current_employer INTO v_dummy;
	IF c_current_employer%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_current_employer;
  END IF;
END CREATE_RU_PREVIOUS_JOB;

PROCEDURE UPDATE_RU_PREVIOUS_JOB(P_PREVIOUS_JOB_ID	NUMBER
				,P_START_DATE		DATE
				,P_END_DATE		DATE) is

CURSOR c_job_details is
	SELECT 'x' FROM PER_PREVIOUS_EMPLOYERS ppe, per_previous_jobs ppj WHERE
	(ppe.person_id,ppe.business_group_id) =(SELECT person_id,business_group_id FROM per_previous_employers pee,per_previous_jobs ppj
	WHERE ppj.previous_job_id=p_previous_job_id and ppj.previous_employer_id = pee.previous_employer_id)
	AND   ppe.previous_employer_id = ppj.previous_employer_id (+)
    AND   ppj.previous_job_id <> p_previous_job_id
	AND  (ppj.start_date BETWEEN P_START_DATE AND P_END_DATE
	      OR ppj.end_date BETWEEN P_START_DATE AND P_END_DATE
	      OR ppe.start_date BETWEEN P_START_DATE AND P_END_DATE
	      OR ppe.end_date BETWEEN P_START_DATE AND P_END_DATE
		  OR P_START_DATE BETWEEN ppj.start_date and ppj.end_date
		  OR P_END_DATE BETWEEN ppj.start_date and ppj.end_date
  		  OR P_START_DATE BETWEEN ppe.start_date and ppe.end_date
		  OR P_END_DATE BETWEEN ppe.start_date and ppe.end_date);

CURSOR c_current_employer IS
   select 'x' from per_all_assignments_f a, hr_soft_coding_keyflex s
   where (person_id, business_group_id) = (SELECT person_id,business_group_id FROM per_previous_employers pee,per_previous_jobs ppj
   WHERE ppj.previous_job_id=p_previous_job_id and ppj.previous_employer_id = pee.previous_employer_id)
   and assignment_status_type_id <> '3'
   and a.SOFT_CODING_KEYFLEX_ID = s.SOFT_CODING_KEYFLEX_ID(+)
   and (nvl(segment2, 'N') = 'N' OR a.SOFT_CODING_KEYFLEX_ID IS NULL)
   and (effective_start_date between p_start_date and p_end_date
        OR effective_end_date between p_start_date and p_end_date
		OR p_start_date between effective_start_date and effective_end_date
		OR p_end_date between effective_start_date and effective_end_date);

v_dummy varchar2(1);
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
    --
	OPEN c_job_details;
	FETCH c_job_details into v_dummy;
	IF c_job_details%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_job_details;
	OPEN c_current_employer;
	FETCH c_current_employer INTO v_dummy;
	IF c_current_employer%FOUND THEN
		hr_utility.set_message(800,'HR_RU_OVERLAPPING_DATES');
		hr_utility.set_message_token('STARTDATE', to_char(p_start_date, 'DD-MON-YYYY'));
		hr_utility.set_message_token('ENDDATE', to_char(p_end_date, 'DD-MON-YYYY'));
		hr_utility.raise_error;
	END IF;
	CLOSE c_current_employer;
  END IF;
END UPDATE_RU_PREVIOUS_JOB;

END PER_RU_PREVIOUS_EMPLOYER;

/
