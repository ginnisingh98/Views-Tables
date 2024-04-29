--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE9_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE9_PKG" AS
/* $Header: peper09t.pkb 120.1 2006/03/03 05:49:29 lsilveir noship $ */
--
procedure insert_applicant_rows(p_person_id NUMBER
                              ,p_effective_start_date DATE
                              ,p_effective_end_date DATE
                              ,p_business_group_id NUMBER
                              ,p_app_ass_status_type_id NUMBER
                              ,p_request_id NUMBER
                              ,p_program_application_id NUMBER
                              ,p_program_id NUMBER
                              ,p_program_update_date DATE
                              ,p_last_update_date DATE
                              ,p_last_updated_by NUMBER
                              ,p_last_update_login NUMBER
                              ,p_created_by NUMBER
                              ,p_creation_date DATE) is
--
-- Inserts default applicant assignment
--
--
-- local variables
--
l_row_id VARCHAR2(30);           -- Dummy strorage for ROWID.
l_location_id NUMBER(15);        -- Location_id of Business_group
l_time_normal_start VARCHAR2(30);-- BG's start time from Work day defaults.
l_time_normal_end VARCHAR2(30);  -- BG's end  time from Work day defaults.
l_normal_hours number;           -- BG's normal hours from Work day defaults.
l_frequency VARCHAR2(30);        -- BG's frequency from Work day defaults.
l_application_id NUMBER;         -- Dummy return for application id.
l_assignment_id NUMBER;          -- Dummy return for assignment_id.
l_assignment_sequence NUMBER;    -- Dummy return for assignment_sequence.
--
begin
   hr_utility.set_location('per_people9_pkg.insert_applicant_rows',1);
   per_applications_pkg.insert_Row(
                              p_Rowid =>l_row_id,
                              p_Application_Id   =>l_application_id,
                              p_Business_Group_Id =>p_business_group_id,
                              p_Person_Id         =>p_person_id,
                              p_Date_Received     => p_effective_start_date,
                              p_Comments          =>NULL,
                              p_Current_Employer  =>NULL,
                              p_Date_End          =>NULL,
                              p_Projected_Hire_Date =>NULL,
                              p_Successful_Flag     =>NULL,
                              p_Termination_Reason  =>NULL,
                              p_Appl_Attribute_Category =>NULL,
                              p_Appl_Attribute1         =>NULL,
                              p_Appl_Attribute2         =>NULL,
                              p_Appl_Attribute3         =>NULL,
                              p_Appl_Attribute4         =>NULL,
                              p_Appl_Attribute5         =>NULL,
                              p_Appl_Attribute6         =>NULL,
                              p_Appl_Attribute7         =>NULL,
                              p_Appl_Attribute8         =>NULL,
                              p_Appl_Attribute9         =>NULL,
                              p_Appl_Attribute10        =>NULL,
                              p_Appl_Attribute11        =>NULL,
                              p_Appl_Attribute12        =>NULL,
                              p_Appl_Attribute13        =>NULL,
                              p_Appl_Attribute14        =>NULL,
                              p_Appl_Attribute15        =>NULL,
                              p_Appl_Attribute16        =>NULL,
                              p_Appl_Attribute17        =>NULL,
                              p_Appl_Attribute18        =>NULL,
                              p_Appl_Attribute19        =>NULL,
                              p_Appl_Attribute20        =>NULL,
                              p_Last_Update_Date        =>NULL,
                              p_Last_Updated_By         =>NULL,
                              p_Last_Update_Login       =>NULL,
                              p_Created_By              =>NULL,
                              p_Creation_Date           =>NULL);
   -- Insert the applicant assignment.
   --
   hr_utility.set_location('per_people9_pkg.insert_applicant_assignment',2);
   hr_assignment.gen_new_ass_sequence(p_person_id
          ,'A'
          ,l_assignment_sequence);
   begin
      --
      -- get the default location and times.
      --
      select pbg.location_id
      ,      pbg.default_start_time
      ,      pbg.default_end_time
      ,      fnd_number.canonical_to_number(pbg.working_hours)
      ,      pbg.frequency
      into   l_location_id
      ,      l_time_normal_start
      ,      l_time_normal_end
      ,      l_normal_hours
      ,      l_frequency
      from per_business_groups pbg
      where pbg.business_group_id = p_business_group_id;
      --
      exception
         when no_data_found then
            hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','Insert Applicant Rows');
            hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
   hr_utility.set_location('per_people9_pkg.insert_applicant_assignment',3);
   end;
   --
   -- Insert the Applicant assignment
   --
   --
	-- 340022 Made p_source_organiation_id = NULL
	-- Rather than p_business_group_id
	-- 311758 Assignment_number now nulled rather than set to 1.
	-- TM 08-mar-1996.
   per_assignments_f_pkg.insert_row(
                  p_row_id =>l_row_id
                  ,p_assignment_id                 => l_assignment_id
                  ,p_effective_start_date          => p_effective_start_date
                  ,p_effective_end_date            => p_effective_end_date
                  ,p_business_group_id             => p_business_group_id
                  ,p_recruiter_id                  =>NULL
                  ,p_grade_id                      =>NULL
                  ,p_position_id                   =>NULL
                  ,p_job_id                        =>NULL
                  ,p_assignment_status_type_id     => p_app_ass_status_type_id
                  ,p_payroll_id                    =>NULL
                  ,p_location_id                   =>l_location_id
                  ,p_person_referred_by_id         => NULL
                  ,p_supervisor_id                 => NULL
                  ,p_special_ceiling_step_id       => NULL
                  ,p_person_id                     => p_person_id
                  ,p_recruitment_activity_id       => NULL
                  ,p_source_organization_id        => NULL
                  ,p_organization_id               => p_business_group_id
                  ,p_people_group_id               => NULL
                  ,p_soft_coding_keyflex_id        => NULL
                  ,p_vacancy_id                    => NULL
                  ,p_assignment_sequence           => l_assignment_sequence
                  ,p_assignment_type               =>'A'
                  ,p_primary_flag                  => 'N'
                  ,p_application_id                => l_application_id
                  ,p_assignment_number             => NULL
                  ,p_change_reason                 => NULL
                  ,p_comment_id                    => NULL
                  ,p_date_probation_end            => NULL
                  ,p_default_code_comb_id          => NULL
                  ,p_frequency                     => l_frequency
                  ,p_internal_address_line         => NULL
                  ,p_manager_flag                  => 'N'
                  ,p_normal_hours                  => l_normal_hours
                  ,p_period_of_service_id          => NULL
                  ,p_probation_period              => NULL
                  ,p_probation_unit                => NULL
                  ,p_set_of_books_id               => NULL
                  ,p_source_type                   => NULL
                  ,p_time_normal_finish            => l_time_normal_end
                  ,p_time_normal_start             => l_time_normal_start
                  ,p_request_id                    => p_request_id
                  ,p_program_application_id        => p_program_application_id
                  ,p_program_id                    => p_program_id
                  ,p_program_update_date           => p_program_update_date
                  ,p_ass_attribute_category        => NULL
                  ,p_ass_attribute1                => NULL
                  ,p_ass_attribute2                => NULL
                  ,p_ass_attribute3                => NULL
                  ,p_ass_attribute4                => NULL
                  ,p_ass_attribute5                => NULL
                  ,p_ass_attribute6                => NULL
                  ,p_ass_attribute7                => NULL
                  ,p_ass_attribute8                => NULL
                  ,p_ass_attribute9                => NULL
                  ,p_ass_attribute10               => NULL
                  ,p_ass_attribute11               => NULL
                  ,p_ass_attribute12               => NULL
                  ,p_ass_attribute13               => NULL
                  ,p_ass_attribute14               => NULL
                  ,p_ass_attribute15               => NULL
                  ,p_ass_attribute16               => NULL
                  ,p_ass_attribute17               => NULL
                  ,p_ass_attribute18               => NULL
                  ,p_ass_attribute19               => NULL
                  ,p_ass_attribute20               => NULL
                  ,p_ass_attribute21               => NULL
                  ,p_ass_attribute22               => NULL
                  ,p_ass_attribute23               => NULL
                  ,p_ass_attribute24               => NULL
                  ,p_ass_attribute25               => NULL
                  ,p_ass_attribute26               => NULL
                  ,p_ass_attribute27               => NULL
                  ,p_ass_attribute28               => NULL
                  ,p_ass_attribute29               => NULL
                  ,p_ass_attribute30               => NULL
                  ,p_sal_review_period             => NULL
                  ,p_sal_review_period_frequency   => NULL
                  ,p_perf_review_period            => NULL
                  ,p_perf_review_period_frequency  => NULL
                  ,p_pay_basis_id                  => NULL
                  ,p_employment_category           => NULL
                  ,p_bargaining_unit_code          => NULL
                  ,p_labour_union_member_flag      => NULL
		  ,p_hourly_salaried_code          => NULL
);

   --
   -- BUg 346814 changed the order of insert letter
   -- and insert_assignment calls.
   -- TM 05-03-96
   --
   --
   -- if application assignment  insert ok
   --
   -- Fix for bug 3612059 starts here.
   -- Use check_for_letter_requests procedure call instead of the following call.
   --
   /*
   per_applications_pkg.insert_letter_term(p_business_group_id =>p_business_group_id
                                          ,p_application_id => l_application_id
                                          ,p_person_id =>p_person_id
                                          ,p_session_date =>p_effective_start_date
                                          ,p_Last_Updated_By => NULL
                                          ,p_Last_Update_Login => NULL
                                          ,p_assignment_status_type_id =>
                                           p_app_ass_status_type_id);
   */
   --
   per_applicant_pkg.check_for_letter_requests (
                p_business_group_id         => p_business_group_id,
		p_per_system_status         => NULL,
		p_assignment_status_type_id => p_app_ass_status_type_id,
		p_person_id	                => p_person_id,
		p_assignment_id	            => l_assignment_id,
		p_effective_start_date      => p_effective_start_date,
		p_validation_start_date     => p_effective_start_date,
                p_vacancy_id                => NULL ) ;
   --
   -- Fix for bug 3612059 ends here.
   --
   -- load the default budget values
   --
   hr_assignment.load_budget_values(l_assignment_id
                                   ,p_business_group_id
                                   ,p_last_updated_by
                                   ,p_last_update_login
				   ,p_effective_start_date
				   ,p_effective_end_date);
