--------------------------------------------------------
--  DDL for Package Body PER_DB_PER_ADDITIONAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DB_PER_ADDITIONAL" AS
/* $Header: peadditn.pkb 120.0 2005/05/31 04:56:03 appldev noship $ */
/*
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : per_db_per_additional  (BODY)

 Description : This package defines procedures required to
               create all additional entities in Personnel.
               That is:

                 Applicants,
                 Employees,
                 Secondary assignments,
                 Others,
                 Contacts.
 Change List
 -----------
 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    11-JAN-93 SZWILLIA             Date Created
 70.1    12-JAN-93 SZWILLIA             Changed SELECTS to DISTINCT
                                         where necessary.
 70.3    19-JAN-93 SZWILLIA             Changed status type selects
                                         to UNIONS with amendments.
 70.4    20-JAN-93 SZWILLIA             Corrected error handling and
                                         warning setting.
 70.6    04-MAR-93 SZWILLIA             Changed parameters to DATEs.
 70.7    10-MAR-93 SZWILLIA             Changed parameter lists for
                                         employees and applicants.
                                        Made significant changes to
                                         allow for vacancies and locations.
                                        Changed insert_assignment to
                                         perform third party population
                                         of letters and budget values.
 70.8    11-MAR-93 NKHAN		Added 'exit' at the end
 70.9    18-MAR-93 SZWILLIA             Changed interface to create_applicant
                                         create_employee and
                                         create_secondary_assign.
 70.10   19-MAR-93 SZWILLIA             Minor corrections.
 70.11   19-MAR-93 SZWILLIA             Re-instated exit.
 70.12   29-MAR-93 SZWILLIA             Changed default for expense check
                                         to match domain.
 70.13   26-APR-93 TMATHERS            Changed call to derive_full_name
                                        to account for it's change
                                        to a procedure.
 70.14   11-JUN-93 TMathers             Changed call to validate_dob
                                        removed the current_emp_or_apl_flag
                                        parameter.
 70.15   13-JUN-93 TMathers             Changed call to generate_number
                                        added l_person_id parameter.
 70.20   23-NOV-94 rfine		Suppressed index on business_group_id
					in all where clauses.
 110.1   2-APR-98  SASmith              Change to procedure call to hr_assignment.load_budget_values
                                        to include the assignment's effective start and end dates.
                                        This is required as the budget values table is now date tracked.
 110.2   5-FEB-99  LSIGRIST             Checked, upadated MLS and date formats
                                        for release 11.5 compliancy.
 115.3   22-APR-99 ALogue               Canonical number support for
                                        normal_hours in insert_assignment.
 115.4   24-AUG-99 JPBard               Remove work_telephone from insert list
 115.5   26-JUN-00 CCarter              Changed per_jobs to per_jobs_v for
								Job Groups.
 115.11  15-SEP-00 GPERRY               Leapfrog of 115.9 with fix for
                                        WWBUG 1390173.
 115.12  19-OCT-00 GPERRY               Fixed WWBUG 1408379.
                                        Added hook calls to OAB so life event triggers
                                        work.
 115.13  29-MAY-01 A.Sahay              PTU Changes
 115.13  19-JUN-01 GPERRY               Performance fixes for WWBUG 1833930.
                                        Changed references from hr_locations to
                                        hr_locations_all. This is done because
                                        of the join using location_code which
                                        is consistent with hr_locations_all and
                                        not hz_locations.
 115.14  06-JUL-01 PBODLA               Bug 1877018 - Passed final_process_date
                                        while calling ben_pps_trg.ler_chk
                                        to detect potential life events.
 115.18  20-JUN-02 vbanner              changes in call to generate_number
                                        and validate_unique_number
                                        to allow compilation
                                        Bug 2426235.
 115.19  09-Dec-02 joward               MLS enabled grade name
 115.20  15-Jan-03 pkakar               updated function insert assignment to
					                         include vacancy_id
 115.21  29-Jun-04 vanantha             Performance fixes(Bug 3648477)
 115.22  20-jan-05 irgonzal   3889584   Added call to new routine to
                                        derive person names.
 ================================================================= */
--
--
FUNCTION insert_period_of_service
  (p_person_id                    NUMBER
  ,p_business_group_id            NUMBER
  ,p_date_start                   DATE
  ,p_accepted_termination_date    DATE
  ,p_actual_termination_date      DATE
  ,p_final_process_date           DATE
  ,p_last_standard_process_date   DATE
  ,p_leaving_reason               VARCHAR2
  ,p_notified_termination_date    DATE
  ,p_projected_termination_date   DATE
  ,p_term_accepted_person_id      NUMBER)
return NUMBER IS
--
  l_period_of_service_id NUMBER;
  l_emp_check            VARCHAR2(1);
