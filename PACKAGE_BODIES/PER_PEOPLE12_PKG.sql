--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE12_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE12_PKG" AS
/* $Header: peper12t.pkb 120.11.12010000.3 2008/12/10 12:35:37 skura ship $ */
--
--
-- Bug fix 2824664
FUNCTION future_pactid_exists(p_person_id IN number, p_effective_date IN date)
  RETURN boolean IS

  l_action_chk VARCHAR2(1) := 'N';
begin
    SELECT 'Y'
     INTO   l_action_chk
     FROM   sys.dual
    WHERE  exists
         (SELECT null
          FROM   pay_payroll_actions pac,
                 pay_assignment_actions act
          WHERE  act.assignment_id =
           (select assignment_id
              from per_all_assignments_f
             where person_id = p_person_id
               and p_effective_date between
                   effective_start_date and effective_end_date
               and primary_flag = 'Y'
               and assignment_type = 'E')
            AND  pac.payroll_action_id = act.payroll_action_id
	    AND  pac.action_type not in ('X','BEE') -- Bug 2898318. Exclude BEE
						    -- actions
            AND  pac.effective_date >=  p_effective_date);
   return(TRUE);
exception
 when NO_DATA_FOUND then return(FALSE);

end future_pactid_exists;
--
-- Start new code for bug #2664569: Overloaded procedure. ********
procedure update_row1(p_rowid VARCHAR2
   ,p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_person_type_id NUMBER
   ,p_last_name VARCHAR2
   ,p_start_date DATE
   ,p_applicant_number IN OUT NOCOPY VARCHAR2
   ,p_comment_id NUMBER
   ,p_current_applicant_flag in  VARCHAR2
   ,p_current_emp_or_apl_flag VARCHAR2
   ,p_current_employee_flag VARCHAR2
   ,p_date_employee_data_verified DATE
   ,p_date_of_birth DATE
   ,p_email_address VARCHAR2
   ,p_employee_number IN OUT NOCOPY VARCHAR2
   ,p_expense_check_send_to_addr VARCHAR2
   ,p_first_name VARCHAR2
   ,p_full_name VARCHAR2
   ,p_known_as VARCHAR2
   ,p_marital_status VARCHAR2
   ,p_middle_names VARCHAR2
   ,p_nationality VARCHAR2
   ,p_national_identifier VARCHAR2
   ,p_previous_last_name VARCHAR2
   ,p_registered_disabled_flag VARCHAR2
   ,p_sex VARCHAR2
   ,p_title VARCHAR2
   ,p_suffix VARCHAR2
   ,p_vendor_id NUMBER
   ,p_work_telephone VARCHAR2
   ,p_request_id NUMBER
   ,p_program_application_id NUMBER
   ,p_program_id NUMBER
   ,p_program_update_date DATE
   ,p_a_cat VARCHAR2
   ,p_a1 VARCHAR2
   ,p_a2 VARCHAR2
   ,p_a3 VARCHAR2
   ,p_a4 VARCHAR2
   ,p_a5 VARCHAR2
   ,p_a6 VARCHAR2
   ,p_a7 VARCHAR2
   ,p_a8 VARCHAR2
   ,p_a9 VARCHAR2
   ,p_a10 VARCHAR2
   ,p_a11 VARCHAR2
   ,p_a12 VARCHAR2
   ,p_a13 VARCHAR2
   ,p_a14 VARCHAR2
   ,p_a15 VARCHAR2
   ,p_a16 VARCHAR2
   ,p_a17 VARCHAR2
   ,p_a18 VARCHAR2
   ,p_a19 VARCHAR2
   ,p_a20 VARCHAR2
   ,p_a21 VARCHAR2
   ,p_a22 VARCHAR2
   ,p_a23 VARCHAR2
   ,p_a24 VARCHAR2
   ,p_a25 VARCHAR2
   ,p_a26 VARCHAR2
   ,p_a27 VARCHAR2
   ,p_a28 VARCHAR2
   ,p_a29 VARCHAR2
   ,p_a30 VARCHAR2
   ,p_last_update_date DATE
   ,p_last_updated_by NUMBER
   ,p_last_update_login NUMBER
   ,p_created_by NUMBER
   ,p_creation_date DATE
   ,p_i_cat VARCHAR2
   ,p_i1 VARCHAR2
   ,p_i2 VARCHAR2
   ,p_i3 VARCHAR2
   ,p_i4 VARCHAR2
   ,p_i5 VARCHAR2
   ,p_i6 VARCHAR2
   ,p_i7 VARCHAR2
   ,p_i8 VARCHAR2
   ,p_i9 VARCHAR2
   ,p_i10 VARCHAR2
   ,p_i11 VARCHAR2
   ,p_i12 VARCHAR2
   ,p_i13 VARCHAR2
   ,p_i14 VARCHAR2
   ,p_i15 VARCHAR2
   ,p_i16 VARCHAR2
   ,p_i17 VARCHAR2
   ,p_i18 VARCHAR2
   ,p_i19 VARCHAR2
   ,p_i20 VARCHAR2
   ,p_i21 VARCHAR2
   ,p_i22 VARCHAR2
   ,p_i23 VARCHAR2
   ,p_i24 VARCHAR2
   ,p_i25 VARCHAR2
   ,p_i26 VARCHAR2
   ,p_i27 VARCHAR2
   ,p_i28 VARCHAR2
   ,p_i29 VARCHAR2
   ,p_i30 VARCHAR2
   ,p_app_ass_status_type_id NUMBER
   ,p_emp_ass_status_type_id NUMBER
	,p_system_person_type in VARCHAR2
   ,p_s_system_person_type VARCHAR2
   ,p_hire_date DATE
   ,p_s_hire_date DATE
   ,p_s_date_of_birth DATE
   ,p_status in out nocopy VARCHAR2
   ,p_new_primary_id in out nocopy NUMBER
   ,p_update_primary in out nocopy VARCHAR2
   ,p_legislation_code VARCHAR2
   ,p_vacancy_id IN OUT NOCOPY NUMBER
   ,p_session_date date
   ,p_end_of_time date
   ,p_work_schedule VARCHAR2
   ,p_correspondence_language VARCHAR2
   ,p_student_status VARCHAR2
   ,p_fte_capacity NUMBER
   ,p_on_military_service VARCHAR2
   ,p_second_passport_exists VARCHAR2
   ,p_background_check_status VARCHAR2
   ,p_background_date_check DATE
   ,p_blood_type VARCHAR2
   ,p_last_medical_test_date DATE
   ,p_last_medical_test_by VARCHAR2
   ,p_rehire_recommendation VARCHAR2
   ,p_rehire_reason VARCHAR2
   ,p_resume_exists VARCHAR2
   ,p_resume_last_updated DATE
   ,p_office_number VARCHAR2
   ,p_internal_location VARCHAR2
   ,p_mailstop VARCHAR2
   ,p_honors VARCHAR2
   ,p_pre_name_adjunct VARCHAR2
   ,p_hold_applicant_date_until DATE
   ,p_benefit_group_id NUMBER
   ,p_receipt_of_death_cert_date DATE
   ,p_coord_ben_med_pln_no VARCHAR2
   ,p_coord_ben_no_cvg_flag VARCHAR2
   ,p_uses_tobacco_flag VARCHAR2
   ,p_dpdnt_adoption_date DATE
   ,p_dpdnt_vlntry_svce_flag VARCHAR2
   ,p_date_of_death DATE
   ,p_original_date_of_hire DATE
   ,p_adjusted_svc_date DATE
   ,p_s_adjusted_svc_date DATE
   ,p_town_of_birth VARCHAR2
   ,p_region_of_birth VARCHAR2
   ,p_country_of_birth VARCHAR2
   ,p_global_person_id VARCHAR2
   ,p_npw_number IN OUT NOCOPY VARCHAR2
   ,p_current_npw_flag VARCHAR2

) is
  l_sys_per_type varchar2(150);
  l_current_apl varchar2(150);
  l_table HR_EMPLOYEE_APPLICANT_API.t_ApplTable;
begin
  l_sys_per_type := p_system_person_type;
  l_current_apl := p_current_applicant_flag;

  update_row1(p_rowid
   ,p_person_id
   ,p_effective_start_date
   ,p_effective_end_date
   ,p_business_group_id
   ,p_person_type_id
   ,p_last_name
   ,p_start_date
   ,p_applicant_number
   ,p_comment_id
   -- # 2264569:
   ,l_current_apl
   --
   ,p_current_emp_or_apl_flag
   ,p_current_employee_flag
   ,p_date_employee_data_verified
   ,p_date_of_birth
   ,p_email_address
   ,p_employee_number
   ,p_expense_check_send_to_addr
   ,p_first_name
   ,p_full_name
   ,p_known_as
   ,p_marital_status
   ,p_middle_names
   ,p_nationality
   ,p_national_identifier
   ,p_previous_last_name
   ,p_registered_disabled_flag
   ,p_sex
   ,p_title
   ,p_suffix
   ,p_vendor_id
   ,p_work_telephone
   ,p_request_id
   ,p_program_application_id
   ,p_program_id
   ,p_program_update_date
   ,p_a_cat
   ,p_a1
   ,p_a2
   ,p_a3
   ,p_a4
   ,p_a5
   ,p_a6
   ,p_a7
   ,p_a8
   ,p_a9
   ,p_a10
   ,p_a11
   ,p_a12
   ,p_a13
   ,p_a14
   ,p_a15
   ,p_a16
   ,p_a17
   ,p_a18
   ,p_a19
   ,p_a20
   ,p_a21
   ,p_a22
   ,p_a23
   ,p_a24
   ,p_a25
   ,p_a26
   ,p_a27
   ,p_a28
   ,p_a29
   ,p_a30
   ,p_last_update_date
   ,p_last_updated_by
   ,p_last_update_login
   ,p_created_by
   ,p_creation_date
   ,p_i_cat
   ,p_i1
   ,p_i2
   ,p_i3
   ,p_i4
   ,p_i5
   ,p_i6
   ,p_i7
   ,p_i8
   ,p_i9
   ,p_i10
   ,p_i11
   ,p_i12
   ,p_i13
   ,p_i14
   ,p_i15
   ,p_i16
   ,p_i17
   ,p_i18
   ,p_i19
   ,p_i20
   ,p_i21
   ,p_i22
   ,p_i23
   ,p_i24
   ,p_i25
   ,p_i26
   ,p_i27
   ,p_i28
   ,p_i29
   ,p_i30
   ,p_app_ass_status_type_id
   ,p_emp_ass_status_type_id
    -- # 2264569
	,l_sys_per_type
   ,p_s_system_person_type
   ,p_hire_date
   ,p_s_hire_date
   ,p_s_date_of_birth
   ,p_status
   ,p_new_primary_id
   ,p_update_primary
   ,p_legislation_code
   ,p_vacancy_id
   ,p_session_date
   ,p_end_of_time
   ,p_work_schedule
   ,p_correspondence_language
   ,p_student_status
   ,p_fte_capacity
   ,p_on_military_service
   ,p_second_passport_exists
   ,p_background_check_status
   ,p_background_date_check
   ,p_blood_type
   ,p_last_medical_test_date
   ,p_last_medical_test_by
   ,p_rehire_recommendation
   ,p_rehire_reason
   ,p_resume_exists
   ,p_resume_last_updated
   ,p_office_number
   ,p_internal_location
   ,p_mailstop
   ,p_honors
   ,p_pre_name_adjunct
   ,p_hold_applicant_date_until
   ,p_benefit_group_id
   ,p_receipt_of_death_cert_date
   ,p_coord_ben_med_pln_no
   ,p_coord_ben_no_cvg_flag
   ,p_uses_tobacco_flag
   ,p_dpdnt_adoption_date
   ,p_dpdnt_vlntry_svce_flag
   ,p_date_of_death
   ,p_original_date_of_hire
   ,p_adjusted_svc_date
   ,p_s_adjusted_svc_date
   ,p_town_of_birth
   ,p_region_of_birth
   ,p_country_of_birth
   ,p_global_person_id
   ,p_npw_number
   ,p_current_npw_flag
   -- #2264569
   ,l_table
   ,null
   ,null
   ,null);