--
end;
--
procedure insert_employee_rows(p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_emp_ass_status_type_id NUMBER
   ,p_employee_number VARCHAR2
   ,p_request_id NUMBER
   ,p_program_application_id NUMBER
   ,p_program_id NUMBER
   ,p_program_update_date DATE
   ,p_last_update_date DATE
   ,p_last_updated_by NUMBER
   ,p_last_update_login NUMBER
   ,p_created_by NUMBER
   ,p_creation_date DATE
   ,p_adjusted_svc_date DATE) is
--
-- Inserts default employee assignment
--
--
-- local variables
--
l_row_id VARCHAR2(30);           -- Dummy strorage for ROWID.
l_location_id NUMBER(15);        -- Location_id of Business_group
l_time_normal_start VARCHAR2(30);-- BG's start time from Work day defaults.
l_time_normal_end VARCHAR2(30);  -- BG's end  time from Work day defaults.
l_normal_hours NUMBER;           -- BG's normal hours from Work day defaults.
l_frequency VARCHAR2(30);        -- BG's frequency from Work day defaults.
l_period_of_service_id NUMBER;   -- Dummy return for period_of_service_id.
l_assignment_id NUMBER;          -- Dummy return for assignment_id.
l_assignment_id_temp NUMBER;          -- Dummy return for assignment_id.
l_assignment_sequence NUMBER;    -- Dummy return for assignment_sequence.
l_assignment_number VARCHAR2(30);-- Dummy return for assignment_number.
l_primary_flag VARCHAR2(1);      -- Dummy return for primary_flag
l_warning VARCHAR2(1);           -- Dummy return for warning;
--
--start WWBUG 2130950 hrwf synchronization --tpapired
  l_asg_rec                per_all_assignments_f%rowtype;
  cursor l_asg_cur is
    select *
        from per_all_assignments_f
        where   assignment_id           = L_ASSIGNMENT_ID
        and     effective_start_date    = P_EFFECTIVE_START_DATE
    and     effective_end_date          = P_EFFECTIVE_END_DATE;