--
-- START WWBUG fix for 1390173
--
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG fix for 1390173
--
--
begin
  --
  --
  hr_utility.set_location('per_db_per_additional.insert_period_of_service',1);
  SELECT per_periods_of_service_s.nextval
  INTO   l_period_of_service_id
  FROM   sys.dual;
  --
  hr_utility.set_location('per_db_per_additional.insert_period_of_service',2);
  --
  --  Note : this check will only work for NEW employees - ie no
  --         previous periods of service.
  --
  SELECT 'Y'
  INTO   l_emp_check
  FROM   sys.dual
  WHERE  p_date_start = (SELECT min(effective_start_date)
                  FROM   per_people_f     pp
                  WHERE  pp.person_id   = p_person_id
                  AND    pp.current_employee_flag = 'Y');
  --
  hr_utility.set_location('per_db_per_additional.insert_period_of_service',5);
  INSERT INTO per_periods_of_service
  (period_of_service_id
  ,business_group_id
  ,person_id
  ,date_start
  ,accepted_termination_date
  ,actual_termination_date
  ,final_process_date
  ,last_standard_process_date
  ,leaving_reason
  ,notified_termination_date
  ,projected_termination_date
  ,termination_accepted_person_id
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  values
  (l_period_of_service_id
  ,p_business_group_id
  ,p_person_id
  ,p_date_start
  ,p_accepted_termination_date
  ,p_actual_termination_date
  ,p_final_process_date
  ,p_last_standard_process_date
  ,p_leaving_reason
  ,p_notified_termination_date
  ,p_projected_termination_date
  ,p_term_accepted_person_id
  ,SYSDATE
  ,0
  ,0
  ,0
  ,SYSDATE);
  --
--
-- START WWBUG fix for 1390173
--
  l_new.PERSON_ID := p_person_id;
  l_new.BUSINESS_GROUP_ID := p_business_group_id;
  l_new.DATE_START := p_date_start;
  l_new.ACTUAL_TERMINATION_DATE := p_actual_termination_date;
  l_new.LEAVING_REASON := p_leaving_reason;
  l_new.ADJUSTED_SVC_DATE := null;
  l_new.ATTRIBUTE1 := null;
  l_new.ATTRIBUTE2 := null;
  l_new.ATTRIBUTE3 := null;
  l_new.ATTRIBUTE4 := null;
  l_new.ATTRIBUTE5 := null;
  l_new.final_process_date := p_final_process_date;
  --
  ben_pps_ler.ler_chk(p_old            => l_old
                     ,p_new            => l_new
                     ,p_event          => 'INSERTING'
                     ,p_effective_date => p_date_start);
--
-- END WWBUG fix for 1390173
--
  --
  return l_period_of_service_id;
--
end insert_period_of_service;
--
--
FUNCTION insert_application
  (p_person_id                    NUMBER
  ,p_business_group_id            NUMBER
  ,p_date_received                DATE
  ,p_date_end                     DATE
  ,p_current_employer             VARCHAR2
  ,p_projected_hire_date          DATE
  ,p_termination_reason           VARCHAR2)
return NUMBER IS
--
  l_application_id NUMBER;
  l_apl_check      VARCHAR2(1);
  l_termination_reason VARCHAR2(80) := null;
--
begin
  --
  --
  hr_utility.set_location('per_db_per_additional.insert_application',1);
  SELECT per_applications_s.nextval
  INTO   l_application_id
  FROM   sys.dual;
  --
  hr_utility.set_location('per_db_per_additional.insert_application',2);
  --
  --  Note : this check will only work for NEW applicants - ie no
  --         previous applications .
  --
  SELECT 'Y'
  INTO   l_apl_check
  FROM   sys.dual
  WHERE  p_date_received = (SELECT min(effective_start_date)
                  FROM   per_people_f     pp
                  WHERE  pp.person_id   = p_person_id
                  AND    pp.current_applicant_flag = 'Y');
  --
  hr_utility.set_location('per_db_per_additional.insert_application',5);
  INSERT INTO per_applications
  (application_id
  ,business_group_id
  ,person_id
  ,date_received
  ,date_end
  ,current_employer
  ,projected_hire_date
  ,termination_reason
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  values
  (l_application_id
  ,p_business_group_id
  ,p_person_id
  ,p_date_received
  ,p_date_end
  ,p_current_employer
  ,p_projected_hire_date
  ,l_termination_reason
  ,SYSDATE
  ,0
  ,0
  ,0
  ,SYSDATE);
  --
  return l_application_id;
--
end insert_application;
--
--
FUNCTION insert_person
  (p_effective_start_date         DATE
  ,p_effective_end_date           DATE
  ,p_business_group_id            NUMBER
  ,p_person_type_id               NUMBER
  ,p_last_name                    VARCHAR2
  ,p_applicant_number             VARCHAR2
  ,p_current_applicant_flag       VARCHAR2
  ,p_current_employee_flag        VARCHAR2
  ,p_current_emp_or_apl_flag      VARCHAR2
  ,p_employee_data_verified       DATE
  ,p_date_of_birth                DATE
  ,p_employee_number              VARCHAR2
  ,p_expense_chk_send_to_address  VARCHAR2
  ,p_first_name                   VARCHAR2
  ,p_known_as                     VARCHAR2
  ,p_marital_status               VARCHAR2
  ,p_middle_names                 VARCHAR2
  ,p_nationality                  VARCHAR2
  ,p_national_identifier          VARCHAR2
  ,p_previous_last_name           VARCHAR2
  ,p_registered_disabled_flag     VARCHAR2
  ,p_sex                          VARCHAR2
  ,p_title                        VARCHAR2
  ,p_work_telephone               VARCHAR2)
  return NUMBER
  IS
  --
    l_person_id         NUMBER;
    l_applicant_number  VARCHAR2(30) ;
    l_employee_number   VARCHAR2(30);
    l_npw_number        VARCHAR2(30) := NULL;
    l_full_name         VARCHAR2(240);
    l_order_name        varchar2(240);
    l_global_name       varchar2(240);
    l_local_name        varchar2(240);
    l_dup_name          VARCHAR2(1);
    l_current_npw       VARCHAR2(30) := NULL;
  --
  begin
    --
      hr_utility.set_location('per_db_per_additional.insert_person',1);
    --
      l_applicant_number := p_applicant_number;
      l_employee_number  := p_employee_number;
    --
      SELECT per_people_s.nextval
      INTO   l_person_id
      FROM   sys.dual;
    --
      hr_utility.set_location('per_db_per_additional.insert_person',2);
      hr_person.validate_national_identifier(p_national_identifier,
                                             l_person_id,
                                             p_business_group_id);
    --
    if hr_utility.check_warning then
       hr_utility.raise_error;
    end if;
    --
      hr_utility.set_location('per_db_per_additional.insert_person',3);
      hr_person.validate_dob(p_date_of_birth,
                             p_effective_start_date);
    --
    --
      hr_utility.set_location('per_db_per_additional.insert_person',4);
      --
      -- this is replaced by new call below
      --
      --hr_person.derive_full_name(p_first_name,
      --                         p_middle_names, p_last_name, p_known_as,
      --                         p_title, p_date_of_birth,
      --                         l_person_id, p_business_group_id
      --                         ,l_full_name,l_dup_name);

    --
    if hr_utility.check_warning then
       hr_utility.raise_error;
    end if;
    --
      hr_person.generate_number(p_current_employee_flag,
                                p_current_applicant_flag,
                                l_current_npw,     --current_npw_flag
                                p_national_identifier,
                                p_business_group_id ,
                                l_person_id,
                                l_employee_number,
                                l_applicant_number,
                                l_npw_number);
    --
    --
      hr_utility.set_location('per_db_per_additional.insert_person',5);
      hr_person.validate_sex_and_title(p_current_employee_flag
                               ,p_sex
                               ,p_title);
    if hr_utility.check_warning then
       hr_utility.raise_error;
    end if;
    --
      hr_person.validate_unique_number(l_person_id
                               ,p_business_group_id
                               ,l_employee_number
                               ,l_applicant_number
                               ,l_npw_number      --npw_number
                               ,p_current_employee_flag
                               ,p_current_applicant_flag
                               ,l_current_npw      --current_npw_flag
                               );
    --
    hr_utility.set_location('per_db_per_additional.insert_person',6);
    --
    hr_person_name.derive_person_names  -- #3889584
      (p_format_name        =>  NULL, -- derive all names
       p_business_group_id  =>  p_business_group_id,
       p_person_id          =>  l_person_id,
       p_first_name         =>  p_first_name,
       p_middle_names       =>  p_middle_names,
       p_last_name          =>  p_last_name,
       p_known_as           =>  p_known_as,
       p_title              =>  p_title,
       p_suffix             =>  NULL,
       p_pre_name_adjunct   =>  NULL,
       p_date_of_birth      =>  p_date_of_birth,
       p_previous_last_name =>  p_previous_last_name  ,
       --
       p_employee_number    =>  l_employee_number  ,
       p_applicant_number   =>  l_applicant_number  ,
       p_npw_number         =>  l_npw_number,
       p_full_name          =>  l_full_name,
       p_order_name         =>  l_order_name,
       p_global_name        =>  l_global_name,
       p_local_name         =>  l_local_name,
       p_duplicate_flag     =>  l_dup_name
       );
    --
      hr_utility.set_location('per_db_per_additional.insert_person',7);
    --
      INSERT INTO per_people_f
      (person_id
      ,effective_start_date
      ,effective_end_date
      ,business_group_id
      ,person_type_id
      ,last_name
      ,start_date
      ,applicant_number
      ,current_applicant_flag
      ,current_employee_flag
      ,current_emp_or_apl_flag
      ,date_employee_data_verified
      ,date_of_birth
      ,employee_number
      ,expense_check_send_to_address
      ,first_name
      ,full_name
      ,known_as
      ,marital_status
      ,middle_names
      ,nationality
      ,national_identifier
      ,previous_last_name
      ,registered_disabled_flag
      ,sex
      ,title
      ,order_name
      ,global_name
      ,local_name
--      ,work_telephone
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date)
      values
      (l_person_id
      ,p_effective_start_date
      ,p_effective_end_date
      ,p_business_group_id
      ,p_person_type_id
      ,p_last_name
      ,p_effective_start_date
      ,l_applicant_number
      ,p_current_applicant_flag
      ,p_current_employee_flag
      ,p_current_emp_or_apl_flag
      ,p_employee_data_verified
      ,p_date_of_birth
      ,l_employee_number
      ,p_expense_chk_send_to_address
      ,p_first_name
      ,l_full_name
      ,p_known_as
      ,p_marital_status
      ,p_middle_names
      ,p_nationality
      ,p_national_identifier
      ,p_previous_last_name
      ,p_registered_disabled_flag
      ,p_sex
      ,p_title
      ,l_order_name
      ,l_global_name
      ,l_local_name
--      ,p_work_telephone
      ,SYSDATE
      ,0
      ,0
      ,0
      ,SYSDATE);
    --
    --
    return l_person_id;
    --
end insert_person;
--
--
FUNCTION insert_assignment
  (p_effective_start_date        DATE
  ,p_effective_end_date          DATE
  ,p_business_group_id           NUMBER
  ,p_person_id                   NUMBER
  ,p_assignment_type             VARCHAR2
  ,p_organization_id             NUMBER
  ,p_grade_id                    NUMBER
  ,p_job_id                      NUMBER
  ,p_position_id                 NUMBER
  ,p_payroll_id                  NUMBER
  ,p_location_id                 NUMBER
  ,p_vacancy_id                  NUMBER
  ,p_people_group_id             NUMBER
  ,p_soft_coding_keyflex_id      NUMBER
  ,p_assignment_status_type_id   NUMBER
  ,p_primary_flag                VARCHAR2
  ,p_manager_flag                VARCHAR2
  ,p_change_reason               VARCHAR2
  ,p_date_probation_end          DATE
  ,p_frequency                   VARCHAR2
  ,p_internal_address_line       VARCHAR2
  ,p_normal_hours                VARCHAR2
  ,p_probation_period            VARCHAR2
  ,p_probation_unit              VARCHAR2
  ,p_recruiter_id                NUMBER
  ,p_special_ceiling_step_id     NUMBER
  ,p_supervisor_id               NUMBER
  ,p_recruitment_activity_id     NUMBER
  ,p_person_referred_by_id       NUMBER
  ,p_source_organization_id      NUMBER
  ,p_time_normal_finish          VARCHAR2
  ,p_time_normal_start           VARCHAR2)
return NUMBER IS
--
  l_assignment_id         NUMBER;
  l_application_id        NUMBER := null;
  l_period_of_service_id  NUMBER := null;
  l_assignment_sequence   NUMBER;
  l_assignment_number     VARCHAR2(30) := null;
  l_employee_number       VARCHAR2(30) := null;
  l_letter_type_id        NUMBER;
  l_letter_request_id     NUMBER;
--
begin
  --
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',1);
  SELECT per_assignments_s.nextval
  ,      pp.employee_number
  INTO   l_assignment_id
  ,      l_employee_number
  FROM   per_people_f pp
  WHERE  pp.person_id = p_person_id
  AND    p_effective_start_date BETWEEN pp.effective_start_date
                                AND     pp.effective_end_date;
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',20);
  if p_assignment_type = 'E' then     -- Employee
     SELECT period_of_service_id
     INTO   l_period_of_service_id
     FROM   per_periods_of_service
     WHERE  person_id = p_person_id
     AND    p_effective_start_date
            BETWEEN date_start AND
            nvl(actual_termination_date,to_date('4712/12/31','YYYY/MM/DD'))
     AND    p_effective_end_date <=
            nvl(actual_termination_date,to_date('4712/12/31','YYYY/MM/DD'));
  else                                -- Applicant
     SELECT application_id
     INTO   l_application_id
     FROM   per_applications
     WHERE  person_id = p_person_id
     AND    p_effective_start_date BETWEEN date_received AND
            nvl(date_end,to_date('4712/12/31','YYYY/MM/DD'))
     AND    p_effective_end_date <=
            nvl(date_end,to_date('4712/12/31','YYYY/MM/DD'));
  end if;
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',2);
  hr_assignment.gen_new_ass_sequence(p_person_id,
                       p_assignment_type,
                       l_assignment_sequence);
  --
  --
 if p_assignment_type = 'E' then  -- Employee
  hr_utility.set_location('per_db_per_additional.insert_assignment',3);
  hr_assignment.gen_new_ass_number(l_assignment_id,
                     p_business_group_id,
                     l_employee_number,
                     l_assignment_sequence,
                     l_assignment_number);
  --
 end if;
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',4);
  hr_assignment.check_hours(p_frequency,
              fnd_number.canonical_to_number(p_normal_hours));
  --
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',5);
  INSERT INTO per_all_assignments_f
  (assignment_id
  ,effective_start_date
  ,effective_end_date
  ,business_group_id
  ,grade_id
  ,position_id
  ,job_id
  ,assignment_status_type_id
  ,payroll_id
  ,location_id
  ,person_id
  ,organization_id
  ,people_group_id
  ,soft_coding_keyflex_id
  ,vacancy_id
  ,assignment_sequence
  ,assignment_type
  ,manager_flag
  ,primary_flag
  ,application_id
  ,assignment_number
  ,change_reason
  ,date_probation_end
  ,frequency
  ,internal_address_line
  ,normal_hours
  ,period_of_service_id
  ,probation_period
  ,probation_unit
  ,recruiter_id
  ,special_ceiling_step_id
  ,supervisor_id
  ,recruitment_activity_id
  ,person_referred_by_id
  ,source_organization_id
  ,time_normal_finish
  ,time_normal_start
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  values (l_assignment_id
  ,      p_effective_start_date
  ,      p_effective_end_date
  ,      p_business_group_id
  ,      p_grade_id
  ,      p_position_id
  ,      p_job_id
  ,      p_assignment_status_type_id
  ,      p_payroll_id
  ,      p_location_id
  ,      p_person_id
  ,      p_organization_id
  ,      p_people_group_id
  ,      p_soft_coding_keyflex_id
  ,      p_vacancy_id
  ,      l_assignment_sequence
  ,      p_assignment_type
  ,      nvl(p_manager_flag,'N')
  ,      p_primary_flag
  ,      l_application_id
  ,      l_assignment_number
  ,      p_change_reason
  ,      p_date_probation_end
  ,      p_frequency
  ,      p_internal_address_line
  ,      fnd_number.canonical_to_number(p_normal_hours)
  ,      l_period_of_service_id
  ,      p_probation_period
  ,      p_probation_unit
  ,      p_recruiter_id
  ,      p_special_ceiling_step_id
  ,      p_supervisor_id
  ,      p_recruitment_activity_id
  ,      p_person_referred_by_id
  ,      p_source_organization_id
  ,      p_time_normal_finish
  ,      p_time_normal_start
  ,      SYSDATE
  ,      0
  ,      0
  ,      0
  ,      SYSDATE);
  --
  -- Add effective start and end dates.
  --SASmith 2-APR-98
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',8);
  hr_assignment.load_budget_values(l_assignment_id
                                  ,p_business_group_id
                                  ,0
                                  ,0
                                  ,p_effective_start_date
                                  ,p_effective_end_date);
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',10);
  if p_assignment_type = 'E'  then null;
  else                                       -- assignment type = 'A'
  hr_utility.set_location('per_db_per_additional.insert_assignment',15);
  begin
  SELECT letter_type_id
  INTO   l_letter_type_id
  FROM   per_letter_gen_statuses
  WHERE  business_group_id + 0     = p_business_group_id
  AND    assignment_status_type_id = p_assignment_status_type_id
  AND    enabled_flag              = 'Y';
  --
  exception when NO_DATA_FOUND then null;
  end;
  --
  hr_utility.set_location('per_db_per_additional.insert_assignment',20);
  if l_letter_type_id IS NOT NULL then
   begin
     hr_utility.set_location('per_db_per_additional.insert_assignment',25);
     SELECT letter_request_id
     INTO   l_letter_request_id
     FROM   per_letter_requests
     WHERE  letter_type_id    = l_letter_type_id
     AND    business_group_id + 0 = p_business_group_id
     AND    vacancy_id 		= p_vacancy_id
     AND    request_status    = 'PENDING' ;
   --
   exception when NO_DATA_FOUND then null;
   end;
   --
   hr_utility.set_location('per_db_per_additional.insert_assignment',30);
   if l_letter_request_id IS NOT NULL then null;
   else
      hr_utility.set_location('per_db_per_additional.insert_assignment',35);
      SELECT per_letter_requests_s.nextval
      INTO   l_letter_request_id
      FROM   sys.dual;
      --
      hr_utility.set_location('per_db_per_additional.insert_assignment',40);
      INSERT INTO per_letter_requests
      (letter_request_id
      ,business_group_id
      ,letter_type_id
      ,date_from
      ,request_status
      ,auto_or_manual
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date
      ,vacancy_id)
      VALUES
      (l_letter_request_id
      ,p_business_group_id
      ,l_letter_type_id
      ,p_effective_start_date
      ,'PENDING'
      ,'AUTO'
      ,SYSDATE
      ,0
      ,0
      ,0
      ,SYSDATE
      ,p_vacancy_id);
      --
   end if;
   --
   hr_utility.set_location('per_db_per_additional.insert_assignment',45);
   INSERT INTO per_letter_request_lines
   (letter_request_line_id
   ,business_group_id
   ,letter_request_id
   ,person_id
   ,assignment_id
   ,assignment_status_type_id
   ,date_from
   ,last_update_date
   ,last_updated_by
   ,last_update_login
   ,created_by
   ,creation_date)
   VALUES
   (per_letter_request_lines_s.nextval
   ,p_business_group_id
   ,l_letter_request_id
   ,p_person_id
   ,l_assignment_id
   ,p_assignment_status_type_id
   ,p_effective_start_date
   ,SYSDATE
   ,0
   ,0
   ,0
   ,SYSDATE);
   --
   end if;   -- letter type not null
   --
  end if;   -- assignment type = 'A'
  --
  return l_assignment_id;
--
end insert_assignment;
--
--
FUNCTION create_applicant
(p_effective_start_date           DATE      default null
,p_effective_end_date             DATE      default null
,p_business_group                 VARCHAR2
,p_last_name                      VARCHAR2
,p_applicant_number               VARCHAR2  default null
,p_organization                   VARCHAR2  default null
,p_position                       VARCHAR2  default null
,p_job                            VARCHAR2  default null
,p_grade                          VARCHAR2  default null
,p_location                       VARCHAR2  default null
,p_vacancy                        VARCHAR2  default null
,p_people_group_id                NUMBER    default null
,p_start_date                     DATE      default null
,p_date_of_birth                  DATE      default null
,p_first_name                     VARCHAR2  default null
,p_known_as                       VARCHAR2  default null
,p_marital_status                 VARCHAR2  default 'S'
,p_middle_names                   VARCHAR2  default null
,p_nationality                    VARCHAR2  default null
,p_previous_last_name             VARCHAR2  default null
,p_registered_disabled_flag       VARCHAR2  default 'N'
,p_sex                            VARCHAR2  default 'M'
,p_title                          VARCHAR2  default 'MR.'
,p_work_telephone                 VARCHAR2  default null
,p_frequency                      VARCHAR2  default 'W'
,p_normal_hours                   VARCHAR2  default '37.5'
,p_current_employer               VARCHAR2  default null
,p_projected_hire_date            DATE      default null
,p_recruitment_activity_id        NUMBER    default null
,p_person_referred_by_id          NUMBER    default null
,p_source_organization_id         NUMBER    default null
,p_time_normal_start              VARCHAR2  default '08:00'
,p_time_normal_finish             VARCHAR2  default '17:30'
,p_probation_period               VARCHAR2  default null
,p_probation_unit                 VARCHAR2  default null
,p_recruiter_id                   NUMBER    default null
,p_internal_address_line          VARCHAR2  default null
,p_change_reason                  VARCHAR2  default null)
return NUMBER
IS
--
-- local variables
   --
   l_business_group_id        NUMBER(15);
   l_person_type_id           NUMBER(15);
   l_person_id                NUMBER(15);
   l_full_name                VARCHAR2(240);
   l_current_applicant_flag   VARCHAR2(1);
   l_current_employee_flag    VARCHAR2(1);
   l_current_emp_or_apl_flag  VARCHAR2(1);
   l_effective_start_date     DATE;
   l_effective_end_date       DATE;
   l_date_of_birth            DATE;
   l_application_id           NUMBER(15);
   l_assignment_id            NUMBER(15);
   l_assignment_status_type_id NUMBER(15);
--
   l_job_id                   NUMBER(15) := null;
   l_position_id              NUMBER(15) := null;
   l_grade_id                 NUMBER(15) := null;
   l_organization_id          NUMBER(15) := null;
   l_vacancy_id               NUMBER(15) := null;
   l_location_id              NUMBER(15) := null;
   l_recruiter_id             NUMBER(15) := null;
   l_people_group_id          NUMBER(15) := null;
   l_recruitment_activity_id  NUMBER;
   l_person_referred_by_id    NUMBER;
   l_source_organization_id   NUMBER;
   l_people_group_structure   NUMBER;
--
--
begin  -- FUNCTION create_applicant
--
--
  hr_utility.set_location('per_db_per_additional.create_applicant',1);
--
  SELECT business_group_id
  ,      people_group_structure
  INTO   l_business_group_id
  ,      l_people_group_structure
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',2);
--
  SELECT person_type_id
  INTO   l_person_type_id
  FROM   per_person_types
  WHERE  business_group_id   = l_business_group_id  --Bug fix 3648477
  AND    system_person_type = 'APL'
  AND    default_flag       = 'Y';
--
  hr_utility.set_location('per_db_per_additional.create_applicant',4);
  SELECT assignment_status_type_id
  INTO   l_assignment_status_type_id
  FROM   per_ass_status_type_amends
  WHERE  business_group_id + 0 = l_business_group_id
  AND    default_flag      = 'Y'
  AND    per_system_status = 'ACTIVE_APL'
  UNION
  SELECT ast.assignment_status_type_id
  FROM   per_assignment_status_types ast
  WHERE  nvl(ast.business_group_id,l_business_group_id)
           = l_business_group_id
  AND    ast.default_flag = 'Y'
  AND    ast.per_system_status = 'ACTIVE_APL'
  AND NOT EXISTS (SELECT null
                  FROM   per_ass_status_type_amends ast1
                  WHERE  ast1.business_group_id + 0 = l_business_group_id
                  AND    ast1.default_flag      = 'Y'
                  AND    ast1.assignment_status_type_id =
                              ast.assignment_status_type_id) ;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',6);
  l_current_employee_flag   := null;
  l_current_applicant_flag  := 'Y';
  l_current_emp_or_apl_flag := 'Y';
  l_effective_start_date := nvl(p_effective_start_date, trunc(SYSDATE));
  l_effective_end_date   := nvl(p_effective_end_date,
                                to_date('4712/12/31','YYYY/MM/DD'));
  l_date_of_birth        := nvl(p_date_of_birth,
                                to_date('1958/01/01','YYYY/MM/DD'));
--
  hr_utility.set_location('per_db_per_additional.create_applicant',8);
--
  l_person_id := insert_person(l_effective_start_date
                              ,l_effective_end_date
                              ,l_business_group_id
                              ,l_person_type_id
                              ,p_last_name
                              ,p_applicant_number
                              ,l_current_applicant_flag
                              ,l_current_employee_flag
                              ,l_current_emp_or_apl_flag
                              ,null
                              ,l_date_of_birth
                              ,null
                              ,null
                              ,p_first_name
                              ,p_known_as
                              ,p_marital_status
                              ,p_middle_names
                              ,p_nationality
                              ,null
                              ,p_previous_last_name
                              ,p_registered_disabled_flag
                              ,p_sex
                              ,p_title
                              ,p_work_telephone );
--
--
--
  hr_utility.set_location('per_db_per_additional.create_applicant',10);
  l_application_id := insert_application(l_person_id
                            ,l_business_group_id
                            ,l_effective_start_date
                            ,null
                            ,p_current_employer
                            ,p_projected_hire_date
                            ,null);
--
-- PTU : Following code added for PTU

    hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => l_effective_start_date
          ,p_person_id       => l_person_id
          ,p_person_type_id  => l_person_type_id
        );

-- End of PTU Changes

--
  hr_utility.set_location('per_db_per_additional.create_applicant',12);
  --
  -- WWBUG 1833930, changed hr_locations to hr_locations_all
  --
  if p_vacancy IS NULL then
  --
   if p_location IS NULL then null;
   else
    hr_utility.set_location('per_db_per_additional.create_applicant',14);
    SELECT location_id
    INTO   l_location_id
    FROM   hr_locations_all
    WHERE  location_code =  p_location
    AND    l_effective_start_date <= nvl(inactive_date,to_date('4712/12/31',
                                                             'YYYY/MM/DD'));
   end if;
--
--
  hr_utility.set_location('per_db_per_additional.create_applicant',16);
  if p_position IS NULL then  -- job and organization
  --
   if p_organization IS NULL then
      l_organization_id := l_business_group_id;
   else hr_utility.set_location('per_db_per_additional.create_applicant',18);
     SELECT organization_id
     ,      location_id
     INTO   l_organization_id
     ,      l_location_id
     FROM   hr_organization_units
     WHERE  name = p_organization
     AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  hr_utility.set_location('per_db_per_additional.create_applicant',1);
   if p_job IS NULL then null;
   else hr_utility.set_location('per_db_per_additional.create_applicant',20);
        SELECT job_id
        INTO   l_job_id
        FROM   per_jobs_v
        WHERE  name = p_job
        AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  else  -- p_position is not null (position overrides job and org)
        hr_utility.set_location('per_db_per_additional.create_applicant',22);
        SELECT pos.position_id
        ,      pos.job_id
        ,      pos.organization_id
        ,      nvl(pos.location_id,nvl(org.location_id,l_location_id))
        INTO   l_position_id
        ,      l_job_id
        ,      l_organization_id
        ,      l_location_id
        FROM   per_organization_units  org
        ,      per_positions           pos
        WHERE  pos.name = p_position
        AND    pos.business_group_id + 0 = l_business_group_id
        AND    pos.organization_id   = org.organization_id
        AND    l_effective_start_date BETWEEN pos.date_effective
                                   AND nvl(pos.date_end,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
--
   if p_grade IS NULL then null;
   else
    hr_utility.set_location('per_db_per_additional.create_applicant',24);
    SELECT grade_id
    INTO   l_grade_id
    FROM   per_grades_vl
    WHERE  name =  p_grade
    AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  else  -- p_vacancy is not null (vacancy overrides all other columns)
    --
    hr_utility.set_location('per_db_per_additional.create_applicant',26);
    SELECT vacancy_id
    ,      position_id
    ,      job_id
    ,      organization_id
    ,      grade_id
    ,      people_group_id
    ,      location_id
    INTO   l_vacancy_id
    ,      l_position_id
    ,      l_job_id
    ,      l_organization_id
    ,      l_grade_id
    ,      l_people_group_id
    ,      l_location_id
    FROM   per_vacancies
    WHERE  name = p_vacancy
    AND    l_effective_start_date BETWEEN date_from
                        AND nvl(date_to,to_date('4712/12/31','YYYY/MM/DD'));
    --
    hr_utility.set_location('per_db_per_additional.create_applicant',28);
    if l_organization_id IS NULL then
       l_organization_id := l_business_group_id;  -- mandatory column
    end if;
  --
    hr_utility.set_location('per_db_per_additional.create_applicant',30);
    if p_recruitment_activity_id IS NULL then
       l_recruitment_activity_id := null;
    else
      hr_utility.set_location('per_db_per_additional.create_applicant',32);
      SELECT recruitment_activity_id
      INTO   l_recruitment_activity_id
      FROM   per_recruitment_activity_for
      WHERE  business_group_id + 0 = l_business_group_id
      AND    vacancy_id        = l_vacancy_id;
    end if;
  --
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',34);
  if p_people_group_id IS NULL then
     l_people_group_id := null;
  else
    SELECT people_group_id
    INTO   l_people_group_id
    FROM   pay_people_groups
    WHERE  people_group_id = p_people_group_id
    AND    id_flex_num     = l_people_group_structure;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',36);
  if p_source_organization_id IS NULL then null;
  else
  SELECT organization_id
  INTO   l_source_organization_id
  FROM   per_organization_units
  WHERE  organization_id = p_source_organization_id
  AND    business_group_id + 0 = l_business_group_id
  AND    l_effective_start_date BETWEEN date_from
                         AND nvl(date_to,to_date('4712/12/31','YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',38);
  if p_recruiter_id IS NULL then null;
  else
  SELECT person_id
  INTO   l_recruiter_id
  FROM   per_people_f
  WHERE  (business_group_id = l_business_group_id or
       nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y')
  AND    person_id         = p_recruiter_id
  AND    current_employee_flag = 'Y'
  AND    l_effective_start_date BETWEEN effective_start_date
                                AND     effective_end_date;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',40);
  if p_person_referred_by_id IS NULL then null;
  else
  SELECT person_id
  INTO   l_person_referred_by_id
  FROM   per_people_f
  WHERE  (business_group_id = l_business_group_id or
         nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y')
  AND    person_id         = p_person_referred_by_id
  AND    current_employee_flag = 'Y'
  AND    l_effective_start_date BETWEEN effective_start_date
                                AND     effective_end_date;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_applicant',42);
  l_assignment_id := insert_assignment(l_effective_start_date
                     , l_effective_end_date
                     , l_business_group_id
                     , l_person_id
                     , 'A'
                     , l_organization_id
                     , l_grade_id
                     , l_job_id
                     , l_position_id
                     , null
                     , l_location_id
                     , l_vacancy_id
                     , l_people_group_id
                     , null
                     , l_assignment_status_type_id
                     , 'Y'
                     , null
                     , p_change_reason
                     , null
                     , p_frequency
                     , p_internal_address_line
                     , p_normal_hours
                     , null
                     , null
                     , l_recruiter_id
                     , null
                     , null
                     , l_recruitment_activity_id
                     , l_person_referred_by_id
                     , l_source_organization_id
                     , p_time_normal_finish
                     , p_time_normal_start);
--
  hr_utility.set_location('per_db_per_additional.create_applicant',45);

--
  return l_person_id;
--
--
--
end create_applicant;
--
--
FUNCTION create_employee
(p_effective_start_date           DATE      default null
,p_effective_end_date             DATE      default null
,p_business_group                 VARCHAR2
,p_last_name                      VARCHAR2
,p_national_identifier            VARCHAR2
,p_employee_number                VARCHAR2  default null
,p_tax_code                       VARCHAR2  default '50T'
,p_tax_basis                      VARCHAR2  default 'C'  -- cumulative
,p_organization                   VARCHAR2  default null
,p_position                       VARCHAR2  default null
,p_job                            VARCHAR2  default null
,p_grade                          VARCHAR2  default null
,p_payroll                        VARCHAR2  default null
,p_location                       VARCHAR2  default null
,p_people_group_id                NUMBER    default null
,p_cost_allocation_keyflex_id     NUMBER    default null
,p_start_date                     DATE      default null
,p_date_of_birth                  DATE      default null
,p_employee_data_verified         DATE      default null
,p_expense_chk_send_to_address    VARCHAR2  default 'H'
,p_first_name                     VARCHAR2  default null
,p_known_as                       VARCHAR2  default null
,p_marital_status                 VARCHAR2  default 'S'
,p_middle_names                   VARCHAR2  default null
,p_nationality                    VARCHAR2  default null
,p_previous_last_name             VARCHAR2  default null
,p_registered_disabled_flag       VARCHAR2  default 'N'
,p_sex                            VARCHAR2  default 'M'
,p_title                          VARCHAR2  default 'MR.'
,p_work_telephone                 VARCHAR2  default null
,p_frequency                      VARCHAR2  default 'W'
,p_normal_hours                   VARCHAR2  default '37.5'
,p_time_normal_start              VARCHAR2  default '08:00'
,p_time_normal_finish             VARCHAR2  default '17:30'
,p_probation_period               VARCHAR2  default null
,p_probation_unit                 VARCHAR2  default null
,p_date_probation_end             DATE      default null
,p_manager_flag                   VARCHAR2  default 'N'
,p_supervisor_id                  NUMBER    default null
,p_special_ceiling_step_id        NUMBER    default null
,p_internal_address_line          VARCHAR2  default null
,p_change_reason                  VARCHAR2  default null)
return NUMBER
IS
--
-- local variables
   --
   l_business_group_id        NUMBER;
   l_person_type_id           NUMBER;
   l_person_id                NUMBER;
   l_full_name                VARCHAR2(240);
   l_current_applicant_flag   VARCHAR2(1);
   l_current_employee_flag    VARCHAR2(1);
   l_current_emp_or_apl_flag  VARCHAR2(1);
   l_effective_start_date     DATE;
   l_effective_end_date       DATE;
   l_date_of_birth            DATE;
   l_period_of_service_id     NUMBER;
   l_assignment_id            NUMBER;
   l_assignment_status_type_id NUMBER;
--
   l_job_id                   NUMBER := null;
   l_position_id              NUMBER := null;
   l_grade_id                 NUMBER := null;
   l_organization_id          NUMBER := null;
   l_payroll_id               NUMBER := null;
   l_location_id              NUMBER := null;
   l_supervisor_id            NUMBER := null;
   l_special_ceiling_step_id  NUMBER := null;   -- not yet validated
   l_cost_allocation_keyflex_id NUMBER;
   l_cost_allocation_structure  NUMBER;
   l_people_group_id          NUMBER;
   l_people_group_structure   NUMBER;
--
--
begin  -- FUNCTION create_employee
--
--
  hr_utility.set_location('per_db_per_additional.create_employee',1);
--
  SELECT business_group_id
  ,      people_group_structure
  ,      cost_allocation_structure
  INTO   l_business_group_id
  ,      l_people_group_structure
  ,      l_cost_allocation_structure
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  hr_utility.set_location('per_db_per_additional.create_employee',2);
--
  SELECT person_type_id
  INTO   l_person_type_id
  FROM   per_person_types
  WHERE  business_group_id  = l_business_group_id --Bug fix 3648477
  AND    system_person_type = 'EMP'
  AND    default_flag       = 'Y';
--
  hr_utility.set_location('per_db_per_additional.create_employee',4);
  SELECT assignment_status_type_id
  INTO   l_assignment_status_type_id
  FROM   per_ass_status_type_amends
  WHERE  business_group_id + 0 = l_business_group_id
  AND    default_flag      = 'Y'
  AND    per_system_status = 'ACTIVE_ASSIGN'
  UNION
  SELECT ast.assignment_status_type_id
  FROM   per_assignment_status_types ast
  WHERE  nvl(ast.business_group_id,l_business_group_id)
           = l_business_group_id
  AND    ast.default_flag = 'Y'
  AND    ast.per_system_status = 'ACTIVE_ASSIGN'
  AND NOT EXISTS (SELECT null
                  FROM   per_ass_status_type_amends ast1
                  WHERE  ast1.business_group_id + 0 = l_business_group_id
                  AND    ast1.default_flag      = 'Y'
                  AND    ast1.assignment_status_type_id =
                              ast.assignment_status_type_id) ;
--
  hr_utility.set_location('per_db_per_additional.create_employee',6);
  l_current_employee_flag   := 'Y';
  l_current_applicant_flag  := null;
  l_current_emp_or_apl_flag := 'Y';
  l_effective_start_date := nvl(p_effective_start_date, trunc(SYSDATE));
  l_effective_end_date   := nvl(p_effective_end_date,
                                to_date('4712/12/31','YYYY/MM/DD'));
  l_date_of_birth        := nvl(p_date_of_birth,
                                to_date('1958/01/01','YYYY/MM/DD'));
--
  hr_utility.set_location('per_db_per_additional.create_employee',8);
--
  l_person_id := insert_person(l_effective_start_date
                              ,l_effective_end_date
                              ,l_business_group_id
                              ,l_person_type_id
                              ,p_last_name
                              ,null
                              ,l_current_applicant_flag
                              ,l_current_employee_flag
                              ,l_current_emp_or_apl_flag
                              ,p_employee_data_verified
                              ,l_date_of_birth
                              ,p_employee_number
                              ,p_expense_chk_send_to_address
                              ,p_first_name
                              ,p_known_as
                              ,p_marital_status
                              ,p_middle_names
                              ,p_nationality
                              ,p_national_identifier
                              ,p_previous_last_name
                              ,p_registered_disabled_flag
                              ,p_sex
                              ,p_title
                              ,p_work_telephone );
--
--
-- PTU : Following code added for PTU

    hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => l_effective_start_date
          ,p_person_id       => l_person_id
          ,p_person_type_id  => l_person_type_id
        );

-- End of PTU Changes
--
  hr_utility.set_location('per_db_per_additional.create_employee',10);
  l_period_of_service_id := insert_period_of_service(l_person_id
                            ,l_business_group_id
                            ,l_effective_start_date
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null);
--
  hr_utility.set_location('per_db_per_additional.create_employee',12);
-- Validate position before using
  --
  -- WWBUG 1833930, changed hr_locations to hr_locations_all
  --
  if p_location IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_employee',14);
  SELECT location_id
  INTO   l_location_id
  FROM   hr_locations_all
  WHERE  location_code =  p_location
  AND    l_effective_start_date <= nvl(inactive_date,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',16);
  if p_position IS NULL then  -- position overrides job and organization
  --
   if p_organization IS NULL then
      hr_utility.set_location('per_db_per_additional.create_employee',18);
      l_organization_id := l_business_group_id;
   else hr_utility.set_location('per_db_per_additional.create_employee',20);
     SELECT organization_id
     ,      nvl(location_id, l_location_id)
     INTO   l_organization_id
     ,      l_location_id
     FROM   hr_organization_units
     WHERE  name = p_organization
     AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
   hr_utility.set_location('per_db_per_additional.create_employee',22);
   if p_job IS NULL then null;
   else hr_utility.set_location('per_db_per_additional.create_employee',24);
        SELECT job_id
        INTO   l_job_id
        FROM   per_jobs_v
        WHERE  name = p_job
        AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  else  hr_utility.set_location('per_db_per_additional.create_employee',26);
        SELECT pos.position_id
        ,      pos.job_id
        ,      pos.organization_id
        ,      nvl(pos.location_id,nvl(org.location_id,l_location_id))
        INTO   l_position_id
        ,      l_job_id
        ,      l_organization_id
        ,      l_location_id
        FROM   per_organization_units org
        ,      per_positions          pos
        WHERE  pos.name = p_position
        AND    pos.business_group_id + 0 = l_business_group_id
        AND    pos.organization_id   = org.organization_id
     AND    l_effective_start_date BETWEEN pos.date_effective
                                   AND nvl(pos.date_end,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',28);
  if p_grade IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_employee',30);
  SELECT grade_id
  INTO   l_grade_id
  FROM   per_grades_vl
  WHERE  name =  p_grade
  AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',32);
  if p_payroll IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_employee',34);
  SELECT pa.payroll_id
  INTO   l_payroll_id
  FROM   pay_payrolls_f pa
  WHERE  pa.payroll_name = p_payroll
  AND    pa.business_group_id + 0 = l_business_group_id
  AND    l_effective_start_date BETWEEN pa.effective_start_date
                                AND     pa.effective_end_date
  AND    l_effective_end_date <= (SELECT max(pa1.effective_end_date)
                                  FROM   pay_payrolls_f pa1
                                  WHERE  pa1.business_group_id + 0 =
                                             l_business_group_id
                                  AND    pa1.payroll_id = pa.payroll_id) ;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',36);
  if p_supervisor_id IS NULL then null;
  else
  SELECT person_id
  INTO   l_supervisor_id
  FROM   per_people_f
  WHERE  (business_group_id  = l_business_group_id OR
         nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
  AND    person_id         = p_supervisor_id
  AND    current_employee_flag = 'Y'
  AND    l_effective_start_date BETWEEN effective_start_date
                                AND     effective_end_date;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',38);
  if p_cost_allocation_keyflex_id IS NULL then
     l_cost_allocation_keyflex_id := null;
  else
  hr_utility.set_location('per_db_per_additional.create_employee',40);
  SELECT cost_allocation_keyflex_id
  INTO   l_cost_allocation_keyflex_id
  FROM   pay_cost_allocation_keyflex
  WHERE  cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
  AND    id_flex_num                = l_cost_allocation_structure;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_employee',42);
  if p_people_group_id IS NULL then
     l_people_group_id := null;
  else
  hr_utility.set_location('per_db_per_additional.create_employee',44);
  SELECT people_group_id
  INTO   l_people_group_id
  FROM   pay_people_groups
  WHERE  people_group_id = p_people_group_id
  AND    id_flex_num     = l_people_group_structure;
  end if;
--
--
  hr_utility.set_location('per_db_per_additional.create_employee',46);
  l_assignment_id := insert_assignment(l_effective_start_date
                     , l_effective_end_date
                     , l_business_group_id
                     , l_person_id
                     , 'E'
                     , l_organization_id
                     , l_grade_id
                     , l_job_id
                     , l_position_id
                     , l_payroll_id
                     , l_location_id
                     , l_cost_allocation_keyflex_id
                     , l_people_group_id
                     , null
                     , l_assignment_status_type_id
                     , 'Y'
                     , p_manager_flag
                     , p_change_reason
                     , p_date_probation_end
                     , p_frequency
                     , p_internal_address_line
                     , p_normal_hours
                     , p_probation_period
                     , p_probation_unit
                     , null
                     , l_special_ceiling_step_id
                     , l_supervisor_id
                     , null
                     , null
                     , null
                     , p_time_normal_finish
                     , p_time_normal_start);
--
--
  return l_person_id;
--
--
--
end create_employee;
--
--
FUNCTION create_other
  (p_effective_start_date           DATE      default null
  ,p_effective_end_date             DATE      default null
  ,p_business_group                 VARCHAR2
  ,p_last_name                      VARCHAR2
  ,p_date_of_birth                  DATE      default null
  ,p_expense_chk_send_to_address    VARCHAR2  default 'H'
  ,p_first_name                     VARCHAR2  default null
  ,p_known_as                       VARCHAR2  default null
  ,p_marital_status                 VARCHAR2  default 'S'
  ,p_middle_names                   VARCHAR2  default null
  ,p_nationality                    VARCHAR2  default null
  ,p_national_identifier            VARCHAR2
  ,p_previous_last_name             VARCHAR2  default null
  ,p_registered_disabled_flag       VARCHAR2  default 'N'
  ,p_sex                            VARCHAR2  default null
  ,p_title                          VARCHAR2  default null
  ,p_work_telephone                 VARCHAR2  default null)
  return NUMBER
  IS
  --
  -- local variables
     --
     l_business_group_id        NUMBER;
     l_person_type_id           NUMBER;
     l_person_id                NUMBER;
     l_current_applicant_flag   VARCHAR2(1);
     l_current_employee_flag    VARCHAR2(1);
     l_current_emp_or_apl_flag  VARCHAR2(1);
     l_effective_start_date     DATE;
     l_effective_end_date       DATE;
  --
  --
  --
  begin  -- FUNCTION create_other
  --
  --
    hr_utility.set_location('per_db_per_additional.create_other',1);
  --
    SELECT business_group_id
    INTO   l_business_group_id
    FROM   per_business_groups
    WHERE  name = p_business_group;
  --
    hr_utility.set_location('per_db_per_additional.create_other',2);
  --
    SELECT person_type_id
    INTO   l_person_type_id
    FROM   per_person_types
    WHERE  business_group_id  = l_business_group_id  --Bug fix 3648477
    AND    system_person_type = 'OTHER'
    AND    default_flag       = 'Y';
  --
    l_current_employee_flag   := null;
    l_current_applicant_flag  := null;
    l_current_emp_or_apl_flag := null;
    l_effective_start_date := nvl(p_effective_start_date,
                                  trunc(SYSDATE));
    l_effective_end_date   := nvl(p_effective_end_date,
                                  to_date('4712/12/31','YYYY/MM/DD'));
  --
    hr_utility.set_location('per_db_per_additional.create_other',3);
  --
    l_person_id := insert_person(l_effective_start_date
                                ,l_effective_end_date
                                ,l_business_group_id
                                ,l_person_type_id
                                ,p_last_name
                                ,null
                                ,l_current_applicant_flag
                                ,l_current_employee_flag
                                ,l_current_emp_or_apl_flag
                                ,null
                                ,p_date_of_birth
                                ,null
                                ,p_expense_chk_send_to_address
                                ,p_first_name
                                ,p_known_as
                                ,p_marital_status
                                ,p_middle_names
                                ,p_nationality
                                ,p_national_identifier
                                ,p_previous_last_name
                                ,p_registered_disabled_flag
                                ,p_sex
                                ,p_title
                                ,p_work_telephone );
--
--
-- PTU : Following code added for PTU

    hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => l_effective_start_date
          ,p_person_id       => l_person_id
          ,p_person_type_id  => l_person_type_id
        );

-- End of PTU Changes
  --
  --
    return l_person_id;
  --
  --
  --
end create_other;
--
--
FUNCTION create_secondary_assign
  (p_effective_start_date        DATE     DEFAULT null
  ,p_effective_end_date          DATE     DEFAULT null
  ,p_business_group              VARCHAR2
  ,p_person_id                   NUMBER
  ,p_assignment_type             VARCHAR2
  ,p_organization                VARCHAR2 DEFAULT null
  ,p_grade                       VARCHAR2 DEFAULT null
  ,p_job                         VARCHAR2 DEFAULT null
  ,p_position                    VARCHAR2 DEFAULT null
  ,p_payroll                     VARCHAR2 DEFAULT null
  ,p_location                    VARCHAR2 DEFAULT null
  ,p_vacancy                     VARCHAR2 DEFAULT null
  ,p_people_group_id             NUMBER   DEFAULT null
  ,p_cost_allocation_keyflex_id  NUMBER   DEFAULT null
  ,p_manager_flag                VARCHAR2 DEFAULT null
  ,p_change_reason               VARCHAR2 DEFAULT null
  ,p_date_probation_end          DATE     DEFAULT null
  ,p_frequency                   VARCHAR2 DEFAULT 'W'
  ,p_internal_address_line       VARCHAR2 DEFAULT null
  ,p_normal_hours                VARCHAR2 DEFAULT '37.5'
  ,p_probation_period            VARCHAR2 DEFAULT null
  ,p_probation_unit              VARCHAR2 DEFAULT null
  ,p_recruiter_id                NUMBER   DEFAULT null
  ,p_special_ceiling_step_id     NUMBER   DEFAULT null
  ,p_supervisor_id               NUMBER   DEFAULT null
  ,p_recruitment_activity_id     NUMBER   DEFAULT null
  ,p_person_referred_by_id       NUMBER   DEFAULT null
  ,p_source_organization_id      NUMBER   DEFAULT null
  ,p_time_normal_finish          VARCHAR2 DEFAULT '08:00'
  ,p_time_normal_start           VARCHAR2 DEFAULT '17:30')
return NUMBER IS
--
  l_type_check                VARCHAR2(1) := null;
  l_assignment_id             NUMBER;
  l_assignment_status_type_id NUMBER;
  l_effective_start_date      DATE;
  l_effective_end_date        DATE;
  l_business_group_id         NUMBER;
  l_organization_id           NUMBER;
  l_grade_id                  NUMBER;
  l_job_id                    NUMBER;
  l_position_id               NUMBER;
  l_payroll_id                NUMBER;
  l_location_id               NUMBER;
  l_vacancy_id                NUMBER;
  l_people_group_id           NUMBER;
  l_recruiter_id              NUMBER;
  l_supervisor_id             NUMBER;
  l_cost_allocation_structure NUMBER;
  l_cost_allocation_keyflex_id NUMBER;
  l_people_group_structure    NUMBER;
  l_recruitment_activity_id   NUMBER;
  l_person_referred_by_id     NUMBER;
  l_source_organization_id    NUMBER;
--
begin
  --
  --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',1);
  SELECT business_group_id
  ,      cost_allocation_structure
  ,      people_group_structure
  INTO   l_business_group_id
  ,      l_cost_allocation_structure
  ,      l_people_group_structure
  FROM   per_business_groups
  WHERE  name = p_business_group;
  --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',2);
  l_effective_start_date := nvl(p_effective_start_date,trunc(SYSDATE));
  l_effective_end_date   := nvl(p_effective_end_date,
                                to_date('4712/12/31','YYYY/MM/DD'));
  --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',3);
  SELECT 'Y'
  INTO   l_type_check
  FROM   per_people_f pp
  WHERE  pp.person_id = p_person_id
  AND    l_effective_start_date BETWEEN pp.effective_start_date
                                AND     pp.effective_end_date
  AND  ((p_assignment_type = 'E'
     AND pp.current_employee_flag = 'Y')
   OR   (p_assignment_type = 'A'
     AND pp.current_applicant_flag = 'Y'));
  --
  --
  if p_assignment_type = 'E' then     -- Employee
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',4);
  SELECT assignment_status_type_id
  INTO   l_assignment_status_type_id
  FROM   per_ass_status_type_amends
  WHERE  business_group_id + 0 = l_business_group_id
  AND    default_flag      = 'Y'
  AND    per_system_status = 'ACTIVE_ASSIGN'
  UNION
  SELECT ast.assignment_status_type_id
  FROM   per_assignment_status_types ast
  WHERE  nvl(ast.business_group_id,l_business_group_id)
           = l_business_group_id
  AND    ast.default_flag = 'Y'
  AND    ast.per_system_status = 'ACTIVE_ASSIGN'
  AND NOT EXISTS (SELECT null
                  FROM   per_ass_status_type_amends ast1
                  WHERE  ast1.business_group_id + 0 = l_business_group_id
                  AND    ast1.default_flag      = 'Y'
                  AND    ast1.assignment_status_type_id =
                              ast.assignment_status_type_id) ;
     --
  else                                -- Applicant
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',7);
  SELECT assignment_status_type_id
  INTO   l_assignment_status_type_id
  FROM   per_ass_status_type_amends
  WHERE  business_group_id + 0 = l_business_group_id
  AND    default_flag      = 'Y'
  AND    per_system_status = 'ACTIVE_APL'
  UNION
  SELECT ast.assignment_status_type_id
  FROM   per_assignment_status_types ast
  WHERE  nvl(ast.business_group_id,l_business_group_id)
           = l_business_group_id
  AND    ast.default_flag = 'Y'
  AND    ast.per_system_status = 'ACTIVE_APL'
  AND NOT EXISTS (SELECT null
                  FROM   per_ass_status_type_amends ast1
                  WHERE  ast1.business_group_id + 0 = l_business_group_id
                  AND    ast1.default_flag      = 'Y'
                  AND    ast1.assignment_status_type_id =
                              ast.assignment_status_type_id) ;
     --
  end if;
  --
  --
  if p_assignment_type = 'E' then
  --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',9);
-- Validate position before using
  --
  -- WWBUG 1833930, changed hr_locations to hr_locations_all
  --
  if p_location IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',11);
  SELECT location_id
  INTO   l_location_id
  FROM   hr_locations_all
  WHERE  location_code =  p_location
  AND    l_effective_start_date <= nvl(inactive_date,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  if p_position IS NULL then  -- position overrides job and organization
  --
   if p_organization IS NULL then
      hr_utility.set_location('per_db_per_additional.create_secondary_assign',13);
      l_organization_id := l_business_group_id;
   else
     hr_utility.set_location('per_db_per_additional.create_secondary_assign',15);
     SELECT organization_id
     ,      nvl(location_id, l_location_id)
     INTO   l_organization_id
     ,      l_location_id
     FROM   hr_organization_units
     WHERE  name = p_organization
     AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
   hr_utility.set_location('per_db_per_additional.create_secondary_assign',17);
   if p_job IS NULL then null;
   else
        hr_utility.set_location('per_db_per_additional.create_secondary_assign',19);
        SELECT job_id
        INTO   l_job_id
        FROM   per_jobs_v
        WHERE  name = p_job
        AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  else
        hr_utility.set_location('per_db_per_additional.create_secondary_assign',21);
        SELECT pos.position_id
        ,      pos.job_id
        ,      pos.organization_id
        ,      nvl(pos.location_id,nvl(org.location_id,l_location_id))
        INTO   l_position_id
        ,      l_job_id
        ,      l_organization_id
        ,      l_location_id
        FROM   per_organization_units org
        ,      per_positions          pos
        WHERE  pos.name = p_position
        AND    pos.business_group_id + 0 = l_business_group_id
        AND    pos.organization_id   = org.organization_id
     AND    l_effective_start_date BETWEEN pos.date_effective
                                   AND nvl(pos.date_end,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',23);
  if p_grade IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',25);
  SELECT grade_id
  INTO   l_grade_id
  FROM   per_grades_vl
  WHERE  name =  p_grade
  AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',27);
  if p_payroll IS NULL then null;
  else
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',29);
  SELECT pa.payroll_id
  INTO   l_payroll_id
  FROM   pay_payrolls_f pa
  WHERE  pa.payroll_name = p_payroll
  AND    pa.business_group_id + 0 = l_business_group_id
  AND    l_effective_start_date BETWEEN pa.effective_start_date
                                AND     pa.effective_end_date
  AND    l_effective_end_date <= (SELECT max(pa1.effective_end_date)
                                  FROM   pay_payrolls_f pa1
                                  WHERE  pa1.business_group_id + 0 =
                                             l_business_group_id
                                  AND    pa1.payroll_id = pa.payroll_id) ;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',31);
  if p_supervisor_id IS NULL then null;
  else
  SELECT person_id
  INTO   l_supervisor_id
  FROM   per_people_f
  WHERE  business_group_id + 0 = l_business_group_id
  AND    person_id         = p_supervisor_id
  AND    current_employee_flag = 'Y'
  AND    l_effective_start_date BETWEEN effective_start_date
                                AND     effective_end_date;
  end if;
--
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',33);
  if p_cost_allocation_keyflex_id IS NULL then
     l_cost_allocation_keyflex_id := null;
  else
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',35);
  SELECT cost_allocation_keyflex_id
  INTO   l_cost_allocation_keyflex_id
  FROM   pay_cost_allocation_keyflex
  WHERE  cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
  AND    id_flex_num                = l_cost_allocation_structure;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',37);
  if p_people_group_id IS NULL then
     l_people_group_id := null;
  else
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',39);
  SELECT people_group_id
  INTO   l_people_group_id
  FROM   pay_people_groups
  WHERE  people_group_id = p_people_group_id
  AND    id_flex_num     = l_people_group_structure;
  end if;
--
  else  -- if p_assignment_type = 'A'
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',41);
  --
  -- WWBUG 1833930, changed hr_locations to hr_locations_all
  --
  if p_vacancy IS NULL then
  --
   if p_location IS NULL then null;
   else
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',43);
    SELECT location_id
    INTO   l_location_id
    FROM   hr_locations_all
    WHERE  location_code =  p_location
    AND    l_effective_start_date <= nvl(inactive_date,to_date('4712/12/31',
                                                             'YYYY/MM/DD'));
   end if;
--
--
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',44);
  if p_position IS NULL then  -- job and organization
  --
   if p_organization IS NULL then
      l_organization_id := l_business_group_id;
   else
     hr_utility.set_location('per_db_per_additional.create_secondary_assign',46);
     SELECT organization_id
     ,      location_id
     INTO   l_organization_id
     ,      l_location_id
     FROM   hr_organization_units
     WHERE  name = p_organization
     AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
   if p_job IS NULL then null;
   else
        hr_utility.set_location('per_db_per_additional.create_secondary_assign',48);
        SELECT job_id
        INTO   l_job_id
        FROM   per_jobs_v
        WHERE  name = p_job
        AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
   --
  else  -- p_position is not null (position overrides job and org)
        hr_utility.set_location('per_db_per_additional.create_secondary_assign',50);
        SELECT pos.position_id
        ,      pos.job_id
        ,      pos.organization_id
        ,      nvl(pos.location_id,nvl(org.location_id,l_location_id))
        INTO   l_position_id
        ,      l_job_id
        ,      l_organization_id
        ,      l_location_id
        FROM   per_organization_units  org
        ,      per_positions           pos
        WHERE  pos.name = p_position
        AND    pos.business_group_id + 0 = l_business_group_id
        AND    pos.organization_id   = org.organization_id
        AND    l_effective_start_date BETWEEN pos.date_effective
                                   AND nvl(pos.date_end,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
--
   if p_grade IS NULL then null;
   else
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',52);
    SELECT grade_id
    INTO   l_grade_id
    FROM   per_grades_vl
    WHERE  name =  p_grade
    AND    business_group_id + 0 = l_business_group_id
     AND    l_effective_start_date BETWEEN date_from
                                   AND nvl(date_to,to_date('4712/12/31',
                                                           'YYYY/MM/DD'));
   end if;
--
  else  -- p_vacancy is not null (vacancy overrides all other columns)
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',54);
    SELECT vacancy_id
    ,      position_id
    ,      job_id
    ,      organization_id
    ,      grade_id
    ,      people_group_id
    ,      location_id
    INTO   l_vacancy_id
    ,      l_position_id
    ,      l_job_id
    ,      l_organization_id
    ,      l_grade_id
    ,      l_people_group_id
    ,      l_location_id
    FROM   per_vacancies
    WHERE  name = p_vacancy
    AND    l_effective_start_date BETWEEN date_from
                            AND nvl(date_to,to_date('4712/12/31','YYYY/MM/DD'));
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',56);
    if l_organization_id IS NULL then
       l_organization_id := l_business_group_id;  -- mandatory column
    end if;
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',58);
    if p_recruitment_activity_id IS NULL then
       l_recruitment_activity_id := null;
    else
      hr_utility.set_location('per_db_per_additional.create_secondary_assign',60);
      SELECT recruitment_activity_id
      INTO   l_recruitment_activity_id
      FROM   per_recruitment_activity_for
      WHERE  business_group_id + 0 = l_business_group_id
      AND    vacancy_id        = l_vacancy_id;
    end if;
  --
  end if;  -- vacancy not null within applicant
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',62);
    if p_source_organization_id IS NULL then null;
    else
    SELECT organization_id
    INTO   l_organization_id
    FROM   per_organization_units
    WHERE  organization_id = p_source_organization_id
    AND    business_group_id + 0 = l_business_group_id
    AND    l_effective_start_date BETWEEN date_from
                           AND nvl(date_to,to_date('4712/12/31','YYYY/MM/DD'));
    end if;
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',64);
    if p_recruiter_id IS NULL then null;
    else
    SELECT person_id
    INTO   l_recruiter_id
    FROM   per_people_f
    WHERE  (business_group_id = l_business_group_id or
         nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y')
    AND    person_id         = p_recruiter_id
    AND    current_employee_flag = 'Y'
    AND    l_effective_start_date BETWEEN effective_start_date
                                  AND     effective_end_date;
    end if;
    --
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',66);
    if p_person_referred_by_id IS NULL then null;
    else
    SELECT person_id
    INTO   l_person_referred_by_id
    FROM   per_people_f
    WHERE  (business_group_id = l_business_group_id or
          nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'Y')
    AND    person_id         = p_person_referred_by_id
    AND    current_employee_flag = 'Y'
    AND    l_effective_start_date BETWEEN effective_start_date
                                  AND     effective_end_date;
    end if;
 --
 end if;  -- split by assignment type
 --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',68);
  if p_people_group_id IS NULL then
     l_people_group_id := null;
  else
    hr_utility.set_location('per_db_per_additional.create_secondary_assign',70);
    SELECT people_group_id
    INTO   l_people_group_id
    FROM   pay_people_groups
    WHERE  people_group_id = p_people_group_id
    AND    id_flex_num     = l_people_group_structure;
  end if;
  --
  hr_utility.set_location('per_db_per_additional.create_secondary_assign',72);
  l_assignment_id := insert_assignment(l_effective_start_date
                                      ,l_effective_end_date
                                      ,l_business_group_id
                                      ,p_person_id
                                      ,p_assignment_type
                                      ,l_organization_id
                                      ,l_grade_id
                                      ,l_job_id
                                      ,l_position_id
                                      ,l_payroll_id
                                      ,l_location_id
                                      ,l_vacancy_id
                                      ,l_people_group_id
                                      ,l_cost_allocation_keyflex_id
                                      ,l_assignment_status_type_id
                                      ,'N'
                                      ,p_manager_flag
                                      ,p_change_reason
                                      ,p_date_probation_end
                                      ,p_frequency
                                      ,p_internal_address_line
                                      ,p_normal_hours
                                      ,p_probation_period
                                      ,p_probation_unit
                                      ,l_recruiter_id
                                      ,p_special_ceiling_step_id
                                      ,l_supervisor_id
                                      ,l_recruitment_activity_id
                                      ,l_person_referred_by_id
                                      ,l_source_organization_id
                                      ,p_time_normal_finish
                                      ,p_time_normal_start );
  --
  --
  return l_assignment_id;
--
end create_secondary_assign;
--
--
FUNCTION create_contact
  (p_effective_start_date           DATE      default null
  ,p_effective_end_date             DATE      default null
  ,p_employee_number                VARCHAR2
  ,p_contact_person_id              VARCHAR2  default null
  ,p_relationship                   VARCHAR2  default null
  ,p_primary_flag                   VARCHAR2  default 'N'
  ,p_dependent_flag                 VARCHAR2  default 'N'
  ,p_business_group                 VARCHAR2
  ,p_last_name                      VARCHAR2
  ,p_date_of_birth                  DATE      default null
  ,p_expense_chk_send_to_address    VARCHAR2  default 'H'
  ,p_first_name                     VARCHAR2  default null
  ,p_known_as                       VARCHAR2  default null
  ,p_marital_status                 VARCHAR2  default 'S'
  ,p_middle_names                   VARCHAR2  default null
  ,p_nationality                    VARCHAR2  default null
  ,p_national_identifier            VARCHAR2
  ,p_previous_last_name             VARCHAR2  default null
  ,p_registered_disabled_flag       VARCHAR2  default 'N'
  ,p_sex                            VARCHAR2  default null
  ,p_title                          VARCHAR2  default null
  ,p_work_telephone                 VARCHAR2  default null)
return NUMBER
IS
--
  l_contact_person_id       NUMBER;
  l_person_id               NUMBER;
  l_business_group_id       NUMBER;
  l_contact_relationship_id NUMBER;
  l_contact_type            VARCHAR2(10);
  l_effective_start_date    DATE;
  l_effective_end_date      DATE;
--
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
--
begin   -- function create_contact
--
--
  hr_utility.set_location('per_db_per_additional.create_contact',1);
  SELECT business_group_id
  INTO   l_business_group_id
  FROM   per_business_groups
  WHERE  name = p_business_group;
--
  l_effective_start_date := nvl(p_effective_start_date,trunc(SYSDATE));
  l_effective_end_date   := nvl(p_effective_end_date,
                                to_date('4712/12/31','YYYY/MM/DD'));
--
  hr_utility.set_location('per_db_per_additional.create_contact',2);
  SELECT pp.person_id
  INTO   l_person_id
  FROM   per_periods_of_service pos
  ,      per_people_f pp
  WHERE  pp.business_group_id + 0 = l_business_group_id
  AND    pp.current_employee_flag = 'Y'
  AND    pp.employee_number       = p_employee_number
  AND    pp.person_id             = pos.person_id
  AND    l_effective_start_date BETWEEN
         pp.effective_start_date AND pp.effective_end_date
  AND    l_effective_start_date BETWEEN pos.date_start
         AND nvl(pos.actual_termination_date,to_date('4712/12/31','YYYY/MM/DD'))
  AND    l_effective_end_date <=
         nvl(pos.actual_termination_date,to_date('4712/12/31','YYYY/MM/DD'));
--
--
  if p_contact_person_id IS NULL then
     hr_utility.set_location('per_db_per_additional.create_contact',3);
     l_contact_person_id := per_db_per_additional.create_other
                            (p_effective_start_date
                            ,p_effective_end_date
                            ,p_business_group
                            ,p_last_name
                            ,p_date_of_birth
                            ,p_expense_chk_send_to_address
                            ,p_first_name
                            ,p_known_as
                            ,p_marital_status
                            ,p_middle_names
                            ,p_nationality
                            ,p_national_identifier
                            ,p_previous_last_name
                            ,p_registered_disabled_flag
                            ,p_sex
                            ,p_title
                            ,p_work_telephone);
  else
   hr_utility.set_location('per_db_per_additional.create_contact',4);
   SELECT DISTINCT person_id
   INTO   l_contact_person_id
   FROM   per_people_f
   WHERE  business_group_id + 0 = l_business_group_id
   AND    person_id         = p_contact_person_id;
  end if;
--
  if p_relationship IS NULL then
     hr_utility.set_location('per_db_per_additional.create_contact',5);
     l_contact_type := 'O';
  else
    hr_utility.set_location('per_db_per_additional.create_contact',6);
    SELECT lookup_code
    INTO   l_contact_type
    FROM   hr_lookups
    WHERE  lookup_type = 'CONTACT'
    AND    meaning     = p_relationship;
  end if;
--
  hr_utility.set_location('per_db_per_additional.create_contact',7);
  SELECT per_contact_relationships_s.nextval
  INTO   l_contact_relationship_id
  FROM   sys.dual;
--
--
  hr_utility.set_location('per_db_per_additional.create_contact',8);
  INSERT INTO per_contact_relationships
  (contact_relationship_id
  ,business_group_id
  ,person_id
  ,contact_person_id
  ,contact_type
  ,dependent_flag
  ,primary_contact_flag
  ,last_update_date
  ,last_updated_by
  ,last_update_login
  ,created_by
  ,creation_date)
  values
  (l_contact_relationship_id
  ,l_business_group_id
  ,l_person_id
  ,l_contact_person_id
  ,l_contact_type
  ,p_dependent_flag
  ,p_primary_flag
  ,SYSDATE
  ,0
  ,0
  ,0
  ,SYSDATE);
  --
  --
  -- Start of Fix for WWBUG 1408379
  --
  l_new.person_id := l_person_id;
  l_new.contact_person_id := l_contact_person_id;
  l_new.business_group_id := l_business_group_id;
  l_new.date_start := null;
  l_new.date_end := null;
  l_new.contact_type := l_contact_type;
  l_new.personal_flag := null;
  l_new.start_life_reason_id := null;
  l_new.end_life_reason_id := null;
  l_new.rltd_per_rsds_w_dsgntr_flag := null;
  l_new.contact_relationship_id := l_contact_relationship_id;
  --
  ben_con_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => l_effective_start_date);
  --
  -- End of Fix for WWBUG 1408379
  --
  return l_contact_person_id;
--
--
end create_contact;
--
--
end per_db_per_additional;

/