end update_row1;
-- End new code for bug # 2264569 ************************
--
procedure update_row1(p_rowid VARCHAR2
   ,p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_person_type_id NUMBER
   ,p_last_name VARCHAR2
   ,p_start_date DATE
   ,p_applicant_number IN OUT NOCOPY VARCHAR2
   ,p_comment_id NUMBER
   -- *** Start commented code for bug 2264569 *****
   --,p_current_applicant_flag VARCHAR2
   -- *** End commented code for bug 2264569 *******
   --
   -- *** Start new code for bug 2264569 ***********
   -- should be in out parameter
   ,p_current_applicant_flag IN OUT NOCOPY VARCHAR2
   -- *** End new code for bug 2264569 *************
   ,p_current_emp_or_apl_flag VARCHAR2
   ,p_current_employee_flag VARCHAR2
   ,p_date_employee_data_verified DATE
   ,p_date_of_birth DATE
   ,p_email_address VARCHAR2
   ,p_employee_number IN OUT NOCOPY VARCHAR2
   ,p_expense_check_send_to_addr VARCHAR2
   ,p_first_name VARCHAR2
   ,p_full_name VARCHAR2
   ,p_known_as VARCHAR2
   ,p_marital_status VARCHAR2
   ,p_middle_names VARCHAR2
   ,p_nationality VARCHAR2
   ,p_national_identifier VARCHAR2
   ,p_previous_last_name VARCHAR2
   ,p_registered_disabled_flag VARCHAR2
   ,p_sex VARCHAR2
   ,p_title VARCHAR2
   ,p_suffix VARCHAR2
   ,p_vendor_id NUMBER
   ,p_work_telephone VARCHAR2
   ,p_request_id NUMBER
   ,p_program_application_id NUMBER
   ,p_program_id NUMBER
   ,p_program_update_date DATE
   ,p_a_cat VARCHAR2
   ,p_a1 VARCHAR2
   ,p_a2 VARCHAR2
   ,p_a3 VARCHAR2
   ,p_a4 VARCHAR2
   ,p_a5 VARCHAR2
   ,p_a6 VARCHAR2
   ,p_a7 VARCHAR2
   ,p_a8 VARCHAR2
   ,p_a9 VARCHAR2
   ,p_a10 VARCHAR2
   ,p_a11 VARCHAR2
   ,p_a12 VARCHAR2
   ,p_a13 VARCHAR2
   ,p_a14 VARCHAR2
   ,p_a15 VARCHAR2
   ,p_a16 VARCHAR2
   ,p_a17 VARCHAR2
   ,p_a18 VARCHAR2
   ,p_a19 VARCHAR2
   ,p_a20 VARCHAR2
   ,p_a21 VARCHAR2
   ,p_a22 VARCHAR2
   ,p_a23 VARCHAR2
   ,p_a24 VARCHAR2
   ,p_a25 VARCHAR2
   ,p_a26 VARCHAR2
   ,p_a27 VARCHAR2
   ,p_a28 VARCHAR2
   ,p_a29 VARCHAR2
   ,p_a30 VARCHAR2
   ,p_last_update_date DATE
   ,p_last_updated_by NUMBER
   ,p_last_update_login NUMBER
   ,p_created_by NUMBER
   ,p_creation_date DATE
   ,p_i_cat VARCHAR2
   ,p_i1 VARCHAR2
   ,p_i2 VARCHAR2
   ,p_i3 VARCHAR2
   ,p_i4 VARCHAR2
   ,p_i5 VARCHAR2
   ,p_i6 VARCHAR2
   ,p_i7 VARCHAR2
   ,p_i8 VARCHAR2
   ,p_i9 VARCHAR2
   ,p_i10 VARCHAR2
   ,p_i11 VARCHAR2
   ,p_i12 VARCHAR2
   ,p_i13 VARCHAR2
   ,p_i14 VARCHAR2
   ,p_i15 VARCHAR2
   ,p_i16 VARCHAR2
   ,p_i17 VARCHAR2
   ,p_i18 VARCHAR2
   ,p_i19 VARCHAR2
   ,p_i20 VARCHAR2
   ,p_i21 VARCHAR2
   ,p_i22 VARCHAR2
   ,p_i23 VARCHAR2
   ,p_i24 VARCHAR2
   ,p_i25 VARCHAR2
   ,p_i26 VARCHAR2
   ,p_i27 VARCHAR2
   ,p_i28 VARCHAR2
   ,p_i29 VARCHAR2
   ,p_i30 VARCHAR2
   ,p_app_ass_status_type_id NUMBER
   ,p_emp_ass_status_type_id NUMBER
   -- *** Start commented code for bug 2264569 ***
   --,p_system_person_type VARCHAR2
   -- *** End commented code for bug 2264569******
   --
   -- Start new code for bug 2264569 *************
   -- should be in out parameter
   ,p_system_person_type IN OUT NOCOPY VARCHAR2
   -- End new code for bug 2264569 **************
   --
   ,p_s_system_person_type      VARCHAR2
   ,p_hire_date                 DATE
   ,p_s_hire_date               DATE
   ,p_s_date_of_birth           DATE
   ,p_status in out nocopy             VARCHAR2
   ,p_new_primary_id in out nocopy     NUMBER
   ,p_update_primary in out nocopy     VARCHAR2
   ,p_legislation_code          VARCHAR2
   ,p_vacancy_id IN OUT NOCOPY         NUMBER
   ,p_session_date date
   ,p_end_of_time date
   ,p_work_schedule VARCHAR2
   ,p_correspondence_language VARCHAR2
   ,p_student_status VARCHAR2
   ,p_fte_capacity NUMBER
   ,p_on_military_service VARCHAR2
   ,p_second_passport_exists VARCHAR2
   ,p_background_check_status VARCHAR2
   ,p_background_date_check DATE
   ,p_blood_type VARCHAR2
   ,p_last_medical_test_date DATE
   ,p_last_medical_test_by VARCHAR2
   ,p_rehire_recommendation VARCHAR2
   ,p_rehire_reason VARCHAR2
   ,p_resume_exists VARCHAR2
   ,p_resume_last_updated DATE
   ,p_office_number VARCHAR2
   ,p_internal_location VARCHAR2
   ,p_mailstop VARCHAR2
   ,p_honors VARCHAR2
   ,p_pre_name_adjunct VARCHAR2
   ,p_hold_applicant_date_until DATE
   ,p_benefit_group_id NUMBER
   ,p_receipt_of_death_cert_date DATE
   ,p_coord_ben_med_pln_no VARCHAR2
   ,p_coord_ben_no_cvg_flag VARCHAR2
   ,p_uses_tobacco_flag VARCHAR2
   ,p_dpdnt_adoption_date DATE
   ,p_dpdnt_vlntry_svce_flag VARCHAR2
   ,p_date_of_death DATE
   ,p_original_date_of_hire DATE
   ,p_adjusted_svc_date DATE
   ,p_s_adjusted_svc_date DATE
   ,p_town_of_birth VARCHAR2
   ,p_region_of_birth VARCHAR2
   ,p_country_of_birth VARCHAR2
   ,p_global_person_id VARCHAR2
   ,p_npw_number IN OUT NOCOPY VARCHAR2
   ,p_current_npw_flag VARCHAR2
   -- Start new code for bug 2264569 ****************************
   -- added pl/sql table
   ,p_tab IN OUT NOCOPY HR_EMPLOYEE_APPLICANT_API.t_ApplTable
   -- End new code for bug 2264569 ******************************
   ,p_order_name     IN VARCHAR2
   ,p_global_name    IN VARCHAR2
   ,p_local_name     IN VARCHAR2
) is
--
   l_period_of_service_id number; -- Period of Service id.
   l_back2back boolean;
   l_employ_emp_apl varchar2(1);  -- Are we employing an EMP_APL?
   l_fire_warning varchar2(1);    -- If set Y return to form displaying warning.
   l_num_appls NUMBER;            -- Number of applicants.
   l_num_accepted_appls NUMBER;   -- Number of accepted spplicant assignments
   l_set_of_books_id NUMBER;      -- Required for GL.
   v_dummy NUMBER;                -- For cursor fetch.
   l_npw_number per_all_people_f.npw_number%type;
--
   l_warn_ee VARCHAR2(1) := 'N';
--
l_max_ele number;--added for bug 6600075

