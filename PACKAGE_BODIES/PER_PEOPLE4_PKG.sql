--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE4_PKG" AS
/* $Header: peper04t.pkb 120.1 2005/10/19 03:53:12 pchowdav noship $ */
--
procedure update_row(p_rowid VARCHAR2
   ,p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_person_type_id NUMBER
   ,p_last_name VARCHAR2
   ,p_start_date DATE
   ,p_applicant_number IN OUT NOCOPY VARCHAR2
   ,p_comment_id NUMBER
   ,p_current_applicant_flag VARCHAR2
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
   ,p_system_person_type VARCHAR2
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
   ,p_end_of_time date) is
--
   l_period_of_service_id number; -- Period of Service id.
   l_employ_emp_apl varchar2(1);  -- Are we employing an EMP_APL?
   l_fire_warning varchar2(1);    -- If set Y return to form displaying warning.
   l_num_appls NUMBER;            -- Number of applicants.
   l_num_accepted_appls NUMBER;   -- Number of accepted spplicant assignments
   l_set_of_books_id NUMBER;      -- Required for GL.
   v_dummy NUMBER;                -- For cursor fetch.
   l_npw_number per_all_people_f.npw_number%type;
   l_party_id   per_all_people_f.party_id%type;
--
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
   cursor csr_partyId_details is -- Enh 3299580
     select party_id
       from per_all_people_f
      where person_id = p_person_id
        and p_session_date between effective_start_date
                              and  effective_end_date;