--End WWBUG 2130950 for testing hrwf synchronization -tpapired
--
begin
   begin
      --
      -- get the default location and times.
      --
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',1);
      select pbg.location_id
      ,      pbg.default_start_time
      ,      pbg.default_end_time
      ,      fnd_number.canonical_to_number(pbg.working_hours)
      ,      pbg.frequency
      into   l_location_id
      ,      l_time_normal_start
      ,      l_time_normal_end
      ,      l_normal_hours
      ,      l_frequency
      from per_business_groups pbg
      where pbg.business_group_id = p_business_group_id;
      --
      exception
         when no_data_found then
            hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
            hr_utility.set_message_token('PROCEDURE','Insert Employee rows');
            hr_utility.set_message_token('STEP','1');
            hr_utility.raise_error;
   end;
   --
   -- Insert Period of service.
   --
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',2);
   per_periods_of_service_pkg.insert_row(l_row_id
                      ,p_period_of_service_id => l_period_of_service_id
                      ,p_business_group_id          => p_business_group_id
                      ,p_person_id                  => p_person_id
                      ,p_date_start                 => p_effective_start_date
                      ,p_termination_accepted_per_id  =>NULL
                      ,p_accepted_termination_date  =>NULL
                      ,p_actual_termination_date    =>NULL
                      ,p_comments                   =>NULL
                      ,p_final_process_date         =>NULL
                      ,p_last_standard_process_date =>NULL
                      ,p_leaving_reason             =>NULL
                      ,p_notified_termination_date  =>NULL
                      ,p_projected_termination_date =>NULL
                      ,p_request_id                 => p_request_id
                      ,p_program_application_id     => p_program_application_id
                      ,p_program_id                 => p_program_id
                      ,p_program_update_date        => p_program_update_date
                      ,p_attribute_category         =>NULL
                      ,p_attribute1                 =>NULL
                      ,p_attribute2                 =>NULL
                      ,p_attribute3                 =>NULL
                      ,p_attribute4                 =>NULL
                      ,p_attribute5                 =>NULL
                      ,p_attribute6                 =>NULL
                      ,p_attribute7                 =>NULL
                      ,p_attribute8                 =>NULL
                      ,p_attribute9                 =>NULL
                      ,p_attribute10                =>NULL
                      ,p_attribute11                =>NULL
                      ,p_attribute12                =>NULL
                      ,p_attribute13                =>NULL
                      ,p_attribute14                =>NULL
                      ,p_attribute15                =>NULL
                      ,p_attribute16                =>NULL
                      ,p_attribute17                =>NULL
                      ,p_attribute18                =>NULL
                      ,p_attribute19                =>NULL
                      ,p_attribute20                =>NULL
                      ,p_adjusted_svc_date          =>p_adjusted_svc_date);
   --
   -- If period of service entered ok
   --
   -- Then enter employee assignment
   --
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',3);
   hr_assignment.gen_new_ass_sequence(p_person_id
                                     ,'E'
                                     ,l_assignment_sequence);
   --
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',4);
   hr_assignment.gen_new_ass_number(''
                                  ,p_business_group_id
                                  ,p_employee_number
                                  ,l_assignment_sequence
                                  ,l_assignment_number);
   --
	-- 340021 Made p_source_organiation_id = NULL
	-- Rather than p_business_group_id
	-- TM 08-mar-1996.
	--
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',5);
   per_assignments_f_pkg.insert_row(p_row_id =>l_row_id
                   ,p_assignment_id                 => l_assignment_id
                   ,p_effective_start_date          => p_effective_start_date
                   ,p_effective_end_date            => p_effective_end_date
                   ,p_business_group_id             => p_business_group_id
                   ,p_recruiter_id                  =>NULL
                   ,p_grade_id                      =>NULL
                   ,p_position_id                   =>NULL
                   ,p_job_id                        =>NULL
                   ,p_assignment_status_type_id     => p_emp_ass_status_type_id
                   ,p_payroll_id                    =>NULL
                   ,p_location_id                   =>l_location_id
                   ,p_person_referred_by_id         => NULL
                   ,p_supervisor_id                 => NULL
                   ,p_special_ceiling_step_id       => NULL
                   ,p_person_id                     => p_person_id
                   ,p_recruitment_activity_id       => NULL
                   ,p_source_organization_id        => NULL
                   ,p_organization_id               => p_business_group_id
                   ,p_people_group_id               => NULL
                   ,p_soft_coding_keyflex_id        => NULL
                   ,p_vacancy_id                    => NULL
                   ,p_assignment_sequence           => l_assignment_sequence
                   ,p_assignment_type               =>'E'
                   ,p_primary_flag                  =>'Y'
                   ,p_application_id                => NULL
                   ,p_assignment_number             => l_assignment_number
                   ,p_change_reason                 => NULL
                   ,p_comment_id                    => NULL
                   ,p_date_probation_end            => NULL
                   ,p_default_code_comb_id          => NULL
                   ,p_frequency                     => l_frequency
                   ,p_internal_address_line         => NULL
                   ,p_manager_flag                  => 'N'
                   ,p_normal_hours                  => l_normal_hours
                   ,p_period_of_service_id          => l_period_of_service_id
                   ,p_probation_period              => NULL
                   ,p_probation_unit                => NULL
                   ,p_set_of_books_id               => NULL
                   ,p_source_type                   => NULL
                   ,p_time_normal_finish            => l_time_normal_end
                   ,p_time_normal_start             => l_time_normal_start
                   ,p_request_id                    => p_request_id
                   ,p_program_application_id        => p_program_application_id
                   ,p_program_id                    => p_program_id
                   ,p_program_update_date           => p_program_update_date
                   ,p_ass_attribute_category        => NULL
                   ,p_ass_attribute1                => NULL
                   ,p_ass_attribute2                => NULL
                   ,p_ass_attribute3                => NULL
                   ,p_ass_attribute4                => NULL
                   ,p_ass_attribute5                => NULL
                   ,p_ass_attribute6                => NULL
                   ,p_ass_attribute7                => NULL
                   ,p_ass_attribute8                => NULL
                   ,p_ass_attribute9                => NULL
                   ,p_ass_attribute10               => NULL
                   ,p_ass_attribute11               => NULL
                   ,p_ass_attribute12               => NULL
                   ,p_ass_attribute13               => NULL
                   ,p_ass_attribute14               => NULL
                   ,p_ass_attribute15               => NULL
                   ,p_ass_attribute16               => NULL
                   ,p_ass_attribute17               => NULL
                   ,p_ass_attribute18               => NULL
                   ,p_ass_attribute19               => NULL
                   ,p_ass_attribute20               => NULL
                   ,p_ass_attribute21               => NULL
                   ,p_ass_attribute22               => NULL
                   ,p_ass_attribute23               => NULL
                   ,p_ass_attribute24               => NULL
                   ,p_ass_attribute25               => NULL
                   ,p_ass_attribute26               => NULL
                   ,p_ass_attribute27               => NULL
                   ,p_ass_attribute28               => NULL
                   ,p_ass_attribute29               => NULL
                   ,p_ass_attribute30               => NULL
                   ,p_sal_review_period             => NULL
                   ,p_sal_review_period_frequency   => NULL
                   ,p_perf_review_period            => NULL
                   ,p_perf_review_period_frequency  => NULL
                   ,p_pay_basis_id                  => NULL
                   ,p_employment_category           => NULL
                   ,p_bargaining_unit_code          => NULL
                   ,p_labour_union_member_flag      => NULL
		   ,p_hourly_salaried_code          => NULL);