cursor get_pay_proposal
is
select PAY_PROPOSAL_ID
from per_pay_proposals
where change_date = p_s_hire_date
and   assignment_id = (select assignment_id
from per_assignments_f
where person_id = p_person_id
and   primary_flag = 'Y'
and   effective_start_date = p_hire_date
and   assignment_type = 'E'
);
--
  --
  /* BEGIN OF WWBUG 1975359 */
    cursor c1 is
    select party_id
    from   per_all_people_f
    where  person_id = p_person_id
       and    p_effective_start_date
           between effective_start_date
           and     effective_end_date;  /* Fix for Bug 7442246 */
  --
  l_party_id number;
  --
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = p_person_id
    and    p_effective_start_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  /* END OF WWBUG 1975359 */
  --
  -- **** Start new code for bug 2264569   ******************************
  cursor c_apl_flag(cp_person_type varchar2) is
    select current_applicant_flag
      from  per_startup_person_types
     where system_person_type = cp_person_type;
  -- **** End new code for bug 2264569    *******************************
  --
--bug no 5546586 starts here
  cursor email_address is
    select email_address
    from   per_all_people_f
   where   rowid = p_rowid;
--bug no 5546586 ends here
begin

   --
   -- Bug 3091465. The system_person_type at the person-level should
   -- never be CWK; this information is only available from the PTU
   -- records.  Reset the person type.  Note, this situation should
   -- never occur; this is simply a safety net.
   --
   IF p_system_person_type = 'CWK' THEN
     p_system_person_type := p_s_system_person_type;
   END IF;

   --
   -- p_status has the Value of where the code should start on re-entry.
   -- on startup = 'BEGIN'( First time called from form)
   -- other values depend on what meesages have been returned to the client
   -- and the re-entry point on return from the client.
   --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',5);
   --
   /* BEGIN OF WWBUG 1975359 */
   open c1;
     --
     fetch c1 into l_party_id;
     --
   close c1;
--bug no 5546586 starts here

   open email_address;
     --
     fetch email_address into per_hrtca_merge.g_old_email_address;
     --
   close email_address;
--bug no 5546586 starts here

   /* BEGIN OF WWBUG 1975359 */
   --
   if p_status = 'BEGIN' then
      --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',10);
      -- Test to see if the hire_date_has changed
      -- Providing Person type has not and it is emp.
      -- Or that it has changed to EMP
      --
      if (p_hire_date <> p_s_hire_date)
         and (p_s_hire_date is not null)
         and (((p_system_person_type = p_s_system_person_type)
            and p_system_person_type in('EMP','EMP_APL'))
          or ((p_system_person_type = 'EMP'
               and p_s_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL'))
          or (p_system_person_type = 'EMP_APL'
               and p_s_system_person_type = 'APL')
          or (p_system_person_type = 'EMP'
             and p_s_system_person_type = 'EMP_APL'))) then
         -- get the period_of_service_id
			-- 303729 if person is a supervisor
			-- test whether change to hire_date would invalidate this action
			--
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',15);
			--
			if ((p_hire_date <> p_s_hire_date)
			 and (p_system_person_type = p_s_system_person_type))
			then
           per_people12_pkg.check_not_supervisor(p_person_id
                                         ,p_hire_date
                                         ,p_s_hire_date);
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',20);
         end if;
         begin
            select pps.period_of_service_id
            into   l_period_of_service_id
            from   per_periods_of_service pps
            where  pps.person_id = p_person_id
            and    pps.date_start = p_s_hire_date;
            --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',25);
            exception
             when no_data_found then
               --
               -- If no data found and a previous hire date existed
               -- then raise an error;
               --
               if p_s_hire_date is not null then
                  hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE','Update_row');
                  hr_utility.raise_error;
               end if;
         end;
         --
         -- check the integrity of the date change.
         -- Date may come in between a person type change.
         --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',30);
         hr_date_chk.check_hire_ref_int(p_person_id
                  ,p_business_group_id
                  ,l_period_of_service_id
                  ,p_s_hire_date
                  ,p_system_person_type
                  ,p_hire_date);
         -- VT 12/05/96 bug #418637
         -- check the existence of the recurring element entries
         --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',35);
         per_people12_pkg.check_recur_ent(p_person_id,p_hire_date,
                p_s_hire_date,l_warn_ee);
      end if;
      --
      -- check session date and effective_start_date for differences
      -- if any exists then ensure the person record is correct
      -- i.e duplicate datetrack functionality as it currently uses
      -- a global version of session date to update the rows (not good)
      --
      -- VT 08/13/96
      if p_session_date <> p_effective_start_date  then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',40);
        per_people9_pkg.update_old_person_row(p_person_id =>p_person_id
                              ,p_session_date => p_session_date
                              ,p_effective_start_date=>p_effective_start_date);
      end if;
      --
      -- get the Employee and applicant numbers if necessary
      -- only returns values depending on values of
      -- p_current_applicant_flag, p_current_applicant_flag
      -- and whether p_employee_number and p_applicant_number
      -- are null.
      --
      -- VT #970014 08/19/99
--adhunter #2544613 comment out call completely, generate number is called from PERWSEPI.pld
--on PRE-UPDATE always
--      if p_current_employee_flag = 'Y' and
--         p_current_applicant_flag is null and
--         p_employee_number is not null then
--         null;
--   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',45);
--      else
--   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',50);
--         hr_person.generate_number(p_current_employee_flag
--           ,p_current_applicant_flag
--           ,null   --p_current_npw_flag
--           ,p_national_identifier
--           ,p_business_group_id
--           ,p_person_id
--           ,p_employee_number
--           ,p_applicant_number
--           ,l_npw_number);
--      end if;
      --
      -- Test current numbers are not used by
      -- the system already.
      --
      hr_person.validate_unique_number(p_person_id    =>p_person_id
				   , p_business_group_id => p_business_group_id
				   , p_employee_number  => p_employee_number
				   , p_applicant_number => p_applicant_number
                                   , p_npw_number       => null --p_npw_number
				   , p_current_employee => p_current_employee_flag
				   , p_current_applicant => p_current_applicant_flag
                                   , p_current_npw       => null --p_current_npw_flag
                                   );
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',55);
      -- VT 12/05/96 bug #418637
      if l_warn_ee = 'Y' then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',60);
        p_status := 'RECUR_ENT_CHK'; -- Set status to next reentry point.
      else
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',65);
        p_status := 'VACANCY_CHECK'; -- Set status to next possible reentry point.
      end if;
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',70);

  --Start of fix for Bug 2167668

  IF p_start_date > p_hold_applicant_date_until THEN
    hr_utility.set_message('800', 'PER_289796_HOLD_UNTIL_DATE');
    hr_utility.set_message_token('HOLD_DATE', p_start_date );
    hr_utility.raise_error;
  END IF;

  -- End of fix for Bug 2167668
   end if; -- End the First in section
   --
   -- VT 12/05/96 bug #418637
   if p_status = 'RECUR_ENT_CHK' then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',75);
     return;
   end if; -- End of RECUR_ENT_CHK
   --
   --
   -- Start of Person type changes.
   --
   -- Has the Person type changed to become that of an applicant?
   --
   if (p_system_person_type ='APL'
         and p_s_system_person_type = 'OTHER')
      or (p_system_person_type = 'APL_EX_APL'
         and p_s_system_person_type = 'EX_APL')
      or (p_system_person_type = 'EMP_APL'
         and p_s_system_person_type = 'EMP')
      or (p_system_person_type = 'EX_EMP_APL'
         and p_s_system_person_type = 'EX_EMP') then
         --
         hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',80);
         NULL;
         -- 3652025 >> this process is replaced by call to
         -- hr_applicant_internal.create_applicant_anytime() procedure.
         -- called directly from PERWSEPI.pld
         --
         --  Ensure no future person_type_changes.
         --
         -- if hr_person.chk_future_person_type(p_s_system_person_type
         --                                 ,p_person_id
         --                                   ,p_business_group_id
         --                                   ,p_effective_start_date) then
         --  fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
         --  app_exception.raise_exception;
         --end if;
         --
         -- Ensure there are no future applicant assignments
         --
         --per_people3_pkg.check_future_apl(p_person_id => p_person_id
         --                 ,p_hire_date => greatest(p_hire_date
		 --,p_effective_start_date));
         -- hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',85);
         --
         -- Insert the default applicant row and applicant
         -- assignment.
         --
         -- VT 08/13/96
         --per_people9_pkg.insert_applicant_rows(p_person_id => p_person_id
         --      ,p_effective_start_date => p_effective_start_date
         --      ,p_effective_end_date => p_effective_end_date
         --      ,p_business_group_id =>p_business_group_id
         --      ,p_app_ass_status_type_id => p_app_ass_status_type_id
         --      ,p_request_id => p_request_id
         --      ,p_program_application_id => p_program_application_id
         --      ,p_program_id => p_program_id
         --      ,p_program_update_date => p_program_update_date
         --      ,p_last_update_date => p_last_update_date
         --      ,p_last_updated_by => p_last_updated_by
         --      ,p_last_update_login => p_last_update_login
         --      ,p_created_by => p_created_by
         --      ,p_creation_date => p_creation_date);
         --
         --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',90);
         --
         -- PTU Changes

           --hr_per_type_usage_internal.maintain_person_type_usage
           --  (p_effective_date       => p_effective_start_date
           --  ,p_person_id            => p_person_id
           --  ,p_person_type_id       => p_person_type_id
           --  );
         --
         --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',92);
         -- PTU Changes
         -- <<
        -- Has the Person type changed to become that of an employee
        -- when the previous type is not a current applicant?
        --
   elsif (p_system_person_type = 'EMP'
         and ( p_s_system_person_type = 'OTHER'
      or p_s_system_person_type = 'EX_EMP'
      or p_s_system_person_type = 'EX_APL')) then /* Bug 523924 */
--       or p_s_system_person_type = 'EX_EMP')) then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',95);
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
--changes for bug no 6070935
--					    ,p_effective_start_date) then
                                            ,p_session_date) then