begin
   --
   -- p_status has the Value of where the code should start on re-entry.
   -- on startup = 'BEGIN'( First time called from form)
   -- other values depend on what meesages have been returned to the client
   -- and the re-entry point on return from the client.
   --
   if p_status = 'BEGIN' then
      --
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
			--
			if ((p_hire_date <> p_s_hire_date)
			 and (p_system_person_type = p_s_system_person_type))
			then
           per_people4_pkg.check_not_supervisor(p_person_id
                                         ,p_hire_date
                                         ,p_s_hire_date);
         end if;
         begin
            select pps.period_of_service_id
            into   l_period_of_service_id
            from   per_periods_of_service pps
            where  pps.person_id = p_person_id
            and    pps.date_start = p_s_hire_date;
            --
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
         hr_date_chk.check_hire_ref_int(p_person_id
                  ,p_business_group_id
                  ,l_period_of_service_id
                  ,p_s_hire_date
                  ,p_system_person_type
                  ,p_hire_date);
      end if;
      --
      -- check session date and effective_start_date for differences
      -- if any exists then ensure the person record is correct
      -- i.e duplicate datetrack functionality as it currently uses
      -- a global version of session date to update the rows (not good)
      --
      -- VT 08/13/96
      if p_session_date <> p_effective_start_date  then
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
      open csr_partyId_details;  -- Enh 3299580
      fetch csr_partyId_details into l_party_id;
      close csr_partyId_details;
      --
      hr_person.generate_number(p_current_employee_flag
           ,p_current_applicant_flag
           ,NULL  --p_current_npw_flag
           ,p_national_identifier
           ,p_business_group_id
           ,p_person_id
           ,p_employee_number
           ,p_applicant_number
           ,l_npw_number
            -- Enh 3299580 --
           ,p_session_date
           ,l_party_id
           ,p_date_of_birth
           ,p_hire_date
       );
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
      p_status := 'VACANCY_CHECK'; -- Set status to next possible reentry point.
   end if; -- End the First in section
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
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
           fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           app_exception.raise_exception;
         end if;
         --
         -- Ensure there are no future applicant assignments
         --
         per_people3_pkg.check_future_apl(p_person_id => p_person_id
                          ,p_hire_date => greatest(p_hire_date
																  ,p_effective_start_date));
         --
         -- Insert the default applicant row and applicant
         -- assignment.
         --
         -- VT 08/13/96
         per_people9_pkg.insert_applicant_rows(p_person_id => p_person_id
               ,p_effective_start_date => p_effective_start_date
               ,p_effective_end_date => p_effective_end_date
               ,p_business_group_id =>p_business_group_id
               ,p_app_ass_status_type_id => p_app_ass_status_type_id
               ,p_request_id => p_request_id
               ,p_program_application_id => p_program_application_id
               ,p_program_id => p_program_id
               ,p_program_update_date => p_program_update_date
               ,p_last_update_date => p_last_update_date
               ,p_last_updated_by => p_last_updated_by
               ,p_last_update_login => p_last_update_login
               ,p_created_by => p_created_by
               ,p_creation_date => p_creation_date);
   --
   -- Has the Person type changed to become that of an employee
   -- when the previous type is not a current applicant?
   --
   elsif (p_system_person_type = 'EMP'
         and ( p_s_system_person_type = 'OTHER'
      or p_s_system_person_type = 'EX_EMP')) then
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
           fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           app_exception.raise_exception;
         end if;
         --
         if p_s_system_person_type = 'EX_EMP'
         then
           per_people4_pkg.check_rehire(p_person_id
                      ,p_hire_date);
         end if;
			per_people4_pkg.check_future_changes(p_person_id
										,p_effective_start_date);
      --
      -- Ensure there are no future applicant assignments
      --
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date
															   ,p_effective_start_date));
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
         ,p_adjusted_svc_date => NULL);
      --
      -- Has the Person become an Employee or Employee applicant from being an
      -- applicant or employee applicant?
      --
   elsif ((p_system_person_type = 'EMP'
         and p_s_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL'))
      or (p_system_person_type = 'EMP_APL'
         and p_s_system_person_type = 'APL')
      or (p_system_person_type = 'EMP'
         and p_s_system_person_type = 'EMP_APL')) then
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
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => greatest(p_hire_date
                                                ,p_effective_start_date));
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
            exit when p_status = 'BOOKINGS_EXIST';
               --
               -- Check each vacancy,if it is oversubscribed
               -- l_fire_warning = 'Y', return to client
               -- displaying relevant message.
               -- on return l_vacancy_id starts the cursor at the
               -- relevant point.
               --
               per_people3_pkg.vacancy_chk(p_person_id => p_person_id
                           ,p_fire_warning => l_fire_warning
                           ,p_vacancy_id => p_vacancy_id);
               if l_fire_warning = 'Y' then
                  return;
               elsif l_fire_warning = 'N' then
                  p_status := 'BOOKINGS_EXIST'; -- Set next possible re-entry point.
               end if;
         end loop;
      end if; -- End of VACANCY_CHECK
      --
      if p_status = 'BOOKINGS_EXIST' then
        -- VT 09/18/96 #288087, #380280, #2172590
        if (per_people3_pkg.chk_events_exist(p_person_id =>p_person_id
                           ,p_business_group_id =>p_business_group_id
                           ,p_hire_date =>  greatest(p_hire_date,p_session_date))) then
          return;
        else
          p_status := 'GET_APPLS'; -- Set next possible re-entry point.
        end if;
      end if;
      if p_status = 'END_BOOKINGS' then
        hrhirapl.end_bookings(p_person_id
                             , p_business_group_id
                             , p_hire_date);
        p_status :=  'GET_APPLS'; -- Set next possible re-entry point.
      end if;
      --
      if p_status='GET_APPLS' then
         --
         -- Get all the accepted applicants
         --
         per_people3_pkg.get_accepted_appls(p_person_id => p_person_id
                           ,p_num_accepted_appls => l_num_accepted_appls
                           ,p_new_primary_id =>p_new_primary_id);
         --
         -- Get all current applicant assignments.
         --
         per_people3_pkg.get_all_current_appls(p_person_id => p_person_id
                              ,p_num_appls => l_num_appls);
         --
         if p_system_person_type = 'EMP_APL' then
            --
            -- If we have got this far then there must be > 0 Accepted
            -- applications,therefore check p_system_person_type if EMP_APL
            -- and number of accepted is equal to number of current assignments
            -- then there is an error. Otherwise go around end_accepted
            -- to multiple contracts.
            --
            if l_num_accepted_appls = l_num_appls then
               hr_utility.set_message('801','HR_6791_EMP_APL_NO_ASG');
               hr_utility.raise_error;
            else
               p_status := 'MULTIPLE_CONTRACTS';-- Set next re-entry point.
            end if;
         --
         -- Number of accepted does not equal number of current then
         -- end_accepted.
         --
         elsif l_num_accepted_appls <> l_num_appls then
            hr_utility.set_message('801','HR_EMP_UNACCEPTED_APPL');
            p_status := 'END_UNACCEPTED'; -- next code re-entry,
            return;
         --
         -- Otherwise ignore end_accepted.
         --
         else
            p_status := 'MULTIPLE_CONTRACTS'; -- next code re-entry.
         end if;
      end if; -- End of GET_APPLS
      --
      if p_status = 'END_UNACCEPTED' then
         --
         -- End the unaccepted assignments.
         --
         hrhirapl.end_unaccepted_app_assign(p_person_id
                                             ,p_business_group_id
                                             ,p_legislation_code
                                             ,p_session_date);
         p_status := 'MULTIPLE_CONTRACTS';
      end if; -- End of END_UNACCEPTED
      --
      -- Test to see if multiple contracts are a possibility.
      --
   hr_utility.set_location('update_row - b4 MULTIPLE_CONTRACTS',1);
      if p_status = 'MULTIPLE_CONTRACTS' then -- MULTIPLE_CONTRACTS
         if l_num_accepted_appls >1 then
            hr_utility.set_message('801','HR_EMP_MULTIPLE_CONTRACTS');
            return;
         else
            p_status := 'CHOOSE_VAC'; -- next code re-entry.
         end if;
      end if; -- End of MULTIPLE_CONTRACTS
      --
      -- Choose whether to change the Primary assignment
      -- and which vacancy  is to be the primary if so.
      --
   hr_utility.set_location('update_row - b4 CHOOSE_VAC',1);
      if p_status = 'CHOOSE_VAC' then
         return;
      end if; --End of CHOOSE_VAC
      --
      -- Can now hire the Person
		-- Note HIRE status can only be set from client form
		-- as interaction is generally required.
      --
   hr_utility.set_location('update_row - b4 HIRE',1);
      if p_status = 'HIRE' then
         --
         -- If new is Emp and old was Emp_apl
         -- then l_emp_emp_apl is set to Y
         --
         if p_system_person_type = 'EMP'
               and p_s_system_person_type = 'EMP_APL' then
            l_employ_emp_apl := 'Y';
         else
            l_employ_emp_apl := 'N';
         end if;
         --
         -- Run the employ_applicant stored procedure
         --
   hr_utility.set_location('update_row - b4 hrhirapl',1);
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
                                  ,NULL
                                  ,p_session_date); -- Bug 3564129
   hr_utility.set_location('update_row - after hrhirapl',2);
      end if; -- End of HIRE.
   end if; -- Of Person type change checks.
   --
   hr_utility.set_location('update_row - b4 update',1);
   update per_people_f ppf
   set ppf.person_id = p_person_id
   ,ppf.effective_start_date = p_effective_start_date
   ,ppf.effective_end_date = p_effective_end_date
   ,ppf.business_group_id = p_business_group_id
   ,ppf.person_type_id = p_person_type_id
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
   where ppf.rowid = p_rowid;
   --
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6001_ALL_MANDATORY_FIELD');
      hr_utility.set_message_token('MISSING_FIELD','rowid is'||p_rowid);
      hr_utility.raise_error;
   end if;
   --
   -- Tests required post-update
   --
   hr_utility.set_location('update_row - after update',1);
   --
   -- Has the Date of Birth changed?
   --
   if p_date_of_birth is null and
		p_s_date_of_birth is not null then
     per_people4_pkg.check_birth_date(p_person_id);
   end if;
   if p_date_of_birth <> p_s_date_of_birth then
      --
      -- Run the assignment_link_usages and Element_entry
      -- code for Change of Personal qualifying conditions.
      --
      --
      per_people3_pkg.run_alu_ee(p_alu_mode => 'CHANGE_PQC'
                            ,p_business_group_id=>p_business_group_id
                            ,p_person_id =>p_person_id
                            ,p_old_start =>p_s_hire_date
                            ,p_start_date => p_last_update_date
                            );
   end if;
   --
   hr_utility.set_location('update_row - after update',2);
   --
   -- test if hire_date has changed. and system person type has not.
   --
   if  ((p_current_employee_flag = 'Y')
         and (p_hire_date <> p_s_hire_date)
         and (p_system_person_type = p_s_system_person_type)) then
      --
      -- Update the period of service for the employee
      --
      --
      per_people3_pkg.update_period(p_person_id =>p_person_id
                              ,p_hire_date => p_s_hire_date
                              ,p_new_hire_date =>p_hire_date);
      --
      hr_utility.set_location('update_row - after update',3);
      --
      -- Update the hire records i.e
      -- assignment etc.
      --
      --
      hr_date_chk.update_hire_records(p_person_id
          ,p_applicant_number
          ,p_hire_date
          ,p_s_hire_date
          ,p_last_updated_by
          ,p_last_update_login);
      --
		open get_pay_proposal;
		fetch get_pay_proposal into v_dummy;
		if get_pay_proposal%FOUND
		then
 		  close get_pay_proposal;
		  begin
		    update per_pay_proposals
		    set change_date = p_hire_date
		    where change_date = p_s_hire_date
		    and   assignment_id = (select assignment_id
		    from per_assignments_f
		    where person_id = p_person_id
		    and   primary_flag = 'Y'
		    and   effective_start_date = p_hire_date
		    and   assignment_type = 'E'
		    );
		    --
		    if sql%ROWCOUNT <> 1
		    then
			   raise NO_DATA_FOUND;
		    end if;
		    exception
			  when NO_DATA_FOUND then
             hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','Update_row');
              hr_utility.set_message_token('STEP','4');
				 hr_utility.raise_error;
		  end;
		else
		  close get_pay_proposal;
		end if;
      hr_utility.set_location('update_row - after update',5);
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
		--
   end if;
   --
   p_status := 'END'; -- Status required to end update loop on server
   --