--
-- 115.10 (START)
--
   --
   -- Handle potentially overlapping PDS due to rehire before FPD
   --
   hr_employee_api.manage_rehire_primary_asgs
      (p_person_id   => p_person_id
      ,p_rehire_date => p_effective_start_date
      ,p_cancel      => 'N'
      );
--
-- 115.10 (END)
--

   --START WWBUG 2130950  HR/WF SYNCH -- tpapired
   --
   open l_asg_cur;
   fetch l_asg_cur into l_asg_rec;
   close l_asg_cur;

   per_hrwf_synch.per_asg_wf(
                      p_rec       => l_asg_rec,
                      p_action    => 'INSERT');
   --
   --END WWBUG 2130950  HR/WF SYNCH -- tpapired
   -- Populate security list for new employee.
   hr_security_internal.populate_new_person(
                              p_business_group_id=>p_business_group_id,
			      p_person_id        =>p_person_id);

   -- Load Budget value defaults
   l_primary_flag := 'Y';
   hr_utility.set_location('per_people9_pkg.insert_employee_rows',6);
   PER_ASSIGNMENTS_F1_PKG.post_insert(p_prim_change_flag =>l_primary_flag
                                 ,p_val_st_date => p_effective_start_date
                                 ,p_new_end_date =>p_effective_end_date
                                 ,p_eot =>p_effective_end_date
                                 ,p_pd_os_id => NULL
                                 ,p_ass_id =>l_assignment_id
                                 ,p_new_prim_ass_id =>l_assignment_id_temp
                                 ,p_pg_id => NULL
                                 ,p_group_name => NULL
                                 ,p_bg_id => p_business_group_id
                                 ,p_dt_upd_mode => NULL
                                 ,p_dt_del_mode => NULL
                                 ,p_per_sys_st => NULL
                                 ,p_sess_date =>p_effective_start_date
                                 ,p_val_end_date =>p_effective_end_date
                                 ,p_new_pay_id => NULL
                                 ,p_old_pay_id => NULL
                                 ,p_scl_id => NULL
                                 ,p_scl_concat => NULL
                                 ,p_warning =>l_warning );
   --
end;
--
procedure update_old_person_row(p_person_id NUMBER
                               ,p_session_date DATE
                               ,p_effective_start_date DATE) is
l_rowid VARCHAR2(18);
cursor old_per is
select rowid
from per_people_f
where person_id = p_person_id
and   effective_end_date = p_session_date -1
for update of effective_end_date;
begin
   open old_per;
   fetch old_per into l_rowid;
   if old_per%NOTFOUND then
      return;
   end if;
   close old_per;
   begin
     update per_people_f
     set effective_end_date = p_effective_start_date -1
     where rowid = l_rowid;
     --
     if sql%rowcount <> 1 then
       fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE','update_old_person');
       fnd_message.set_token('STEP','2');
       app_exception.raise_exception;
     end if;
  end;
end update_old_person_row;
--
--
END per_people9_pkg;

/