--changes for bug no 6070935
	   fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           app_exception.raise_exception;
         end if;
         --
         if p_s_system_person_type = 'EX_EMP'
         then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',100);
          --
          -- Bug 3154253 stars here.
          -- Passed earlier of p_ession_date and p_hire_date
          -- (p_effective_start_date) to the check_hire procedure.
          --
          if p_session_date < p_effective_start_date  then
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',101);
            per_people12_pkg.check_rehire(p_person_id, p_session_date);
          else
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',102);
            per_people12_pkg.check_rehire(p_person_id, p_hire_date);
          end if;
          --
          -- bug 3154253 ends here.
          --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',105);
         end if;
			per_people12_pkg.check_future_changes(p_person_id
					,p_effective_start_date);
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',110);
      --
      -- Ensure there are no future applicant assignments
      --
     /* per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date
        p_effective_start_date));* commented for bug 5403222*/
      --fix for bug  6600075
      l_max_ele := p_tab.COUNT;

      if l_max_ele > 0 then
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date,p_effective_start_date)
                        ,p_table=>p_tab);
      else
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date,p_effective_start_date));
      end if;

   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',115);
      --
      -- Insert the default period_of service and assignment
      -- rows.
      --
      -- VT 08/13/96
      per_people9_pkg.insert_employee_rows(p_person_id => p_person_id
         ,p_effective_start_date => p_effective_start_date
         ,p_effective_end_date => p_effective_end_date
         ,p_business_group_id =>p_business_group_id
         ,p_emp_ass_status_type_id => p_emp_ass_status_type_id
         ,p_employee_number => p_employee_number
         ,p_request_id => p_request_id
         ,p_program_application_id => p_program_application_id
         ,p_program_id => p_program_id
         ,p_program_update_date => p_program_update_date
         ,p_last_update_date => p_last_update_date
         ,p_last_updated_by => p_last_updated_by
         ,p_last_update_login => p_last_update_login
         ,p_created_by => p_created_by
         ,p_creation_date => p_creation_date
         ,p_adjusted_svc_date => p_adjusted_svc_date);
      --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',120);

-- PTU Changes

 l_back2back := per_periods_of_service_pkg_v2.IsBackToBackContract
     ( p_person_id => p_person_id, p_hire_date_of_current_pds => p_effective_start_date);
    if p_s_system_person_type in ('EX_EMP','EX_EMP_APL')  -- Bug 3637893
     and p_system_person_type = 'EMP'
--     and p_session_date = p_effective_start_date then
       and l_back2back then
 hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',1201);
        hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_effective_start_date
         ,p_person_id            => p_person_id
         ,p_person_type_id       => p_person_type_id
         ,p_datetrack_update_mode => 'CORRECTION'
         );
    else
        hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_effective_start_date
         ,p_person_id            => p_person_id
         ,p_person_type_id       => p_person_type_id
         );
 hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',1202);
    end if;

-- PTU Changes

   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',121);

      -- Has the Person become an Employee or Employee applicant from being an
      -- applicant or employee applicant?
      --
   elsif ((p_system_person_type = 'EMP'
         and p_s_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL'))
      or (p_system_person_type = 'EMP_APL'
         and p_s_system_person_type in ('APL','EX_EMP_APL')) /* Bug 732598 */
      or (p_system_person_type = 'EMP'
         and p_s_system_person_type = 'EMP_APL')) then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',125);
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
          fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           hr_utility.raise_error;
         end if;
      --
      -- Ensure there are no future applicant assignments
      --
/*      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date
			,p_effective_start_date));* commented for bug 5403222*/
      --fix for bug  6600075
      l_max_ele := p_tab.COUNT;

      if l_max_ele > 0 then
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date,p_effective_start_date)
                        ,p_table=>p_tab);
      else
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date,p_effective_start_date));
      end if;

   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',130);
      --
      -- Check if the person have open term_assignment records. These can be
      -- found by checking if the person have a periods_of_service with
      -- no FPD and a value for ATD. Bug 2881076
      per_people12_pkg.check_rehire(p_person_id
		                   ,p_hire_date);
      --
      -- Check that the change is valid.
      --
      if p_status = 'VACANCY_CHECK' then
         loop
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',135);
            exit when p_status = 'BOOKINGS_EXIST';
               --
               -- Check each vacancy,if it is oversubscribed
               -- l_fire_warning = 'Y', return to client
               -- displaying relevant message.
               -- on return l_vacancy_id starts the cursor at the
               -- relevant point.
               --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',140);
               per_people3_pkg.vacancy_chk(p_person_id => p_person_id
                           ,p_fire_warning => l_fire_warning
                           ,p_vacancy_id => p_vacancy_id
                           -- **** Start new code for bug 2264569  ****************
                           ,p_table        => p_tab -- #2381925
                           -- **** End new code for bug 2264569   *****************
                           );
               if l_fire_warning = 'Y' then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',145);
                  return;
               elsif l_fire_warning = 'N' then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',150);
                  p_status := 'BOOKINGS_EXIST'; -- Set next possible re-entry point.
               end if;
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',155);
         end loop;
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',160);
      end if; -- End of VACANCY_CHECK
      --
      if p_status = 'BOOKINGS_EXIST' then
        -- VT 09/18/96 #288087, #380280 , #2172590
        if (per_people3_pkg.chk_events_exist(p_person_id =>p_person_id
                           ,p_business_group_id =>p_business_group_id
                           ,p_hire_date => greatest(p_hire_date,p_session_date))) then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',165);
          return;
        else
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',170);
          -- **** Start commented code for bug 2264569 *************************
          --p_status := 'GET_APPLS'; -- Set next possible re-entry point.
          -- **** End commented code for bug 2264569 ***************************
          -- **** Start new code for bug 2264569     ***************************
          p_status := 'CHOOSE_VAC'; -- Set next possible re-entry point.
          -- **** End new code for bug 2264569 *********************************
        end if;
       hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',175);
      end if;
      if p_status = 'END_BOOKINGS' then
        hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',180);
        hrhirapl.end_bookings(p_person_id
                             , p_business_group_id
                             , p_hire_date);
        hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',185);
          --
          -- **** START commented code for bug 2264569 ***************************          --
          --p_status := 'GET_APPLS'; -- Set next possible re-entry point.
          -- **** End commented code for bug 2264569      ************************
          -- **** Start new code for bug 2264569          ************************
          p_status := 'CHOOSE_VAC'; -- Set next possible re-entry point.
          -- **** END new code for bug 2264569    ********************************
          --
      end if;
      --
      -- **** START commented code for bug 2264569 *******************************
      --
      -- Removed references to 'end_unaccepted' and 'multiple_contracts'
      -- Get_appls has been moved to the client side.
      --
      -- if p_status='GET_APPLS' then
         --
         -- Get all the accepted applicants
         --
      --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',190);
      --   per_people3_pkg.get_accepted_appls(p_person_id => p_person_id
      --                     ,p_num_accepted_appls => l_num_accepted_appls
      --                     ,p_new_primary_id =>p_new_primary_id);
         --
         -- Get all current applicant assignments.
         --
      -- hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',195);
      --   per_people3_pkg.get_all_current_appls(p_person_id => p_person_id
      --                        ,p_num_appls => l_num_appls);
       --
      --   if p_system_person_type = 'EMP_APL' then
      -- hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',200);
            --
            -- If we have got this far then there must be > 0 Accepted
            -- applications,therefore check p_system_person_type if EMP_APL
            -- and number of accepted is equal to number of current assignments
            -- then there is an error. Otherwise go around end_accepted
            -- to multiple contracts.
            --
      --    if l_num_accepted_appls = l_num_appls then
      --       hr_utility.set_message('801','HR_6791_EMP_APL_NO_ASG');
      --       hr_utility.raise_error;
      --    else
   -- hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',205);
   --            p_status := 'MULTIPLE_CONTRACTS';-- Set next re-entry point.
   --         end if;
   --      --
         -- Number of accepted does not equal number of current then
         -- end_accepted.
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',210);
         --
   --      elsif l_num_accepted_appls <> l_num_appls then
   --         hr_utility.set_message('801','HR_EMP_UNACCEPTED_APPL');
   --         p_status := 'END_UNACCEPTED'; -- next code re-entry,
   --         return;
   --      --
         -- Otherwise ignore end_accepted.
         --
   --      else
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',215);
   --         p_status := 'MULTIPLE_CONTRACTS'; -- next code re-entry.
   --      end if;
   --   end if; -- End of GET_APPLS
      --
   --   if p_status = 'END_UNACCEPTED' then
         --
         -- End the unaccepted assignments.
         --
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',220);
   --      hrhirapl.end_unaccepted_app_assign(p_person_id
   --                                          ,p_business_group_id
   --                                          ,p_legislation_code
   --                                          ,p_session_date);
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',225);
   --      p_status := 'MULTIPLE_CONTRACTS';
   --   end if; -- End of END_UNACCEPTED
   --   --
   --   -- Test to see if multiple contracts are a possibility.
   --   --
   --hr_utility.set_location('update_row - b4 MULTIPLE_CONTRACTS',1);
   --   if p_status = 'MULTIPLE_CONTRACTS' then -- MULTIPLE_CONTRACTS
   --      if l_num_accepted_appls >1 then
   --         hr_utility.set_message('801','HR_EMP_MULTIPLE_CONTRACTS');
   --         return;
   --      else
   --         p_status := 'CHOOSE_VAC'; -- next code re-entry.
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',230);
   --      end if;
   --hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',235);
   --   end if; -- End of MULTIPLE_CONTRACTS
   --
   --  **** END commented code for bug 2264569 ****************************
      --
      -- Choose whether to change the Primary assignment
      -- and which vacancy  is to be the primary if so.
      --
   hr_utility.set_location('update_row - b4 CHOOSE_VAC',1);
      if p_status = 'CHOOSE_VAC' then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',240);
         return;
      end if; --End of CHOOSE_VAC
      --
      -- Can now hire the Person
		-- Note HIRE status can only be set from client form
		-- as interaction is generally required.
      --
   hr_utility.set_location('update_row - b4 HIRE',1);
      -- +-------------------------------------------------------------------+
      -- +--------- BEGIN: Hire process -------------------------------------+
      -- +-------------------------------------------------------------------+
      if p_status = 'HIRE' then
         hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',245);

         -- bug fix 2824664:
         if p_update_primary = 'Y'
            and future_pactid_exists(p_person_id, p_effective_start_date)
         then
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',246);
            fnd_message.set_name('PAY','HR_6591_ASS_ACTIONS_EXIST');
            hr_utility.raise_error;
         end if;
         -- end bug fix 2824664
         --
         -- If new is Emp and old was Emp_apl
         -- then l_emp_emp_apl is set to Y
         --
         if p_system_person_type = 'EMP'
               and p_s_system_person_type = 'EMP_APL' then
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',250);
            l_employ_emp_apl := 'Y';
         else
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',255);
            l_employ_emp_apl := 'N';
         end if;
         --
         -- Run the employ_applicant stored procedure
         --
         hr_utility.set_location('update_row - b4 hrhirapl',1);
         -- **** Start new code for bug 2264569 *****************************
         -- End date chosen unaccepted applicant assignments
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',257);
         hrhirapl.end_unaccepted_app_assign(p_person_id
                                           ,p_business_group_id
                                           ,p_legislation_code
                                           ,p_session_date
                                           ,p_tab);
         hr_utility.set_location('update_row - b4 hrhirapl',2);

         -- **** End new code for bug 2264569   *****************************

         hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',259);
         hrhirapl.employ_applicant(p_person_id
                                  ,p_business_group_id
                                  ,p_legislation_code
                                  ,p_new_primary_id
                                  ,p_emp_ass_status_type_id
                                  ,p_last_updated_by
                                  ,p_last_update_login
                                  ,p_effective_start_date
                                  ,p_end_of_time
                                  ,p_last_update_date
                                  ,p_update_primary
                                  ,p_employee_number
                                  ,l_set_of_books_id
                                  ,l_employ_emp_apl
                                  ,p_adjusted_svc_date
                                  ,p_session_date -- Bug 3564129
                                  -- **** Start new code for bug 2264569 ******
                                  ,p_tab
                                  -- **** End new code for bug 2264569  *******
                                  );
   hr_utility.set_location('update_row - after hrhirapl',2);
   hr_utility.set_location('manage PTU records',3);
         if p_system_person_type = 'EMP' then