end update_row;
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
and   paf.effective_end_date >= p_old_hire_date;
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
select pps.final_process_date
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
begin
  hr_utility.set_location('hr_person.check_rehire',1);
  --
  -- Check if old PPS row exists
  --
  open old_pps_exists;
  fetch old_pps_exists into v_dummy;
  if old_pps_exists%FOUND
  then
    close old_pps_exists;
	 --
	 -- if yes then check last PPS
	 -- has had it's FPD closed down and that the FPD + 1
	 -- is less than current hire date
	 -- if not error;
	 --
    open pps_not_ended;
    fetch pps_not_ended into v_dummy_fpd;
    if pps_not_ended%FOUND then
      close pps_not_ended;
      if v_dummy_fpd is null then
         hr_utility.set_message('800','HR_51032_EMP_PREV_FPD_OPEN');
      else
         hr_utility.set_message('800','PER_289308_FUTURE_ENDED_FPD');
      end if;
      hr_utility.raise_error;
    end if;
    close pps_not_ended;
  else
    close old_pps_exists;
  end if;
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
--

procedure original_date_of_hire (p_person_id             IN NUMBER
                                ,p_original_date_of_hire IN DATE
                                ,p_hire_date             IN DATE
                                ,p_business_group_id     IN NUMBER
                                ,p_person_type_id        IN NUMBER
                                ,p_period_of_service_id  IN NUMBER
                                ,p_system_person_type   IN VARCHAR2
                                ,p_orig_hire_warning    IN OUT NOCOPY BOOLEAN
                                 )
is
--
l_earliest_date date;
l_end_date date; --Added for fix of #3632547
l_session_date date; --Added for fix of #3632547
l_period_of_service_id number;
--
cursor csr_earliest_date is
select date_start, period_of_service_id,actual_termination_date
from per_periods_of_service
where p_person_id = person_id
order by date_start desc ;-- fix for bug 4672540.
--
begin
--
p_orig_hire_warning := FALSE;
--

  if p_original_date_of_hire is NOT NULL then
--
    if p_system_person_type in ('EMP','EMP_APL','EX_EMP','EX_EMP_APL') then
--
      if  p_original_date_of_hire > p_hire_date then
        hr_utility.set_message(800,'PER_52474_PER_ORIG_ST_DATE');
        hr_utility.raise_error;
--
      elsif p_person_id is not null then
-- commented out the following code for bug 4672540 as l_session_date is no longer needed.
       -- start of fix  #3632547
  /*     begin
         select effective_date
         into l_session_date
         from fnd_sessions
         where session_id=userenv('SESSIONID');
       exception
        when no_data_found then
         l_session_date := null;
       end; */
 -- end of fix #3632547
        open csr_earliest_date;
        fetch csr_earliest_date into l_earliest_date, l_period_of_service_id,l_end_date;
        --Modified the if condition for fix of #3632547
        if ( (l_period_of_service_id = p_period_of_service_id)
              and
             ( (l_end_date is null) or
               ( (l_end_date is not null) and
                  --fix for bug 4672540
                 (nvl(p_original_date_of_hire,l_earliest_date) not between l_earliest_date and l_end_date)
               )
             )
           ) then
           l_earliest_date := p_hire_date;
        end if;
        if p_original_date_of_hire > l_earliest_date then
          hr_utility.set_message(800,'PER_52474_PER_ORIG_ST_DATE');
          hr_utility.raise_error;
        end if;
        close csr_earliest_date;
      end if;
--
    elsif p_system_person_type not in ('EMP','EMP_APL','EX_EMP','EX_EMP_APL')
      then p_orig_hire_warning := TRUE;
    end if;
 end if;
end;
--

END PER_PEOPLE4_PKG;

/