--
-- PTU : Following Code has been added
--           hr_per_type_usage_internal.maintain_ptu(
--              p_action => 'HIRE_APL',
--              p_person_id => p_person_id,
--              p_actual_termination_date => p_effective_start_date-1);
--
       -- **** START new code for bug 2264569  ******************************************
       -- Update the system person type to EMP_APL if user is keeping active APPLS.
         if hr_employee_applicant_api.retain_exists(p_tab) then
            hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',260);
            p_system_person_type     := 'EMP_APL';
            open c_apl_flag(p_system_person_type);
            fetch c_apl_flag into p_current_applicant_flag;
            close c_apl_flag;
            hr_utility.trace('    current applicant_flag : '||p_current_applicant_flag);
         end if;
        -- **** END new code for bug 2264569 *******************************************

-- Bug 3637893 Starts
/*       hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_effective_start_date
         ,p_person_id            => p_person_id
         ,p_person_type_id       => p_person_type_id
         );
*/
 l_back2back := per_periods_of_service_pkg_v2.IsBackToBackContract
     ( p_person_id => p_person_id, p_hire_date_of_current_pds => p_effective_start_date);
    if p_s_system_person_type in ('EX_EMP','EX_EMP_APL')
     and p_system_person_type = 'EMP'
--     and p_session_date = p_effective_start_date then
       and l_back2back then
 hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',1211);
        hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_effective_start_date
         ,p_person_id            => p_person_id
         ,p_person_type_id       => p_person_type_id
         ,p_datetrack_update_mode => 'CORRECTION'
         );
    else
        hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date       => p_effective_start_date
         ,p_person_id            => p_person_id
         ,p_person_type_id       => p_person_type_id
         );
 hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',1212);
    end if;
-- Bug 3637893 Ends
      --
       hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',260);
       -- **** Start new code for bug 2264569 **********************************
       if NOT hr_employee_applicant_api.retain_exists(p_tab) then
           hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',262);
        -- **** End  new code for bug 2264569  **********************************
           hr_per_type_usage_internal.maintain_person_type_usage
           (p_effective_date       => p_effective_start_date
           ,p_person_id            => p_person_id
           ,p_person_type_id       => hr_person_type_usage_info.get_default_person_type_id
                                        (p_business_group_id
                                        ,'EX_APL')
           );
      -- **** Start new code for bug 2264569 **********************************
        end if;

      -- **** End new code for bug 2264569   **********************************
-- PTU : End of changes
--
         end if; -- End of hire
      -- +-------------------------------------------------------------------+
      -- +----------- END: Hire process -------------------------------------+
      -- +-------------------------------------------------------------------+
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',265);
      end if; -- End of HIRE.
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',270);
   end if; -- Of Person type change checks.
   --
   -- changed p_rowid => null to p_rowid => p_rowid
   --
    ben_dt_trgr_handle.person(p_rowid => p_rowid
        ,p_business_group_id          => p_business_group_id
	,p_person_id                  => p_person_id
	,p_effective_start_date       => p_effective_start_date
	,p_effective_end_date         => p_effective_end_date
	,p_date_of_birth              => p_date_of_birth
	,p_date_of_death              => p_date_of_death
	,p_marital_status             => p_marital_status
	,p_on_military_service        => p_on_military_service
	,p_registered_disabled_flag   => p_registered_disabled_flag
	,p_sex                        => p_sex
	,p_student_status             => p_student_status
	,p_coord_ben_med_pln_no       => p_coord_ben_med_pln_no
	,p_coord_ben_no_cvg_flag      => p_coord_ben_no_cvg_flag
	,p_uses_tobacco_flag          => p_uses_tobacco_flag
	,p_benefit_group_id           => p_benefit_group_id
	,p_per_information10          => p_i10
	,p_original_date_of_hire      => p_original_date_of_hire
	,p_dpdnt_vlntry_svce_flag     => p_dpdnt_vlntry_svce_flag
	,p_receipt_of_death_cert_date => p_receipt_of_death_cert_date
	,p_attribute1                 => p_a1
	,p_attribute2                 =>p_a2
	,p_attribute3                 =>p_a3
	,p_attribute4                 =>p_a4
	,p_attribute5                 =>p_a5
	,p_attribute6                 =>p_a6
	,p_attribute7                 =>p_a7
	,p_attribute8                 =>p_a8
	,p_attribute9                 =>p_a9
	,p_attribute10                =>p_a10
	,p_attribute11                =>p_a11
	,p_attribute12                =>p_a12
	,p_attribute13                =>p_a13
	,p_attribute14                =>p_a14
	,p_attribute15                =>p_a15
	,p_attribute16                =>p_a16
	,p_attribute17                =>p_a17
	,p_attribute18                =>p_a18
	,p_attribute19                =>p_a19
	,p_attribute20                =>p_a20
	,p_attribute21                =>p_a21
	,p_attribute22                =>p_a22
	,p_attribute23                =>p_a23
	,p_attribute24                =>p_a24
	,p_attribute25                =>p_a25
	,p_attribute26                =>p_a26
	,p_attribute27                =>p_a27
	,p_attribute28                =>p_a28
	,p_attribute29                =>p_a29
	,p_attribute30                =>p_a30
);
   --
   if l_party_id is null then

     /*
     ** We tried to get the party_id at the start of this process however
     ** the person may not have had one.  If they have undergone a change in
     ** person type they may very well have one by now so we'll try and get
     ** the current party_id from their person record (this will have been
     ** set when the TCAparty was created) if we don't currently have the value.
     **
     ** Ideally we should get the party_id returned from the PTU maintenance
     ** code where it would have been derived but this is not an ideal world
     ** so we won't.
     */
     open c1;
     --
     fetch c1 into l_party_id;
     --
     close c1;

   end if;

   hr_utility.set_location('update_row - b4 update',1);
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',272);
    hr_utility.set_location('PER_PEOPLE12_PKG.update_row1 '||p_person_type_id,272);
    hr_utility.set_location('PER_PEOPLE12_PKG.update_row1 '||p_s_system_person_type,272);
    hr_utility.set_location('PER_PEOPLE12_PKG.update_row1 '||p_system_person_type,272);
    hr_utility.set_location('PER_PEOPLE12_PKG.update_row1 '||hr_person_type_usage_info.get_default_person_type_id(
	 p_business_group_id,p_system_person_type),272);

   -- Bug 6196362 Starts.
   -- update per_people_f ppf
   update per_all_people_f ppf
   -- Bug 6196362 Ends.
   set ppf.person_id = p_person_id
   ,ppf.effective_start_date = p_effective_start_date
   ,ppf.effective_end_date = p_effective_end_date
   ,ppf.business_group_id = p_business_group_id
--   ,ppf.person_type_id = p_person_type_id
   --,ppf.person_type_id =hr_person_type_usage_info.get_default_person_type_id(	 p_business_group_id	,p_system_person_type) bug 6848958
   ,ppf.person_type_id =decode( p_system_person_type,'CWK',
   	hr_person_type_usage_info.get_default_person_type_id(
	 p_business_group_id,'OTHER'),
     hr_person_type_usage_info.get_default_person_type_id(
	 p_business_group_id,p_system_person_type))  -- fix for bug6848958
   ,ppf.last_name = p_last_name
   ,ppf.start_date = p_start_date
   ,ppf.applicant_number = p_applicant_number
   ,ppf.comment_id = p_comment_id
   ,ppf.current_applicant_flag = p_current_applicant_flag
   ,ppf.current_emp_or_apl_flag = p_current_emp_or_apl_flag
   ,ppf.current_employee_flag = p_current_employee_flag
   ,ppf.date_employee_data_verified = p_date_employee_data_verified
   ,ppf.date_of_birth = p_date_of_birth
   ,ppf.email_address = p_email_address
   ,ppf.employee_number = p_employee_number
   ,ppf.expense_check_send_to_address = p_expense_check_send_to_addr
   ,ppf.first_name = p_first_name
   ,ppf.full_name = p_full_name
   ,ppf.known_as = p_known_as
   ,ppf.marital_status = p_marital_status
   ,ppf.middle_names = p_middle_names
   ,ppf.nationality = p_nationality
   ,ppf.national_identifier = p_national_identifier
   ,ppf.previous_last_name = p_previous_last_name
   ,ppf.registered_disabled_flag = p_registered_disabled_flag
   ,ppf.sex = p_sex
   ,ppf.title = p_title
   ,ppf.suffix = p_suffix
   ,ppf.vendor_id = p_vendor_id
--   ,ppf.work_telephone = p_work_telephone
   ,ppf.request_id = p_request_id
   ,ppf.program_application_id = p_program_application_id
   ,ppf.program_id = p_program_id
   ,ppf.program_update_date = p_program_update_date
   ,ppf.attribute_category = p_a_cat
   ,ppf.attribute1 = p_a1
   ,ppf.attribute2 = p_a2
   ,ppf.attribute3 = p_a3
   ,ppf.attribute4 = p_a4
   ,ppf.attribute5 = p_a5
   ,ppf.attribute6 = p_a6
   ,ppf.attribute7 = p_a7
   ,ppf.attribute8 = p_a8
   ,ppf.attribute9 = p_a9
   ,ppf.attribute10 = p_a10
   ,ppf.attribute11 = p_a11
   ,ppf.attribute12 = p_a12
   ,ppf.attribute13 = p_a13
   ,ppf.attribute14 = p_a14
   ,ppf.attribute15 = p_a15
   ,ppf.attribute16 = p_a16
   ,ppf.attribute17 = p_a17
   ,ppf.attribute18 = p_a18
   ,ppf.attribute19 = p_a19
   ,ppf.attribute20 = p_a20
   ,ppf.attribute21 = p_a21
   ,ppf.attribute22 = p_a22
   ,ppf.attribute23 = p_a23
   ,ppf.attribute24 = p_a24
   ,ppf.attribute25 = p_a25
   ,ppf.attribute26 = p_a26
   ,ppf.attribute27 = p_a27
   ,ppf.attribute28 = p_a28
   ,ppf.attribute29 = p_a29
   ,ppf.attribute30 = p_a30
   ,ppf.last_update_date = p_last_update_date
   ,ppf.last_updated_by = p_last_updated_by
   ,ppf.last_update_login = p_last_update_login
   ,ppf.created_by = p_created_by
   ,ppf.creation_date = p_creation_date
   ,ppf.per_information_category = p_i_cat
   ,ppf.per_information1 = p_i1
   ,ppf.per_information2 = p_i2
   ,ppf.per_information3 = p_i3
   ,ppf.per_information4 = p_i4
   ,ppf.per_information5 = p_i5
   ,ppf.per_information6 = p_i6
   ,ppf.per_information7 = p_i7
   ,ppf.per_information8 = p_i8
   ,ppf.per_information9 = p_i9
   ,ppf.per_information10 = p_i10
   ,ppf.per_information11 = p_i11
   ,ppf.per_information12 = p_i12
   ,ppf.per_information13 = p_i13
   ,ppf.per_information14 = p_i14
   ,ppf.per_information15 = p_i15
   ,ppf.per_information16 = p_i16
   ,ppf.per_information17 = p_i17
   ,ppf.per_information18 = p_i18
   ,ppf.per_information19 = p_i19
   ,ppf.per_information20 = p_i20
   ,ppf.per_information21 = p_i21
   ,ppf.per_information22 = p_i22
   ,ppf.per_information23 = p_i23
   ,ppf.per_information24 = p_i24
   ,ppf.per_information25 = p_i25
   ,ppf.per_information26 = p_i26
   ,ppf.per_information27 = p_i27
   ,ppf.per_information28 = p_i28
   ,ppf.per_information29 = p_i29
   ,ppf.per_information30 = p_i30
      ,ppf.work_schedule  = p_work_schedule
   ,ppf.correspondence_language  = p_correspondence_language
   ,ppf.student_status  = p_student_status
   ,ppf.fte_capacity  = p_fte_capacity
   ,ppf.on_military_service  = p_on_military_service
   ,ppf.second_passport_exists  = p_second_passport_exists
   ,ppf.background_check_status  = p_background_check_status
   ,ppf.background_date_check  = p_background_date_check
   ,ppf.blood_type  = p_blood_type
   ,ppf.last_medical_test_date  = p_last_medical_test_date
   ,ppf.last_medical_test_by  = p_last_medical_test_by
   ,ppf.rehire_recommendation  = p_rehire_recommendation
   ,ppf.rehire_reason  = p_rehire_reason
   ,ppf.resume_exists  = p_resume_exists
   ,ppf.resume_last_updated  = p_resume_last_updated
   ,ppf.office_number  = p_office_number
   ,ppf.internal_location  = p_internal_location
   ,ppf.mailstop  = p_mailstop
   ,ppf.honors  = p_honors
   ,ppf.pre_name_adjunct  = p_pre_name_adjunct
   ,ppf.hold_applicant_date_until = p_hold_applicant_date_until
   ,ppf.benefit_group_id = p_benefit_group_id
   ,ppf.receipt_of_death_cert_date = p_receipt_of_death_cert_date
   ,ppf.coord_ben_med_pln_no = p_coord_ben_med_pln_no
   ,ppf.coord_ben_no_cvg_flag = p_coord_ben_no_cvg_flag
   ,ppf.uses_tobacco_flag = p_uses_tobacco_flag
   ,ppf.dpdnt_adoption_date = p_dpdnt_adoption_date
   ,ppf.dpdnt_vlntry_svce_flag = p_dpdnt_vlntry_svce_flag
   ,ppf.date_of_death = p_date_of_death
   ,ppf.original_date_of_hire = p_original_date_of_hire
   ,ppf.town_of_birth    = p_town_of_birth
   ,ppf.region_of_birth  = p_region_of_birth
   ,ppf.country_of_birth = p_country_of_birth
   ,ppf.global_person_id = p_global_person_id
   ,ppf.party_id         = l_party_id
   ,ppf.npw_number       = p_npw_number
   ,ppf.current_npw_flag = p_current_npw_flag
   ,ppf.order_name       = p_order_name  -- #3889584
   ,ppf.global_name      = p_global_name
   ,ppf.local_name       = p_local_name
   where ppf.rowid = p_rowid;
   --
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6001_ALL_MANDATORY_FIELD');
      hr_utility.set_message_token('MISSING_FIELD','rowid is'||p_rowid);
      hr_utility.raise_error;
   end if;
   --

   -- Start of Fix #2447513
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',275);
   --End of Fix

   -- Tests required post-update
   --
   /* BEGIN OF WWBUG 1975359 */
   --
   open c_person;
     --
     fetch c_person into l_person;
     --
   close c_person;
   --
   per_hrtca_merge.update_tca_person(p_Rec => l_person);
   --
   hr_utility.set_location('update_row - after update',1);
   --
   /* END OF WWBUG 1975359 */
   --
   -- HR/WF Synchronization call
   --
   /* -- this now called later in prog so called after ptu. Bug 3297591
   per_hrwf_synch.per_per_wf(p_rec      => l_person,
                             p_action   => 'UPDATE');
   */
   --
   -- Has the Date of Birth changed?
   --
   if p_date_of_birth is null and
		p_s_date_of_birth is not null then
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',280);
     per_people12_pkg.check_birth_date(p_person_id);
   end if;
   if p_date_of_birth <> p_s_date_of_birth then
      --
      -- Run the assignment_link_usages and Element_entry
      -- code for Change of Personal qualifying conditions.
      --
      --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',282);
      per_people3_pkg.run_alu_ee(p_alu_mode => 'CHANGE_PQC'
                            ,p_business_group_id=>p_business_group_id
                            ,p_person_id =>p_person_id
                            ,p_old_start =>p_s_hire_date
                            ,p_start_date => p_last_update_date
                            );
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',285);
   end if;
   --
   hr_utility.set_location('update_row - after update',2);
   --
   -- test if hire_date has changed. and system person type has not.
   --
   if  (((p_current_employee_flag = 'Y')
         and (p_hire_date <> p_s_hire_date)
         and (p_system_person_type = p_s_system_person_type)))
         or (nvl(p_adjusted_svc_date,hr_general.end_of_time) -- #1573563
                                  <> nvl(p_s_adjusted_svc_date,
                                        hr_general.end_of_time)
--          and (p_s_system_person_type not in ('EX_EMP','EX_EMP_APL')) -- #2060744
            --
            -- Verify person has been employee before modifying the POS
            --
            and Hr_General2.is_person_type(p_person_id, 'EMP',p_s_hire_date) --#2472146
            ) then
      --
      -- Update the period of service for the employee
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',290);
      --
      per_people3_pkg.update_period(p_person_id =>p_person_id
                              ,p_hire_date => p_s_hire_date
                              ,p_new_hire_date =>p_hire_date
                              ,p_adjusted_svc_date => p_adjusted_svc_date);
      --
      hr_utility.set_location('update_row - after update',3);
      --
      -- Update the hire records i.e
      -- assignment etc.
      --
      --
      /*--- If condition is added for the bug 5907880 */
      if  (((p_current_employee_flag = 'Y')
         and (p_hire_date <> p_s_hire_date)
         and (p_system_person_type = p_s_system_person_type))) then
      /*--- End changes for the bug 5907880 */
      hr_utility.set_location('update_row - after update',4);
      hr_date_chk.update_hire_records(p_person_id
          ,p_applicant_number
          ,p_hire_date
          ,p_s_hire_date
          ,p_last_updated_by
          ,p_last_update_login);
      End if;
      --
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',295);
-- Commented, as this action is being done in
-- hr_change_start_date_api.update_pay_proposal (pehirapi.pkb)
--		open get_pay_proposal;
--		fetch get_pay_proposal into v_dummy;
--		if get_pay_proposal%FOUND
--		then
--		  close get_pay_proposal;
--		  begin
--		    update per_pay_proposals
--		    set change_date = p_hire_date
--		    where change_date = p_s_hire_date
--		    and   assignment_id = (select assignment_id
--		    from per_assignments_f
--		    where person_id = p_person_id
--		    and   primary_flag = 'Y'
--		    and   effective_start_date = p_hire_date
--		    and   assignment_type = 'E'
--		    );
--		    --
--		    if sql%ROWCOUNT <> 1
--		    then
--			   raise NO_DATA_FOUND;
--		    end if;
--		    exception
--			  when NO_DATA_FOUND then
--            hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
--           hr_utility.set_message_token('PROCEDURE','Update_row');
--           hr_utility.set_message_token('STEP','4');
--				 hr_utility.raise_error;
--		  end;
--		else
--   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',300);
--		  close get_pay_proposal;
--		end if;
      hr_utility.set_location('update_row - after update',5);
      --
      -- Update PTU records to reflect hire date change.
      --
-- PTU changes: following has been added
--
--      hr_per_type_usage_internal.maintain_ptu(
--                p_action         =>'HIRE DATE',
--                p_person_id      => p_person_id,
--		p_date_start     => p_hire_date,
--		p_old_date_start => p_s_hire_date);
--
       hr_per_type_usage_internal.change_hire_date_ptu
          (p_date_start           => p_hire_date
          ,p_old_date_start       => p_s_hire_date
          ,p_person_id            => p_person_id
          ,p_system_person_type   => 'EMP'
          );
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',305);
--
-- PTU : end of changes
--
      --
      -- Run the assignment_link_usages and Element_entry
      -- code for Assignment Criteria.
      --
      per_people3_pkg.run_alu_ee(p_alu_mode => 'ASG_CRITERIA'
                          ,p_business_group_id=>p_business_group_id
                          ,p_person_id =>p_person_id
                          ,p_old_start =>p_s_hire_date
                         ,p_start_date => p_hire_date);
		--
   hr_utility.set_location('PER_PEOPLE12_PKG.update_row1',310);
		--
   end if;
   --
   -- 1766066, contact start date enh. start
   --
   if (((p_hire_date is not null
       and p_s_hire_date is not null
       and p_hire_date < p_s_hire_date)
      or (p_hire_date is not null
       and p_s_hire_date is null))
      and (NVL(p_current_npw_flag,'N') <> 'Y') -- 3813870
       ) then
         maintain_coverage(p_person_id       => p_person_id
                          ,p_type            => 'EMP'
                          );
   end if;
   --
   -- 1766066 end
   --
   -- call synch process here - Bug 3297591.
   --
   --/*
   per_hrwf_synch.per_per_wf(p_rec      => l_person,
                             p_action   => 'UPDATE');
   --*/
   --
   p_status := 'END'; -- Status required to end update loop on server
   hr_utility.set_location('Leaving PER_PEOPLE12_PKG.update_row1',315);
   --
end update_row1;
--
procedure check_future_changes(p_person_id NUMBER
                              ,p_effective_start_date DATE)
is
--
l_dummy VARCHAR2(1);
--
cursor future_exists
is
select '1'
from sys.dual
where exists (
              select 'future assignment exists'
              from   per_people_f ppf
              where  ppf.person_id = p_person_id
              and    ppf.effective_start_date > p_effective_start_date
             );
begin
  open future_exists;
  fetch future_exists into l_dummy;
  if future_exists%found then
    fnd_message.set_name('PAY','HR_7510_PER_FUT_CHANGE');
    app_exception.raise_exception;
  end if;
  close future_exists;
end;
--
procedure check_not_supervisor(p_person_id NUMBER
                              ,p_new_hire_date DATE
                              ,p_old_hire_date DATE)
is
l_dummy VARCHAR2(1);
--
cursor supervisor
is
select 'Y'
from per_assignments_f paf
where paf.assignment_type = 'E'
and   paf.supervisor_id = p_person_id
and   p_new_hire_date > paf.effective_start_date
and   paf.effective_end_date  >= p_old_hire_date ;
--
begin
  open supervisor;
  fetch supervisor into l_dummy;
  if supervisor%FOUND then
    close supervisor;
    fnd_message.set_name('PAY','HR_51031_INV_HIRE_CHG_IS_SUPER');
    app_exception.raise_exception;
  end if;
  close supervisor;
end;
--
--
procedure check_rehire(p_person_id NUMBER
   		      ,p_start_date DATE)
IS
cursor old_pps_exists
is
select 1
from  per_periods_of_service pps
where pps.person_id = p_person_id
and   pps.actual_termination_date is not null;
--
-- 70.11  nvl(pps.final_process_date,p_start_date)+1  < p_start_date;
--
cursor pps_not_ended
is
--
-- 115.67 (START)
--
--select pps.final_process_date
select pps.last_standard_process_date,
       pps.final_process_date
--
-- 115.67 (END)
--
from  per_periods_of_service pps
where pps.person_id  = p_person_id
and   pps.date_start = (select max(date_start)
                        from   per_periods_of_service pps1
                        where  pps1.person_id = pps.person_id
                        and    pps1.date_start <p_start_date
                       )
and nvl(pps.final_process_date,p_start_date)  >= p_start_date;
--
v_dummy INTEGER;
v_dummy_fpd date;
--
-- 115.67 (START)
--
v_dummy_lspd DATE;
l_rule_value pay_legislation_rules.rule_mode%TYPE;
l_rule_found BOOLEAN;
l_legislation_code pay_legislation_rules.legislation_code%TYPE;
--
-- Cursor to get legislation code
--
CURSOR csr_per_legislation IS
  SELECT bus.legislation_code
  FROM per_people_f per
      ,per_business_groups bus
 WHERE per.person_id = p_person_id
   AND per.business_group_id+0 = bus.business_group_id
   AND p_start_date BETWEEN per.effective_start_date
                       AND per.effective_end_date;
--
l_proc  VARCHAR2(50);
--
-- 115.67 (END)
--
begin
  l_proc := 'per_people12_pkg.check_rehire';
  hr_utility.set_location('Entering '||l_proc,5);
--
-- 115.67 (START)
--
  --
  -- Get legislation
  --
  OPEN csr_per_legislation;
  FETCH csr_per_legislation INTO l_legislation_code;
  CLOSE csr_per_legislation;
  --
  pay_core_utils.get_legislation_rule('REHIRE_BEFORE_FPD'
                                     ,l_legislation_code
                                     ,l_rule_value
                                     ,l_rule_found
                                     );
  --
  hr_utility.set_location(l_proc,10);
--
-- 115.67 (END)
--
  --
  -- Check if old PPS row exists
  --
  open old_pps_exists;
  fetch old_pps_exists into v_dummy;
  if old_pps_exists%FOUND
  then
    close old_pps_exists;
	 --
         hr_utility.set_location(l_proc,15);
	 --
	 -- if yes then check last PPS
	 -- has had it's FPD closed down and that the FPD + 1
	 -- is less than current hire date
	 -- if not error;
	 --
    open pps_not_ended;
--
-- 115.67 (START)
--
    --fetch pps_not_ended into v_dummy_fpd;
    fetch pps_not_ended into v_dummy_lspd,v_dummy_fpd;
--
-- 115.67 (END)
--
    if pps_not_ended%FOUND then
--
-- 115.67 (START)
--
      --
      hr_utility.set_location(l_proc,20);
      --
      if (not(l_rule_found)
          OR
          (l_rule_found AND nvl(l_rule_value,'N') = 'N'))
      then
        --
        -- old behaviour as rehire before fpd is not enabled
        --
        hr_utility.set_location(l_proc,25);
--
-- 115.67 (END)
--
      close pps_not_ended;
      if v_dummy_fpd is null then
         hr_utility.set_message('800','HR_51032_EMP_PREV_FPD_OPEN');
      else
         hr_utility.set_message('800','PER_289308_FUTURE_ENDED_FPD');
      end if;
      hr_utility.raise_error;
--
-- 115.67 (START)
--
      else
        --
        hr_utility.set_location(l_proc,30);
        --
        -- Rehire before FPD allowed
        --
        if v_dummy_fpd is null then
          close pps_not_ended;
          hr_utility.set_message('800','HR_449756_FPD_PREV_PDS');
          hr_utility.raise_error;
        end if;
        if v_dummy_lspd >= p_start_date then
          close pps_not_ended;
          hr_utility.set_message('800','HR_449759_REHIRE_AFTER_LSPD');
          hr_utility.raise_error;
        end if;
      end if;
--
-- 115.67 (END)
--
    end if;
    close pps_not_ended;
  else
    close old_pps_exists;
  end if;
  hr_utility.set_location('Leaving '||l_proc,50);
end;
--
procedure check_birth_date(p_person_id NUMBER)
is
v_dummy NUMBER;
--
-- Cursor to check if any employee assignments have
-- Payroll id set.
--
cursor get_payroll
is
select asg.assignment_id
from per_assignments_f asg
where asg.person_id = p_person_id
and   asg.payroll_id is not null;
begin
  open get_payroll;
  fetch get_payroll into v_dummy;
  --
  -- If a row exists, flag an error to stop
  -- Date of birth being nulled when emp on payroll.
  --
  if get_payroll%FOUND
  then
    close get_payroll;
    hr_utility.set_message('801','HR_7950_PPM_NULL_DOB');
	 hr_utility.raise_error;
  else
    close get_payroll;
  end if;
end;
-- VT 12/05/96 bug #418637 new procedure
procedure check_recur_ent(p_person_id NUMBER,
                          p_start_date DATE,
                          p_old_date DATE,
                          p_warn_raise IN OUT NOCOPY VARCHAR2)
is
--
l_warn VARCHAR2(1);
l_earlier_date DATE;
l_later_date DATE;
--
begin
  l_warn := p_warn_raise;
  if p_start_date > p_old_date then
    l_earlier_date := p_old_date;
    l_later_date   := p_start_date;
  else
    l_earlier_date := p_start_date;
    l_later_date   := p_old_date;
  end if;
  begin
    select 'Y'
    into l_warn
    from dual
    where exists
    (select null
     from pay_element_entries_f ee,
          pay_element_links_f el,
          pay_element_types_f et
     where ee.assignment_id in
       (select assignment_id
        from per_assignments_f asg
        where asg.person_id = p_person_id
        and asg.effective_start_date between l_earlier_date and l_later_date)
     and ee.element_link_id = el.element_link_id
     and el.element_type_id = et.element_type_id
     and et.processing_type = 'R');
    exception when NO_DATA_FOUND then null;
  end;
  p_warn_raise := l_warn;
end;

--
--Added procedures for bug 1766066. Only maintain_coverage is declared in header
--
PROCEDURE ins_or_upd_precursor_row
	(p_person_id in number
	,p_cov_date_start in date) is
--
cursor csr_per_details(c_person_id number) is
select *
from per_all_people_f
where person_id = c_person_id
order by effective_start_date asc;
--
cursor csr_per_exists(c_person_id number, c_effective_date date) is
select 'Y'
from dual
where exists(
	select 1
	from per_all_people_f per
	where per.person_id = c_person_id
	and c_effective_date between per.effective_start_date and per.effective_end_date
	);
--
cursor csr_per_type(c_person_id number, c_effective_date date) is
select ppt.system_person_type
from per_person_types ppt,
     per_all_people_f ppf
where ppf.person_id = c_person_id
and ppf.person_type_id = ppt.person_type_id;
--
cursor csr_address(c_person_id number, c_date_from date) is
select address_id
from per_addresses
where person_id = c_person_id
and date_from = c_date_from;
--
cursor csr_get_other(c_business_group_id number) is
select ppt.person_type_id
from per_person_types ppt
where ppt.business_group_id = c_business_group_id
and ppt.default_flag = 'Y'
and ppt.active_flag = 'Y'
and ppt.system_person_type = 'OTHER';
--
l_proc varchar2(100) := 'per_people12_pkg.ins_or_upd_precursor_row';
l_per_rec per_all_people_f%rowtype;
l_system_person_type varchar2(60);
l_dummy varchar2(10);
l_cov_date_start date;
l_ptu_nextval number;
l_object_version_number number;
--
begin
  hr_utility.set_location('Entering '||l_proc,1);
  hr_utility.set_location('person_id: '||p_person_id,2);
  open csr_per_exists(p_person_id, p_cov_date_start);
  fetch csr_per_exists into l_dummy;
  if csr_per_exists%found then
    hr_utility.set_location(l_proc,5);
    close csr_per_exists;   --no need to create precursor row since person exists as of cov.s.d.
  else
    hr_utility.set_location(l_proc,10);
    close csr_per_exists;
    --
    open csr_per_details(p_person_id);
    fetch csr_per_details into l_per_rec;  -- fetch once to get earliest record only
    close csr_per_details;
    --
    open csr_per_type(p_person_id, l_per_rec.effective_start_date);
    fetch csr_per_type into l_system_person_type;
    close csr_per_type;
    --

    for l_address_id in csr_address(p_person_id, l_per_rec.effective_start_date)
    loop
      update per_addresses
      set date_from = p_cov_date_start
      where address_id = l_address_id.address_id;
    end loop;
    --
    if l_system_person_type = 'OTHER' then  --first DT record is "OTHER" so simply extend back
      hr_utility.set_location(l_proc,15);
      update per_all_people_f
      set effective_start_date = p_cov_date_start,
      start_date = p_cov_date_start
      where person_id = p_person_id
      and effective_start_date = l_per_rec.effective_start_date;
      --
      -- Fox for bug 3390731 starts here.
      --
      update per_all_people_f
      set    start_date = p_cov_date_start
      where  person_id = p_person_id;
      --
      -- Fix for bug 3390731 ends here.
      --
      update per_person_type_usages_f ptu
      set ptu.effective_start_date = p_cov_date_start
      where ptu.person_id = p_person_id
      and ptu.person_type_id in (select ppt.person_type_id
                                 from per_person_types ppt
                                 where ppt.system_person_type = 'OTHER');
    else
      hr_utility.set_location(l_proc,20);
      --   now change some of the fields before inserting precursor row
      l_per_rec.applicant_number := null;
      l_per_rec.employee_number := null;
      l_per_rec.current_employee_flag := null;
      l_per_rec.current_applicant_flag := null;
      l_per_rec.current_emp_or_apl_flag := null;
      l_per_rec.rehire_authorizor := null;
      l_per_rec.effective_end_date := l_per_rec.effective_start_date - 1;
      l_per_rec.effective_start_date := p_cov_date_start;
      l_per_rec.start_date := p_cov_date_start;
      open csr_get_other(l_per_rec.business_group_id);
      fetch csr_get_other into l_per_rec.person_type_id;
      close csr_get_other;
      --
      insert into per_all_people_f(
          person_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          person_type_id,
          last_name,
          start_date,
          comment_id,
          current_applicant_flag,
          current_emp_or_apl_flag,
          current_employee_flag,
          date_of_birth,
          first_name,
          full_name,
          middle_names,
          sex,
          title,
	  pre_name_adjunct,
	  suffix,
          national_identifier,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          per_information_category,
          per_information1,
          per_information2,
          per_information3,
          per_information4,
          per_information5,
          per_information6,
          per_information7,
          per_information8,
          per_information9,
          per_information10,
          per_information11,
          per_information12,
          per_information13,
          per_information14,
          per_information15,
          per_information16,
          per_information17,
          per_information18,
          per_information19,
          per_information20,
          per_information21,
          per_information22,
          per_information23,
          per_information24,
          per_information25,
          per_information26,
          per_information27,
          per_information28,
          per_information29,
          per_information30,
          known_as
         )
      values(
          l_per_rec.person_id,
          l_per_rec.effective_start_date,
          l_per_rec.effective_end_date,
          l_per_rec.business_group_id,
          l_per_rec.person_type_id,
          l_per_rec.last_name,
          l_per_rec.start_date,
          l_per_rec.comment_id,
          l_per_rec.current_applicant_flag,
          l_per_rec.current_emp_or_apl_flag,
          l_per_rec.current_employee_flag,
          l_per_rec.date_of_birth,
          l_per_rec.first_name,
          l_per_rec.full_name,
          l_per_rec.middle_names,
          l_per_rec.sex,
          l_per_rec.title,
	  l_per_rec.pre_name_adjunct,
	  l_per_rec.suffix,
          l_per_rec.national_identifier,
          l_per_rec.attribute_category,
          l_per_rec.attribute1,
          l_per_rec.attribute2,
          l_per_rec.attribute3,
          l_per_rec.attribute4,
          l_per_rec.attribute5,
          l_per_rec.attribute6,
          l_per_rec.attribute7,
          l_per_rec.attribute8,
          l_per_rec.attribute9,
          l_per_rec.attribute10,
          l_per_rec.attribute11,
          l_per_rec.attribute12,
          l_per_rec.attribute13,
          l_per_rec.attribute14,
          l_per_rec.attribute15,
          l_per_rec.attribute16,
          l_per_rec.attribute17,
          l_per_rec.attribute18,
          l_per_rec.attribute19,
          l_per_rec.attribute20,
          l_per_rec.attribute21,
          l_per_rec.attribute22,
          l_per_rec.attribute23,
          l_per_rec.attribute24,
          l_per_rec.attribute25,
          l_per_rec.attribute26,
          l_per_rec.attribute27,
          l_per_rec.attribute28,
          l_per_rec.attribute29,
          l_per_rec.attribute30,
          l_per_rec.per_information_category,
          l_per_rec.per_information1,
          l_per_rec.per_information2,
          l_per_rec.per_information3,
          l_per_rec.per_information4,
          l_per_rec.per_information5,
          l_per_rec.per_information6,
          l_per_rec.per_information7,
          l_per_rec.per_information8,
          l_per_rec.per_information9,
          l_per_rec.per_information10,
          l_per_rec.per_information11,
          l_per_rec.per_information12,
          l_per_rec.per_information13,
          l_per_rec.per_information14,
          l_per_rec.per_information15,
          l_per_rec.per_information16,
          l_per_rec.per_information17,
          l_per_rec.per_information18,
          l_per_rec.per_information19,
          l_per_rec.per_information20,
          l_per_rec.per_information21,
          l_per_rec.per_information22,
          l_per_rec.per_information23,
          l_per_rec.per_information24,
          l_per_rec.per_information25,
          l_per_rec.per_information26,
          l_per_rec.per_information27,
          l_per_rec.per_information28,
          l_per_rec.per_information29,
          l_per_rec.per_information30,
          l_per_rec.known_as
          );
      --
      -- Fox for bug 3390731 starts here.
      -- Update the start_date to the minimum of effective_start_date,
      -- in this case it is l_per_rec.start_date.
      --
      update per_all_people_f
      set    start_date = l_per_rec.start_date
      where  person_id = l_per_rec.person_id;
      --
      -- Fix for bug 3390731 ends here.
      --
      select per_person_type_usages_s.nextval into l_ptu_nextval
      from sys.dual;
      l_object_version_number := 1;
      --
      insert into per_person_type_usages_f(
          PERSON_TYPE_USAGE_ID,
          PERSON_ID,
          PERSON_TYPE_ID,
          EFFECTIVE_START_DATE,
          EFFECTIVE_END_DATE,
          OBJECT_VERSION_NUMBER
          )
      values
         (l_ptu_nextval,
          l_per_rec.person_id,
          l_per_rec.person_type_id,
          l_per_rec.effective_start_date,
          l_per_rec.effective_end_date,
          l_object_version_number
          );
      --
    end if;
  end if;
  hr_utility.set_location('Leaving '||l_proc,25);
end ins_or_upd_precursor_row;
--
--
PROCEDURE maintain_coverage
	(p_person_id in number
	,p_type in varchar2) is
--
cursor csr_get_contacts(c_person_id number) is
select contact_person_id, min(nvl(date_start,hr_api.g_sot)) date_start
from per_contact_relationships
where person_id = c_person_id
group by contact_person_id;
--
cursor csr_get_person(c_contact_person_id number) is
select ctr.person_id, min(nvl(ctr.date_start,hr_api.g_sot)) date_start
from per_contact_relationships ctr
    ,per_person_type_usages_f ptu
    ,per_person_types ppt
where ctr.contact_person_id = c_contact_person_id
and ctr.person_id = ptu.person_id
and ptu.person_type_id = ppt.person_type_id
and ppt.system_person_type = 'EMP'
group by ctr.person_id;
--
cursor csr_last_hire_date(c_person_id number) is
select max(date_start)
from per_periods_of_service
where person_id = c_person_id;
--
l_proc varchar2(100) := 'per_people12_pkg.maintain_coverage';
l_cov_date_start date;
l_person_id number;
l_contact_person_id number;
l_ctr_date_start date;
l_pds_date_start date;
--
begin
  if p_type = 'EMP' then
    hr_utility.set_location(l_proc,5);
    open csr_last_hire_date(p_person_id);
    fetch csr_last_hire_date into l_pds_date_start;
    close csr_last_hire_date;
    --
    for l_cov_rec                --contact_person_id, date_start
	in csr_get_contacts(p_person_id)
    loop
      if l_cov_rec.date_start > l_pds_date_start then
        l_cov_date_start := l_cov_rec.date_start;
      else
        l_cov_date_start := l_pds_date_start;
      end if;
      hr_utility.set_location(l_proc,15);
      ins_or_upd_precursor_row(l_cov_rec.contact_person_id, l_cov_date_start);
     end loop;
  elsif p_type = 'CONT' then
    hr_utility.set_location(l_proc,20);
    for l_cov_rec1                --person_id, date_start
        in csr_get_person(p_person_id)
    loop
      open csr_last_hire_date(l_cov_rec1.person_id);
      fetch csr_last_hire_date into l_pds_date_start;
      close csr_last_hire_date;
       --
      if l_cov_rec1.date_start > l_pds_date_start then
        l_cov_date_start := l_cov_rec1.date_start;
      else
        l_cov_date_start := l_pds_date_start;
      end if;
       hr_utility.set_location(l_proc,30);
      ins_or_upd_precursor_row(p_person_id, l_cov_date_start);
    end loop;
  end if;
  hr_utility.set_location('Leaving '||l_proc,40);
end maintain_coverage;
--
--
END PER_PEOPLE12_PKG;

/
