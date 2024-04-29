--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_F_PKG" AS
/* $Header: peasg01t.pkb 120.29.12010000.8 2009/12/08 12:33:48 brsinha ship $ */
-----------------------------------------------------------------------------
--
--  **** Standard ON-* procedures of base view. *****
--
-----------------------------------------------------------------------------
--
-- Standard Insert procedure
--
--bug no 6028006 starts here
--g_package  varchar2(21) := 'PER_ASSIGNMENTS_F_PKG.';
  g_package  varchar2(22) := 'PER_ASSIGNMENTS_F_PKG.';
--bug no 6028006 ends here
g_debug    boolean; -- debug flag
--
procedure insert_row(
   p_row_id                           in out nocopy varchar2,
   p_assignment_id                    in out nocopy number,
   p_effective_start_date             date,
   p_effective_end_date               date,
   p_business_group_id                number,
   p_recruiter_id                     number,
   p_grade_id                         number,
   p_position_id                      number,
   p_job_id                           number,
   p_assignment_status_type_id        number,
   p_payroll_id                       number,
   p_location_id                      number,
   p_person_referred_by_id            number,
   p_supervisor_id                    number,
   p_special_ceiling_step_id          number,
   p_person_id                        number,
   p_recruitment_activity_id          number,
   p_source_organization_id           number,
   p_organization_id                  number,
   p_people_group_id                  number,
   p_soft_coding_keyflex_id           number,
   p_vacancy_id                       number,
   p_assignment_sequence              number,
   p_assignment_type                  varchar2,
   p_primary_flag                     varchar2,
   p_application_id                   number,
   p_assignment_number                varchar2,
   p_change_reason                    varchar2,
   p_comment_id                       number,
   p_date_probation_end               date,
   p_default_code_comb_id             number,
   p_frequency                        varchar2,
   p_internal_address_line            varchar2,
   p_manager_flag                     varchar2,
   p_normal_hours                     number,
   p_period_of_service_id             number,
   p_probation_period                 number,
   p_probation_unit                   varchar2,
   p_set_of_books_id                  number,
   p_source_type                      varchar2,
   p_time_normal_finish               varchar2,
   p_time_normal_start                varchar2,
   p_request_id                       number,
   p_program_application_id           number,
   p_program_id                       number,
   p_program_update_date              date,
   p_ass_attribute_category           varchar2,
   p_ass_attribute1                   varchar2,
   p_ass_attribute2                   varchar2,
   p_ass_attribute3                   varchar2,
   p_ass_attribute4                   varchar2,
   p_ass_attribute5                   varchar2,
   p_ass_attribute6                   varchar2,
   p_ass_attribute7                   varchar2,
   p_ass_attribute8                   varchar2,
   p_ass_attribute9                   varchar2,
   p_ass_attribute10                  varchar2,
   p_ass_attribute11                  varchar2,
   p_ass_attribute12                  varchar2,
   p_ass_attribute13                  varchar2,
   p_ass_attribute14                  varchar2,
   p_ass_attribute15                  varchar2,
   p_ass_attribute16                  varchar2,
   p_ass_attribute17                  varchar2,
   p_ass_attribute18                  varchar2,
   p_ass_attribute19                  varchar2,
   p_ass_attribute20                  varchar2,
   p_ass_attribute21                  varchar2,
   p_ass_attribute22                  varchar2,
   p_ass_attribute23                  varchar2,
   p_ass_attribute24                  varchar2,
   p_ass_attribute25                  varchar2,
   p_ass_attribute26                  varchar2,
   p_ass_attribute27                  varchar2,
   p_ass_attribute28                  varchar2,
   p_ass_attribute29                  varchar2,
   p_ass_attribute30                  varchar2,
   p_sal_review_period                number,
   p_sal_review_period_frequency      varchar2,
   p_perf_review_period               number,
   p_perf_review_period_frequency     varchar2,
   p_pay_basis_id                     number,
   p_employment_category              varchar2,
   p_bargaining_unit_code             varchar2,
   p_labour_union_member_flag         varchar2,
   p_hourly_salaried_code             varchar2,
   p_contract_id                      number   default null,
   p_cagr_id_flex_num                 number   default null,
   p_cagr_grade_def_id                number   default null,
   p_establishment_id                 number   default null,
   p_collective_agreement_id          number   default null,
   p_notice_period                    number   default null,
   p_notice_period_uom                varchar2 default null,
   p_employee_category                varchar2 default null,
   p_work_at_home                     varchar2 default null,
   p_job_post_source_name             varchar2 default null,
   p_placement_date_start             date     default null,
   p_vendor_id                        number   default null,
   p_vendor_employee_number           varchar2 default null,
   p_vendor_assignment_number         varchar2 default null,
   p_assignment_category              varchar2 default null,
   p_title                            varchar2 default null,
   p_project_title                    varchar2 default null,
   p_grade_ladder_pgm_id              number   default null,
   p_supervisor_assignment_id         number   default null,
   p_vendor_site_id                   number   default null,
   p_po_header_id                     number   default null,
   p_po_line_id                       number   default null,
   p_projected_assignment_end         date     default null
 ) is
    l_assignment_status_id  number; --discards irc_status_type out params
    l_object_version_number  number;
--
    l_return_code        number;
    l_return_text        varchar2(240);
    l_session_date       date;
    l_proc               varchar2(200):= 'PER_ASSIGNMENTS_F_PKG.INSERT_ROW';
    l_labour_union_member_flag  varchar2(1); -- bug fix 7698212
    --
/*
    --WWBUG 2130950 Begin hrwf synchronization --tpapired
      l_asg_rec                per_all_assignments_f%rowtype;
      cursor l_asg_cur is
        select *
        from per_all_assignments_f
        where assignment_id           = P_ASSIGNMENT_ID
        and   effective_start_date    = P_EFFECTIVE_START_DATE
        and   effective_end_date      = P_EFFECTIVE_END_DATE;
      --WWBUG 2130950 End hrwf synchronization -tpapired
   --
*/
-- Bug 1319140 fix begin: Added US legislation code check.
    l_legislation_code   varchar2(150);

    cursor   ac1 is
          select legislation_code
            from per_business_groups
           where business_group_id = P_BUSINESS_GROUP_ID;
-- Bug 1319140 fix end: Added US legislation code check.


cursor c1 is
   select   per_assignments_s.nextval
   from  sys.dual;
cursor c2 is
   select   rowid
   from  per_assignments_f
   where assignment_id     = P_ASSIGNMENT_ID
   and     effective_start_date     = P_EFFECTIVE_START_DATE
        and     effective_end_date     = P_EFFECTIVE_END_DATE;
begin
   open c1;
   fetch c1 into P_ASSIGNMENT_ID;
   close c1;
--
/*-- Start change for the bug 5854568  ----*/
   hr_utility.set_location('Entering '||l_proc,20);
   hr_utility.set_location('In the insert row',21);
   hr_utility.set_location('Assgid= '||P_ASSIGNMENT_ID,22);
   hr_utility.set_location('Pid= '||p_position_id,23);
   hr_utility.set_location('Date= '||P_EFFECTIVE_START_DATE,24);

   per_asg_bus1.chk_frozen_single_pos
    (p_assignment_id         =>  P_ASSIGNMENT_ID
    ,p_position_id           =>  p_position_id
    ,p_effective_date        =>  P_EFFECTIVE_START_DATE
    ,p_assignment_type	     =>  p_assignment_type	 -- 6356978
    );
/*-- End change for the bug 5854568  ----*/
l_labour_union_member_flag := nvl(p_labour_union_member_flag,'N'); -- bug fix 7698212
   begin
     insert into per_assignments_f (
   assignment_id,
   effective_start_date,
   effective_end_date,
   business_group_id,
   recruiter_id,
   grade_id,
   position_id,
   job_id,
   assignment_status_type_id,
   payroll_id,
   location_id,
   person_referred_by_id,
   supervisor_id,
   special_ceiling_step_id,
   person_id,
   recruitment_activity_id,
   source_organization_id,
   organization_id,
   people_group_id,
   soft_coding_keyflex_id,
   vacancy_id,
   assignment_sequence,
   assignment_type,
   primary_flag,
   application_id,
   assignment_number,
   change_reason,
   comment_id,
   date_probation_end,
   default_code_comb_id,
   frequency,
   internal_address_line,
   manager_flag,
   normal_hours,
   period_of_service_id,
   probation_period,
   probation_unit,
   set_of_books_id,
   source_type,
   time_normal_finish,
   time_normal_start,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   ass_attribute_category,
   ass_attribute1,
   ass_attribute2,
   ass_attribute3,
   ass_attribute4,
   ass_attribute5,
   ass_attribute6,
   ass_attribute7,
   ass_attribute8,
   ass_attribute9,
   ass_attribute10,
   ass_attribute11,
   ass_attribute12,
   ass_attribute13,
   ass_attribute14,
   ass_attribute15,
   ass_attribute16,
   ass_attribute17,
   ass_attribute18,
   ass_attribute19,
   ass_attribute20,
   ass_attribute21,
   ass_attribute22,
   ass_attribute23,
   ass_attribute24,
   ass_attribute25,
   ass_attribute26,
   ass_attribute27,
   ass_attribute28,
   ass_attribute29,
   ass_attribute30,
   sal_review_period,
   sal_review_period_frequency,
   perf_review_period,
   perf_review_period_frequency,
   pay_basis_id,
   employment_category,
        bargaining_unit_code,
        labour_union_member_flag,
        hourly_salaried_code,
   contract_id,
   cagr_id_flex_num,
   cagr_grade_def_id,
   establishment_id,
   collective_agreement_id,
   notice_period,
   notice_period_uom,
   work_at_home,
   employee_category,
   job_post_source_name,
        period_of_placement_date_start,
        vendor_id,
        vendor_employee_number,
        vendor_assignment_number,
        assignment_category,
        title,
        project_title,
        grade_ladder_pgm_id,
        supervisor_assignment_id,
        vendor_site_id,
        po_header_id,
        po_line_id,
        projected_assignment_end)
values (
   p_assignment_id,
   p_effective_start_date,
   p_effective_end_date,
   p_business_group_id,
   p_recruiter_id,
   p_grade_id,
   p_position_id,
   p_job_id,
   p_assignment_status_type_id,
   p_payroll_id,
   p_location_id,
   p_person_referred_by_id,
   p_supervisor_id,
   p_special_ceiling_step_id,
   p_person_id,
   p_recruitment_activity_id,
   p_source_organization_id,
   p_organization_id,
   p_people_group_id,
   p_soft_coding_keyflex_id,
   p_vacancy_id,
   p_assignment_sequence,
   p_assignment_type,
   p_primary_flag,
   p_application_id,
   p_assignment_number,
   p_change_reason,
   p_comment_id,
   p_date_probation_end,
   p_default_code_comb_id,
   p_frequency,
   p_internal_address_line,
   p_manager_flag,
   p_normal_hours,
   p_period_of_service_id,
   p_probation_period,
   p_probation_unit,
   p_set_of_books_id,
   p_source_type,
   p_time_normal_finish,
   p_time_normal_start,
   p_request_id,
   p_program_application_id,
   p_program_id,
   p_program_update_date,
   p_ass_attribute_category,
   p_ass_attribute1,
   p_ass_attribute2,
   p_ass_attribute3,
   p_ass_attribute4,
   p_ass_attribute5,
   p_ass_attribute6,
   p_ass_attribute7,
   p_ass_attribute8,
   p_ass_attribute9,
   p_ass_attribute10,
   p_ass_attribute11,
   p_ass_attribute12,
   p_ass_attribute13,
   p_ass_attribute14,
   p_ass_attribute15,
   p_ass_attribute16,
   p_ass_attribute17,
   p_ass_attribute18,
   p_ass_attribute19,
   p_ass_attribute20,
   p_ass_attribute21,
   p_ass_attribute22,
   p_ass_attribute23,
   p_ass_attribute24,
   p_ass_attribute25,
   p_ass_attribute26,
   p_ass_attribute27,
   p_ass_attribute28,
   p_ass_attribute29,
   p_ass_attribute30,
   p_sal_review_period,
   p_sal_review_period_frequency,
   p_perf_review_period,
   p_perf_review_period_frequency,
   p_pay_basis_id,
   p_employment_category,
        p_bargaining_unit_code,
        l_labour_union_member_flag, -- bug fix 7698212.
        p_hourly_salaried_code,
   p_contract_id,
   p_cagr_id_flex_num,
   p_cagr_grade_def_id,
   p_establishment_id,
   p_collective_agreement_id,
   p_notice_period,
   p_notice_period_uom,
   p_work_at_home,
   p_employee_category,
   p_job_post_source_name,
        p_placement_date_start,
        p_vendor_id,
        p_vendor_employee_number,
        p_vendor_assignment_number,
        p_assignment_category,
        p_title,
        p_project_title,
        p_grade_ladder_pgm_id,
        p_supervisor_assignment_id,
        p_vendor_site_id,
        p_po_header_id,
        p_po_line_id,
        p_projected_assignment_end
);
   end;
--
    hr_utility.set_location( l_proc, 30);

    -- Insert a row into irc_assignment_statuses for irecruitment
if p_assignment_type = 'A' then
IRC_ASG_STATUS_API.create_irc_asg_status
            ( p_validate                   => FALSE
            , p_assignment_id              => p_assignment_id
            , p_assignment_status_type_id  => p_assignment_status_type_id
            , p_status_change_reason       => p_change_reason   -- Bug 2676934
            , p_status_change_date         => p_effective_start_date
            , p_assignment_status_id       => l_assignment_status_id
            , p_object_version_number      => l_object_version_number
             );
end if;
    hr_utility.set_location( l_proc, 40);
   open c2;
   fetch c2 into P_ROW_ID;
   close c2;
  -- bug 1228430  Adding a call to default tax with validation for
  -- new assignments.

  l_session_date := p_effective_start_date;

-- Bug 1319140 fix begin: Added US legislation code check.
    hr_utility.set_location( l_proc, 50);
   open ac1;
   fetch ac1 into l_legislation_code;
   if ac1%notfound then
        close ac1;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE',
                'PER_ASSIGNMENTS_F1_PKG.INSERT_ROW');
        fnd_message.set_token('STEP', '0');
        fnd_message.raise_error;
   end if;
   close ac1;
    hr_utility.set_location( l_proc, 60);

-- Start of fix 3634447
-- Add the person to the appropriate security lists
hr_security_internal.add_to_person_list(
                     p_effective_date => p_effective_start_date,
                     p_assignment_id  => p_assignment_id);
-- End of fix 3634447
hr_security.add_assignment(p_person_id, p_assignment_id); -- Bug 4018555
--
    hr_utility.set_location( l_proc, 70);

IF l_legislation_code = 'US' THEN
  pay_us_emp_dt_tax_rules.default_tax_with_validation(
                   p_assignment_id        => p_assignment_id,
                   p_person_id            => p_person_id,
                   p_effective_start_date => p_effective_start_date,
                   p_effective_end_date   => p_effective_end_date,
                   p_session_date         => l_session_date,
                   p_business_group_id    => p_business_group_id,
                   p_from_form            => 'Assignment',
                   p_mode                 => NULL,
                   p_location_id          => p_location_id,
                   p_return_code          => l_return_code,
                   p_return_text          => l_return_text);
END IF;
-- Bug 1319140 fix end: Added US legislation code check.
--
    hr_utility.set_location( l_proc, 80);

  ben_dt_trgr_handle.assignment
    (p_rowid                   => null
    ,p_assignment_id           => p_assignment_id
    ,p_business_group_id       => p_business_group_id
    ,p_person_id               => p_person_id
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_assignment_status_type_id  => p_assignment_status_type_id
    ,p_assignment_type         => p_assignment_type
    ,p_organization_id         => p_organization_id
    ,p_primary_flag            => p_primary_flag
    ,p_change_reason           => p_change_reason
    ,p_employment_category     => p_employment_category
    ,p_frequency               => p_frequency
    ,p_grade_id                => p_grade_id
    ,p_job_id                  => p_job_id
    ,p_position_id             => p_position_id
    ,p_location_id             => p_location_id
    ,p_normal_hours            => p_normal_hours
    ,p_payroll_id              => p_payroll_id
    ,p_pay_basis_id            => p_pay_basis_id
    ,p_bargaining_unit_code    => p_bargaining_unit_code
    ,p_labour_union_member_flag => p_labour_union_member_flag
    ,p_hourly_salaried_code    => p_hourly_salaried_code
    ,p_people_group_id    => p_people_group_id
    ,p_ass_attribute1 => p_ass_attribute1
    ,p_ass_attribute2 => p_ass_attribute2
    ,p_ass_attribute3 => p_ass_attribute3
    ,p_ass_attribute4 => p_ass_attribute4
    ,p_ass_attribute5 => p_ass_attribute5
    ,p_ass_attribute6 => p_ass_attribute6
    ,p_ass_attribute7 => p_ass_attribute7
    ,p_ass_attribute8 => p_ass_attribute8
    ,p_ass_attribute9 => p_ass_attribute9
    ,p_ass_attribute10 => p_ass_attribute10
    ,p_ass_attribute11 => p_ass_attribute11
    ,p_ass_attribute12 => p_ass_attribute12
    ,p_ass_attribute13 => p_ass_attribute13
    ,p_ass_attribute14 => p_ass_attribute14
    ,p_ass_attribute15 => p_ass_attribute15
    ,p_ass_attribute16 => p_ass_attribute16
    ,p_ass_attribute17 => p_ass_attribute17
    ,p_ass_attribute18 => p_ass_attribute18
    ,p_ass_attribute19 => p_ass_attribute19
    ,p_ass_attribute20 => p_ass_attribute20
    ,p_ass_attribute21 => p_ass_attribute21
    ,p_ass_attribute22 => p_ass_attribute22
    ,p_ass_attribute23 => p_ass_attribute23
    ,p_ass_attribute24 => p_ass_attribute24
    ,p_ass_attribute25 => p_ass_attribute25
    ,p_ass_attribute26 => p_ass_attribute26
    ,p_ass_attribute27 => p_ass_attribute27
    ,p_ass_attribute28 => p_ass_attribute28
    ,p_ass_attribute29 => p_ass_attribute29
    ,p_ass_attribute30 => p_ass_attribute30
    );
  --
/*
  --WWBUG 2130950 Begin hrwf synchronization --tpapired
    open l_asg_cur;
    fetch l_asg_cur into l_asg_rec;
    close l_asg_cur;
       per_hrwf_synch.PER_ASG_WF(
                  p_rec    => l_asg_rec,
                       p_action => 'INSERT');
  --WWBUG 2130950 End hrwf synchronization --tpapired
*/
  --
--start changes for bug 6598795

hr_assignment.update_assgn_context_value (p_business_group_id,
                                 p_person_id,
                                 p_assignment_id,
                                 p_effective_start_date);

--end changes for bug 6598795
--
end insert_row;
-----------------------------------------------------------------------------
--
-- Standard delete procedure
--
procedure delete_row(p_row_id varchar2) is
begin
   delete   from per_assignments_f a
   where a.rowid  = chartorowid(P_ROW_ID);
end delete_row;
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
   p_row_id          varchar2,
   p_assignment_id                    number,
   p_effective_start_date             date,
   p_effective_end_date               date,
   p_business_group_id                number,
   p_recruiter_id                     number,
   p_grade_id                         number,
   p_position_id                      number,
   p_job_id                           number,
   p_assignment_status_type_id        number,
   p_payroll_id                       number,
   p_location_id                      number,
   p_person_referred_by_id            number,
   p_supervisor_id                    number,
   p_special_ceiling_step_id          number,
   p_person_id                        number,
   p_recruitment_activity_id          number,
   p_source_organization_id           number,
   p_organization_id                  number,
   p_people_group_id                  number,
   p_soft_coding_keyflex_id           number,
   p_vacancy_id                       number,
   p_assignment_sequence              number,
   p_assignment_type                  varchar2,
   p_primary_flag                     varchar2,
   p_application_id                   number,
   p_assignment_number                varchar2,
   p_change_reason                    varchar2,
   p_comment_id                       number,
   p_date_probation_end               date,
   p_default_code_comb_id             number,
   p_frequency                        varchar2,
   p_internal_address_line            varchar2,
   p_manager_flag                     varchar2,
   p_normal_hours                     number,
   p_period_of_service_id             number,
   p_probation_period                 number,
   p_probation_unit                   varchar2,
   p_set_of_books_id                  number,
   p_source_type                      varchar2,
   p_time_normal_finish               varchar2,
   p_time_normal_start                varchar2,
   p_request_id                       number,
   p_program_application_id           number,
   p_program_id                       number,
   p_program_update_date              date,
   p_ass_attribute_category           varchar2,
   p_ass_attribute1                   varchar2,
   p_ass_attribute2                   varchar2,
   p_ass_attribute3                   varchar2,
   p_ass_attribute4                   varchar2,
   p_ass_attribute5                   varchar2,
   p_ass_attribute6                   varchar2,
   p_ass_attribute7                   varchar2,
   p_ass_attribute8                   varchar2,
   p_ass_attribute9                   varchar2,
   p_ass_attribute10                  varchar2,
   p_ass_attribute11                  varchar2,
   p_ass_attribute12                  varchar2,
   p_ass_attribute13                  varchar2,
   p_ass_attribute14                  varchar2,
   p_ass_attribute15                  varchar2,
   p_ass_attribute16                  varchar2,
   p_ass_attribute17                  varchar2,
   p_ass_attribute18                  varchar2,
   p_ass_attribute19                  varchar2,
   p_ass_attribute20                  varchar2,
   p_ass_attribute21                  varchar2,
   p_ass_attribute22                  varchar2,
   p_ass_attribute23                  varchar2,
   p_ass_attribute24                  varchar2,
   p_ass_attribute25                  varchar2,
   p_ass_attribute26                  varchar2,
   p_ass_attribute27                  varchar2,
   p_ass_attribute28                  varchar2,
   p_ass_attribute29                  varchar2,
   p_ass_attribute30                  varchar2,
   p_sal_review_period                number,
   p_sal_review_period_frequency      varchar2,
   p_perf_review_period               number,
   p_perf_review_period_frequency     varchar2,
   p_pay_basis_id                     number,
   p_employment_category         varchar2,
        p_bargaining_unit_code             varchar2,
        p_labour_union_member_flag         varchar2,
        p_hourly_salaried_code             varchar2,
   p_contract_id                      number,
   p_cagr_id_flex_num                 number,
   p_cagr_grade_def_id                number,
   p_establishment_id                 number,
   p_collective_agreement_id          number,
        p_notice_period          number,
        p_notice_period_uom         varchar2,
        p_employee_category         varchar2,
        p_work_at_home           varchar2,
        p_job_post_source_name         varchar2,
        p_placement_date_start             date,
        p_vendor_id                        number,
        p_vendor_employee_number           varchar2,
        p_vendor_assignment_number         varchar2,
        p_assignment_category              varchar2,
        p_title                            varchar2,
        p_project_title                    varchar2,
        p_grade_ladder_pgm_id              number,
        p_supervisor_assignment_id         number,
        p_vendor_site_id                   number,
        p_po_header_id                     number,
        p_po_line_id                       number,
        p_projected_assignment_end         date
) is
--
cursor ASS_CUR is
   select   *
   from  per_assignments_f a
   where a.rowid  = chartorowid(P_ROW_ID)
   FOR   UPDATE OF ASSIGNMENT_ID NOWAIT;
--
ass_rec  ASS_CUR%rowtype;
--
begin
--
   open ASS_CUR;
--
   fetch ASS_CUR into ASS_REC;
--
   if ASS_CUR%notfound then
      close  ASS_CUR;
                fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
                fnd_message.set_token('PROCEDURE',
                        'PER_ASSIGNMENTS_F_PKG.LOCK_ROW');
                fnd_message.set_token('STEP', '1');
                fnd_message.raise_error;
   end if;
   close ASS_CUR;
--
ass_rec.assignment_type := rtrim(ass_rec.assignment_type);
ass_rec.primary_flag := rtrim(ass_rec.primary_flag);
ass_rec.assignment_number := rtrim(ass_rec.assignment_number);
ass_rec.change_reason := rtrim(ass_rec.change_reason);
ass_rec.employment_category := rtrim(ass_rec.employment_category);
ass_rec.frequency := rtrim(ass_rec.frequency);
ass_rec.internal_address_line := rtrim(ass_rec.internal_address_line);
ass_rec.manager_flag := rtrim(ass_rec.manager_flag);
ass_rec.perf_review_period_frequency :=
   rtrim(ass_rec.perf_review_period_frequency);
ass_rec.probation_unit := rtrim(ass_rec.probation_unit);
ass_rec.sal_review_period_frequency :=
   rtrim(ass_rec.sal_review_period_frequency);
ass_rec.source_type := rtrim(ass_rec.source_type);
ass_rec.time_normal_finish := rtrim(ass_rec.time_normal_finish);
ass_rec.time_normal_start := rtrim(ass_rec.time_normal_start);
ass_rec.ass_attribute_category := rtrim(ass_rec.ass_attribute_category);
ass_rec.ass_attribute1 := rtrim(ass_rec.ass_attribute1);
ass_rec.ass_attribute2 := rtrim(ass_rec.ass_attribute2);
ass_rec.ass_attribute3 := rtrim(ass_rec.ass_attribute3);
ass_rec.ass_attribute4 := rtrim(ass_rec.ass_attribute4);
ass_rec.ass_attribute5 := rtrim(ass_rec.ass_attribute5);
ass_rec.ass_attribute6 := rtrim(ass_rec.ass_attribute6);
ass_rec.ass_attribute7 := rtrim(ass_rec.ass_attribute7);
ass_rec.ass_attribute8 := rtrim(ass_rec.ass_attribute8);
ass_rec.ass_attribute9 := rtrim(ass_rec.ass_attribute9);
ass_rec.ass_attribute10 := rtrim(ass_rec.ass_attribute10);
ass_rec.ass_attribute11 := rtrim(ass_rec.ass_attribute11);
ass_rec.ass_attribute12 := rtrim(ass_rec.ass_attribute12);
ass_rec.ass_attribute13 := rtrim(ass_rec.ass_attribute13);
ass_rec.ass_attribute14 := rtrim(ass_rec.ass_attribute14);
ass_rec.ass_attribute15 := rtrim(ass_rec.ass_attribute15);
ass_rec.ass_attribute16 := rtrim(ass_rec.ass_attribute16);
ass_rec.ass_attribute17 := rtrim(ass_rec.ass_attribute17);
ass_rec.ass_attribute18 := rtrim(ass_rec.ass_attribute18);
ass_rec.ass_attribute19 := rtrim(ass_rec.ass_attribute19);
ass_rec.ass_attribute20 := rtrim(ass_rec.ass_attribute20);
ass_rec.ass_attribute21 := rtrim(ass_rec.ass_attribute21);
ass_rec.ass_attribute22 := rtrim(ass_rec.ass_attribute22);
ass_rec.ass_attribute23 := rtrim(ass_rec.ass_attribute23);
ass_rec.ass_attribute24 := rtrim(ass_rec.ass_attribute24);
ass_rec.ass_attribute25 := rtrim(ass_rec.ass_attribute25);
ass_rec.ass_attribute26 := rtrim(ass_rec.ass_attribute26);
ass_rec.ass_attribute27 := rtrim(ass_rec.ass_attribute27);
ass_rec.ass_attribute28 := rtrim(ass_rec.ass_attribute28);
ass_rec.ass_attribute29 := rtrim(ass_rec.ass_attribute29);
ass_rec.ass_attribute30 := rtrim(ass_rec.ass_attribute30);
ass_rec.bargaining_unit_code := rtrim(ass_rec.bargaining_unit_code);
ass_rec.labour_union_member_flag := rtrim(ass_rec.labour_union_member_flag);
ass_rec.hourly_salaried_code:= rtrim(ass_rec.hourly_salaried_code);
ass_rec.contract_id     := rtrim(ass_rec.contract_id);
ass_rec.cagr_id_flex_num  := rtrim(ass_rec.cagr_id_flex_num);
ass_rec.cagr_grade_def_id := rtrim(ass_rec.cagr_grade_def_id);
ass_rec.establishment_id  := rtrim(ass_rec.establishment_id);
ass_rec.collective_agreement_id := rtrim(ass_rec.collective_agreement_id);
ass_rec.notice_period := rtrim(ass_rec.notice_period);
ass_rec.notice_period_uom := rtrim(ass_rec.notice_period_uom);
ass_rec.employee_category := rtrim(ass_rec.employee_category);
ass_rec.work_at_home := rtrim(ass_rec.work_at_home);
ass_rec.job_post_source_name := rtrim(ass_rec.job_post_source_name);
ass_rec.period_of_placement_date_start := rtrim(ass_rec.period_of_placement_date_start);
ass_rec.vendor_employee_number := rtrim(ass_rec.vendor_employee_number);
ass_rec.vendor_assignment_number := rtrim(ass_rec.vendor_assignment_number);
ass_rec.assignment_category := rtrim(ass_rec.assignment_category);
ass_rec.title := rtrim(ass_rec.title);
ass_rec.project_title := rtrim(ass_rec.project_title);

--
if ( ((ass_rec.assignment_id = p_assignment_id)
or (ass_rec.assignment_id is null
 and (p_assignment_id is null)))
and ((ass_rec.notice_period = p_notice_period)
or (ass_rec.notice_period is null
 and (p_notice_period is null)))
and ((ass_rec.notice_period_uom = p_notice_period_uom)
or (ass_rec.notice_period_uom is null
 and (p_notice_period_uom is null)))
and ((ass_rec.work_at_home = p_work_at_home)
or (ass_rec.work_at_home is null
 and (p_work_at_home is null)))
and ((ass_rec.employee_category = p_employee_category)
or (ass_rec.employee_category is null
 and (p_employee_category is null)))
and ((ass_rec.job_post_source_name = p_job_post_source_name)
or (ass_rec.job_post_source_name is null
 and (p_job_post_source_name is null)))
and ((ass_rec.contract_id = p_contract_id)
or (ass_rec.contract_id is null
 and (p_contract_id is null)))
and ((ass_rec.collective_agreement_id = p_collective_agreement_id)
or (ass_rec.collective_agreement_id is null
 and (p_collective_agreement_id is null)))
and ((ass_rec.establishment_id = p_establishment_id)
or (ass_rec.establishment_id is null
 and (p_establishment_id is null)))
and ((ass_rec.cagr_grade_def_id = p_cagr_grade_def_id)
or (ass_rec.cagr_grade_def_id is null
 and (p_cagr_grade_def_id is null)))
and ((ass_rec.cagr_id_flex_num = p_cagr_id_flex_num)
or (ass_rec.cagr_id_flex_num is null
 and (p_cagr_id_flex_num is null)))
and ((ass_rec.effective_start_date = p_effective_start_date)
or (ass_rec.effective_start_date is null
 and (p_effective_start_date is null)))
and ((ass_rec.effective_end_date = p_effective_end_date)
or (ass_rec.effective_end_date is null
 and (p_effective_end_date is null)))
and ((ass_rec.business_group_id = p_business_group_id)
or (ass_rec.business_group_id is null
 and (p_business_group_id is null)))
and ((ass_rec.recruiter_id = p_recruiter_id)
or (ass_rec.recruiter_id is null
 and (p_recruiter_id is null)))
and ((ass_rec.grade_id = p_grade_id)
or (ass_rec.grade_id is null
 and (p_grade_id is null)))
and ((ass_rec.position_id = p_position_id)
or (ass_rec.position_id is null
 and (p_position_id is null)))
and ((ass_rec.job_id = p_job_id)
or (ass_rec.job_id is null
 and (p_job_id is null)))
and ((ass_rec.assignment_status_type_id = p_assignment_status_type_id)
or (ass_rec.assignment_status_type_id is null
 and (p_assignment_status_type_id is null)))
and ((ass_rec.payroll_id = p_payroll_id)
or (ass_rec.payroll_id is null
 and (p_payroll_id is null)))
and ((ass_rec.location_id = p_location_id)
or (ass_rec.location_id is null
 and (p_location_id is null)))
and ((ass_rec.person_referred_by_id = p_person_referred_by_id)
or (ass_rec.person_referred_by_id is null
 and (p_person_referred_by_id is null)))
and ((ass_rec.supervisor_id = p_supervisor_id)
or (ass_rec.supervisor_id is null
 and (p_supervisor_id is null)))
and ((ass_rec.special_ceiling_step_id = p_special_ceiling_step_id)
or (ass_rec.special_ceiling_step_id is null
 and (p_special_ceiling_step_id is null)))
and ((ass_rec.person_id = p_person_id)
or (ass_rec.person_id is null
 and (p_person_id is null)))
and ((ass_rec.recruitment_activity_id = p_recruitment_activity_id)
or (ass_rec.recruitment_activity_id is null
 and (p_recruitment_activity_id is null)))
and ((ass_rec.source_organization_id = p_source_organization_id)
or (ass_rec.source_organization_id is null
 and (p_source_organization_id is null)))
and ((ass_rec.organization_id = p_organization_id)
or (ass_rec.organization_id is null
 and (p_organization_id is null)))
and ((ass_rec.people_group_id = p_people_group_id)
or (ass_rec.people_group_id is null
 and (p_people_group_id is null)))
and ((ass_rec.soft_coding_keyflex_id = p_soft_coding_keyflex_id)
or (ass_rec.soft_coding_keyflex_id is null
 and (p_soft_coding_keyflex_id is null)))
and ((ass_rec.vacancy_id = p_vacancy_id)
or (ass_rec.vacancy_id is null
 and (p_vacancy_id is null)))
and ((ass_rec.assignment_sequence = p_assignment_sequence)
or (ass_rec.assignment_sequence is null
 and (p_assignment_sequence is null)))
and ((ass_rec.assignment_type = p_assignment_type)
or (ass_rec.assignment_type is null
 and (p_assignment_type is null)))
and ((ass_rec.primary_flag = p_primary_flag)
or (ass_rec.primary_flag is null
 and (p_primary_flag is null)))
and ((ass_rec.application_id = p_application_id)
or (ass_rec.application_id is null
 and (p_application_id is null)))
and ((ass_rec.assignment_number = p_assignment_number)
or (ass_rec.assignment_number is null
 and (p_assignment_number is null)))
and ((ass_rec.change_reason = p_change_reason)
or (ass_rec.change_reason is null
 and (p_change_reason is null)))
and ((ass_rec.comment_id = p_comment_id)
or (ass_rec.comment_id is null
 and (p_comment_id is null)))
and ((ass_rec.date_probation_end = p_date_probation_end)
or (ass_rec.date_probation_end is null
 and (p_date_probation_end is null)))
and ((ass_rec.default_code_comb_id = p_default_code_comb_id)
or (ass_rec.default_code_comb_id is null
 and (p_default_code_comb_id is null)))
and ((ass_rec.frequency = p_frequency)
or (ass_rec.frequency is null
 and (p_frequency is null)))
and ((ass_rec.internal_address_line = p_internal_address_line)
or (ass_rec.internal_address_line is null
 and (p_internal_address_line is null)))
and ((ass_rec.manager_flag = p_manager_flag)
or (ass_rec.manager_flag is null
 and (p_manager_flag is null)))
and ((ass_rec.normal_hours = p_normal_hours)
or (ass_rec.normal_hours is null
 and (p_normal_hours is null)))
and ((ass_rec.period_of_service_id = p_period_of_service_id)
or (ass_rec.period_of_service_id is null
 and (p_period_of_service_id is null)))
and ((ass_rec.probation_period = p_probation_period)
or (ass_rec.probation_period is null
 and (p_probation_period is null)))
and ((ass_rec.probation_unit = p_probation_unit)
or (ass_rec.probation_unit is null
 and (p_probation_unit is null)))
and ((ass_rec.set_of_books_id = p_set_of_books_id)
or (ass_rec.set_of_books_id is null
 and (p_set_of_books_id is null)))
and ((ass_rec.source_type = p_source_type)
or (ass_rec.source_type is null
 and (p_source_type is null)))
and ((ass_rec.time_normal_finish = p_time_normal_finish)
or (ass_rec.time_normal_finish is null
 and (p_time_normal_finish is null)))
and ((ass_rec.time_normal_start = p_time_normal_start)
or (ass_rec.time_normal_start is null
 and (p_time_normal_start is null)))
and ((ass_rec.request_id = p_request_id)
or (ass_rec.request_id is null
 and (p_request_id is null)))
and ((ass_rec.program_application_id = p_program_application_id)
or (ass_rec.program_application_id is null
 and (p_program_application_id is null)))
and ((ass_rec.program_id = p_program_id)
or (ass_rec.program_id is null
 and (p_program_id is null)))
and ((ass_rec.program_update_date = p_program_update_date)
or (ass_rec.program_update_date is null
 and (p_program_update_date is null)))
and ((ass_rec.sal_review_period = p_sal_review_period)
or (ass_rec.sal_review_period is null
 and (p_sal_review_period is null)))
and ((ass_rec.sal_review_period_frequency = p_sal_review_period_frequency)
or (ass_rec.sal_review_period_frequency is null
 and (p_sal_review_period_frequency is null)))
and ((ass_rec.perf_review_period = p_perf_review_period)
or (ass_rec.perf_review_period is null
 and (p_perf_review_period is null)))
and ((ass_rec.perf_review_period_frequency = p_perf_review_period_frequency)
or (ass_rec.perf_review_period_frequency is null
 and (p_perf_review_period_frequency is null)))
and ((ass_rec.pay_basis_id = p_pay_basis_id)
or (ass_rec.pay_basis_id is null
 and (p_pay_basis_id is null)))) then
if ( ((ass_rec.ass_attribute_category = p_ass_attribute_category)
   or (ass_rec.ass_attribute_category is null
    and (p_ass_attribute_category is null)))
   and ((ass_rec.ass_attribute1 = p_ass_attribute1)
   or (ass_rec.ass_attribute1 is null
    and (p_ass_attribute1 is null)))
   and ((ass_rec.ass_attribute2 = p_ass_attribute2)
   or (ass_rec.ass_attribute2 is null
    and (p_ass_attribute2 is null)))
   and ((ass_rec.ass_attribute3 = p_ass_attribute3)
   or (ass_rec.ass_attribute3 is null
    and (p_ass_attribute3 is null)))
   and ((ass_rec.ass_attribute4 = p_ass_attribute4)
   or (ass_rec.ass_attribute4 is null
    and (p_ass_attribute4 is null)))
   and ((ass_rec.ass_attribute5 = p_ass_attribute5)
   or (ass_rec.ass_attribute5 is null
    and (p_ass_attribute5 is null)))
   and ((ass_rec.ass_attribute6 = p_ass_attribute6)
   or (ass_rec.ass_attribute6 is null
    and (p_ass_attribute6 is null)))
   and ((ass_rec.ass_attribute7 = p_ass_attribute7)
   or (ass_rec.ass_attribute7 is null
    and (p_ass_attribute7 is null)))
   and ((ass_rec.ass_attribute8 = p_ass_attribute8)
   or (ass_rec.ass_attribute8 is null
    and (p_ass_attribute8 is null)))
   and ((ass_rec.ass_attribute9 = p_ass_attribute9)
   or (ass_rec.ass_attribute9 is null
    and (p_ass_attribute9 is null)))
   and ((ass_rec.ass_attribute10 = p_ass_attribute10)
   or (ass_rec.ass_attribute10 is null
    and (p_ass_attribute10 is null)))
   and ((ass_rec.ass_attribute11 = p_ass_attribute11)
   or (ass_rec.ass_attribute11 is null
    and (p_ass_attribute11 is null)))
   and ((ass_rec.ass_attribute12 = p_ass_attribute12)
   or (ass_rec.ass_attribute12 is null
    and (p_ass_attribute12 is null)))
   and ((ass_rec.ass_attribute13 = p_ass_attribute13)
   or (ass_rec.ass_attribute13 is null
    and (p_ass_attribute13 is null)))
   and ((ass_rec.ass_attribute14 = p_ass_attribute14)
   or (ass_rec.ass_attribute14 is null
    and (p_ass_attribute14 is null)))
   and ((ass_rec.ass_attribute15 = p_ass_attribute15)
   or (ass_rec.ass_attribute15 is null
    and (p_ass_attribute15 is null)))
   and ((ass_rec.ass_attribute16 = p_ass_attribute16)
   or (ass_rec.ass_attribute16 is null
    and (p_ass_attribute16 is null)))
   and ((ass_rec.ass_attribute17 = p_ass_attribute17)
   or (ass_rec.ass_attribute17 is null
    and (p_ass_attribute17 is null)))
   and ((ass_rec.ass_attribute18 = p_ass_attribute18)
   or (ass_rec.ass_attribute18 is null
    and (p_ass_attribute18 is null)))
   and ((ass_rec.ass_attribute19 = p_ass_attribute19)
   or (ass_rec.ass_attribute19 is null
    and (p_ass_attribute19 is null)))
   and ((ass_rec.ass_attribute20 = p_ass_attribute20)
   or (ass_rec.ass_attribute20 is null
    and (p_ass_attribute20 is null)))
   and ((ass_rec.ass_attribute21 = p_ass_attribute21)
   or (ass_rec.ass_attribute21 is null
    and (p_ass_attribute21 is null)))
   and ((ass_rec.ass_attribute22 = p_ass_attribute22)
   or (ass_rec.ass_attribute22 is null
    and (p_ass_attribute22 is null)))
   and ((ass_rec.ass_attribute23 = p_ass_attribute23)
   or (ass_rec.ass_attribute23 is null
    and (p_ass_attribute23 is null)))
   and ((ass_rec.ass_attribute24 = p_ass_attribute24)
   or (ass_rec.ass_attribute24 is null
    and (p_ass_attribute24 is null)))
   and ((ass_rec.ass_attribute25 = p_ass_attribute25)
   or (ass_rec.ass_attribute25 is null
    and (p_ass_attribute25 is null)))
   and ((ass_rec.ass_attribute26 = p_ass_attribute26)
   or (ass_rec.ass_attribute26 is null
    and (p_ass_attribute26 is null)))
   and ((ass_rec.ass_attribute27 = p_ass_attribute27)
   or (ass_rec.ass_attribute27 is null
    and (p_ass_attribute27 is null)))
   and ((ass_rec.ass_attribute28 = p_ass_attribute28)
   or (ass_rec.ass_attribute28 is null
    and (p_ass_attribute28 is null)))
   and ((ass_rec.ass_attribute29 = p_ass_attribute29)
   or (ass_rec.ass_attribute29 is null
    and (p_ass_attribute29 is null)))
   and ((ass_rec.ass_attribute30 = p_ass_attribute30)
   or (ass_rec.ass_attribute30 is null
    and (p_ass_attribute30 is null)))
   and ((ass_rec.employment_category = p_employment_category)
   or (ass_rec.employment_category is null
    and (p_employment_category is null)))
        and ((ass_rec.bargaining_unit_code = p_bargaining_unit_code)
        or (ass_rec.bargaining_unit_code is null
         and (p_bargaining_unit_code is null)))
        and ((ass_rec.labour_union_member_flag = p_labour_union_member_flag)
        or (ass_rec.labour_union_member_flag is null
         and (p_labour_union_member_flag is null)))
        and ((ass_rec.hourly_salaried_code = p_hourly_salaried_code)
        or (ass_rec.hourly_salaried_code is null
         and (p_hourly_salaried_code is null)))
        and ((ass_rec.vendor_id = p_vendor_id)
        or (ass_rec.vendor_id is null
         and (p_vendor_id is null)))
        and ((ass_rec.vendor_site_id = p_vendor_site_id)
        or (ass_rec.vendor_site_id is null
         and (p_vendor_site_id is null)))
        and ((ass_rec.po_header_id = p_po_header_id)
        or (ass_rec.po_header_id is null
         and (p_po_header_id is null)))
        and ((ass_rec.po_line_id = p_po_line_id)
        or (ass_rec.po_line_id is null
         and (p_po_line_id is null)))
        and ((ass_rec.projected_assignment_end = p_projected_assignment_end)
        or (ass_rec.projected_assignment_end is null
         and (p_projected_assignment_end is null)))
) then
      return;   -- Row successfully locked, no changes
   end if;
end if;
--
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
--
end lock_row;
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
/****************************/

procedure update_row(
   p_row_id          varchar2,
   p_assignment_id                    number,
   p_effective_start_date             date,
   p_effective_end_date               date,
   p_business_group_id                number,
   p_recruiter_id                     number,
   p_grade_id                         number,
   p_position_id                      number,
   p_job_id                           number,
   p_assignment_status_type_id        number,
   p_payroll_id                       number,
   p_location_id                      number,
   p_person_referred_by_id            number,
   p_supervisor_id                    number,
   p_special_ceiling_step_id          number,
   p_person_id                        number,
   p_recruitment_activity_id          number,
   p_source_organization_id           number,
   p_organization_id                  number,
   p_people_group_id                  number,
   p_soft_coding_keyflex_id           number,
   p_vacancy_id                       number,
   p_assignment_sequence              number,
   p_assignment_type                  varchar2,
   p_primary_flag                     varchar2,
   p_application_id                   number,
   p_assignment_number                varchar2,
   p_change_reason                    varchar2,
   p_comment_id                       number,
   p_date_probation_end               date,
   p_default_code_comb_id             number,
   p_frequency                        varchar2,
   p_internal_address_line            varchar2,
   p_manager_flag                     varchar2,
   p_normal_hours                     number,
   p_period_of_service_id             number,
   p_probation_period                 number,
   p_probation_unit                   varchar2,
   p_set_of_books_id                  number,
   p_source_type                      varchar2,
   p_time_normal_finish               varchar2,
   p_time_normal_start                varchar2,
   p_request_id                       number,
   p_program_application_id           number,
   p_program_id                       number,
   p_program_update_date              date,
   p_ass_attribute_category           varchar2,
   p_ass_attribute1                   varchar2,
   p_ass_attribute2                   varchar2,
   p_ass_attribute3                   varchar2,
   p_ass_attribute4                   varchar2,
   p_ass_attribute5                   varchar2,
   p_ass_attribute6                   varchar2,
   p_ass_attribute7                   varchar2,
   p_ass_attribute8                   varchar2,
   p_ass_attribute9                   varchar2,
   p_ass_attribute10                  varchar2,
   p_ass_attribute11                  varchar2,
   p_ass_attribute12                  varchar2,
   p_ass_attribute13                  varchar2,
   p_ass_attribute14                  varchar2,
   p_ass_attribute15                  varchar2,
   p_ass_attribute16                  varchar2,
   p_ass_attribute17                  varchar2,
   p_ass_attribute18                  varchar2,
   p_ass_attribute19                  varchar2,
   p_ass_attribute20                  varchar2,
   p_ass_attribute21                  varchar2,
   p_ass_attribute22                  varchar2,
   p_ass_attribute23                  varchar2,
   p_ass_attribute24                  varchar2,
   p_ass_attribute25                  varchar2,
   p_ass_attribute26                  varchar2,
   p_ass_attribute27                  varchar2,
   p_ass_attribute28                  varchar2,
   p_ass_attribute29                  varchar2,
   p_ass_attribute30                  varchar2,
   p_sal_review_period                number,
   p_sal_review_period_frequency      varchar2,
   p_perf_review_period               number,
   p_perf_review_period_frequency     varchar2,
   p_pay_basis_id                     number,
   p_employment_category         varchar2,
        p_dt_update_mode                   varchar2,
        p_session_date                     date,
        p_bargaining_unit_code             varchar2,
        p_labour_union_member_flag         varchar2,
        p_hourly_salaried_code             varchar2,
   p_contract_id                      number default null,
   p_cagr_id_flex_num                 number default null,
   p_cagr_grade_def_id                number default null,
   p_establishment_id                 number default null,
   p_collective_agreement_id          number default null,
        p_notice_period          number   default null,
        p_notice_period_uom         varchar2 default null,
        p_employee_category         varchar2 default null,
        p_work_at_home           varchar2 default null,
        p_job_post_source_name         varchar2 default null,
        p_placement_date_start             date     default null,
        p_vendor_id                        number   default null,
        p_vendor_employee_number           varchar2 default null,
        p_vendor_assignment_number         varchar2 default null,
        p_assignment_category              varchar2 default null,
        p_title                            varchar2 default null,
        p_project_title                    varchar2 default null,
        p_grade_ladder_pgm_id              number   default null,
        p_supervisor_assignment_id         number   default null,
        p_vendor_site_id                   number   default null,
        p_po_header_id                     number   default null,
        p_po_line_id                       number   default null,
        p_projected_assignment_end         date     default null
) is
        l_assignment_status_id number; --discards out params from irc_asg_st
        l_asg_status_ovn       number; --discards out params from irc_asg_st
        l_previous_asg_status  number;
        l_organization_id    number;
        l_legislation_code   varchar2(150);
        l_return_code        number;
        l_return_text        varchar2(240);
        l_location_id        number;
        l_loc_id             number;
        l_location_id_changed  number := 0;
        l_dt_update_mode      varchar2(240);
        l_percent_time        number;
        dummy                date;
--
l_proc            varchar2(10) :=  'insert_row';
--

--
/*
      --WWBUG 2130950 Begin hrwf synchronization --tpapired
   l_asg_rec                per_all_assignments_f%rowtype;
        cursor l_asg_cur is
        select *
   from per_all_assignments_f
   where assignment_id           = P_ASSIGNMENT_ID
   and     effective_start_date    = P_EFFECTIVE_START_DATE
        and     effective_end_date          = P_EFFECTIVE_END_DATE;
      --WWBUG 2130950 End hrwf synchronization -tpapired
*/
      --
        -- DK 99/05/03
        -- Bug 883263 (rdbms 883275)
        -- The workaround gives a simpler and more efficient query
        -- Replace the form's view (per_assignments_v) with the secure view.
        --

        cursor  perav1(c_row_id  rowid) is
          select pav.organization_id,
                 pbg.legislation_code,
                 pav.location_id
          from   per_assignments_f   pav,
                 per_business_groups pbg
          where  c_row_id              = pav.rowid
            and  pav.business_group_id = pbg.business_group_id;
--

  cursor csr_chk_loc_change is
  select paf.location_id
  from   PER_ASSIGNMENTS_F paf
  where  paf.assignment_id = p_assignment_id
  and    p_session_date between paf.effective_start_date
        and paf.effective_end_date;

/* Need to check that US payroll is installed */
/*
CURSOR get_install_info IS
SELECT status
FROM fnd_product_installations
WHERE application_id = 801
AND   p_primary_flag = 'Y';
*/

  cursor c_pay_proposals is
  select min(change_date)
  from per_pay_proposals
  where assignment_id = p_assignment_id;

/* Cursor csr_get_assign added for bug#8232830 */

cursor csr_get_assign(csr_person_id number) is
select assignment_id
from per_all_assignments_f
where person_id=csr_person_id
and business_group_id=p_business_group_id
and trunc(sysdate) between effective_start_date and effective_end_date
and assignment_type not in ('B','O');

/*End of Cursor csr_get_assign added for bug#8232830 */

   --start code for bug 6961562
	l_installed          boolean;
	l_po_installed      VARCHAR2(1);
	l_industry           VARCHAR2(1);
	l_vendor_id      number default null;
	l_vendor_site_id      number default null;

	cursor po_cwk is
	select vendor_id,vendor_site_id from
	per_all_assignments_f paf
	 where paf.assignment_id = p_assignment_id
	 and nvl(p_session_date,sysdate) between paf.effective_start_date
	and paf.effective_end_date;
--end code for bug 6961562


--
--
l_status            VARCHAR2(50);
l_change_date       DATE;
/* variable added for bug#8232830 */
l_assignment_id          per_all_assignments_f.assignment_id%TYPE;
--

--- Fix For Bug # 8860141 Starts ---
    cursor csr_defaulting_date(p_assignment_id number) is
        select 	min(effective_start_date)
          from 	pay_us_emp_fed_tax_rules_f
         where 	assignment_id = p_assignment_id;

    cursor csr_defaultpayrollremoved(p_assignment_id number,
                                      p_effective_date date) is
        select null
          from per_all_assignments_f paa,
               pay_element_entries_f pee,
               pay_element_links_f pel,
               pay_element_types_f pet
         where paa.assignment_id=p_assignment_id
           and paa.payroll_id is null
           and p_effective_date between paa.effective_start_date
	                       and paa.effective_end_date
           and pee.assignment_id=paa.assignment_id
           and p_effective_date between pee.effective_start_date
	                       and pee.effective_end_date
           and pee.element_link_id=pel.element_link_id
           and pel.link_to_all_payrolls_flag = 'Y'
           and p_effective_date between pel.effective_start_date
	                       and pel.effective_end_date
           and pel.element_type_id=pet.element_type_id
           and pet.element_name in ('VERTEX','Workers Compensation');

        l_default_date      DATE;
        l_temp_char         VARCHAR2(10);
--- Fix For Bug # 8860141 Ends ---

begin
--
-- #294004 If the organization_id has been changed away from the default
--business_group, an update to ins_per_list should be invoked, after the update
--to per_assignments_f. This is because all secure users will be able to see
--the person when assigned to the default business group and we want to
--restrict access immediately the organization is entered, rather than waiting
--for the next run of listgen.
--
     hr_utility.set_location('per_assignments_f_pkg.update_row',1);
     open csr_chk_loc_change;
     fetch csr_chk_loc_change into l_loc_id;

    if csr_chk_loc_change%NOTFOUND then
             close csr_chk_loc_change;
             fnd_message.set_name(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             fnd_message.set_token('PROCEDURE',
                            'per_assignments_f_pkg.update_row');
             fnd_message.set_token('STEP','1');
             fnd_message.raise_error;
    else
       if l_loc_id <> p_location_id then
         l_location_id_changed := 1;
         close csr_chk_loc_change;
       end if;
    end if;

/**

-- Bug 2365872
-- If records exists in per_pay_proposals for the assignment
-- then salary basis cannot be nulled.
--
  if p_pay_basis_id is null then
    open c_pay_proposals;

    hr_utility.set_location('per_assignments_f_pkg.update_row',10);
    fetch c_pay_proposals into l_change_date;
      if c_pay_proposals%FOUND then
           if l_change_date < p_session_date then
           fnd_message.set_name('PER','HR_289767_SALARY_BASIS_IS_NULL');
           fnd_message.raise_error;
           end if;
       hr_utility.set_location('per_assignments_f_pkg.update_row',20);
      end if;
    hr_utility.set_location('per_assignments_f_pkg.update_row',30);
  end if;

-- End Bug 2365872
**/

/************************************/
    hr_utility.set_location(g_package || l_proc, 20);

   open perav1(chartorowid(p_row_id));
   fetch perav1 into l_organization_id, l_legislation_code,
                     l_location_id;
   if perav1%notfound then
        close perav1;
   fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
   fnd_message.set_token('PROCEDURE',
      'PER_ASSIGNMENTS_F1_PKG.UPDATE_ROW');
   fnd_message.set_token('STEP', '1');
   fnd_message.raise_error;
   end if;
   close perav1;

    -- start code for bug 6961562
	 -- PO
	l_installed := fnd_installation.get(appl_id => 210
		,dep_appl_id => 210
          ,status => l_po_installed
          ,industry => l_industry);

	if l_po_installed <> 'N' then
	open po_cwk;
	fetch po_cwk into l_vendor_id,l_vendor_site_id;
	if po_cwk%found then
	if (l_vendor_id <> p_vendor_id)
	or (l_vendor_site_id <> p_vendor_site_id) then
	PO_HR_INTERFACE_PVT.is_Supplier_Updatable( p_assignment_id => p_assignment_id,
                                               p_effective_date => p_session_date );
		end if;
	end if;
	close po_cwk;
	end if;
  -- end code for bug 6961562

   --
   -- changed p_rowid => null to p_rowid => p_row_id
   --
    hr_utility.set_location(g_package || l_proc, 30);

    ben_dt_trgr_handle.assignment
            (p_rowid                   => p_row_id
            ,p_assignment_id           => p_assignment_id
            ,p_business_group_id       => p_business_group_id
       ,p_person_id               => p_person_id
       ,p_effective_start_date    => p_effective_start_date
       ,p_effective_end_date      => p_effective_end_date
       ,p_assignment_status_type_id  => p_assignment_status_type_id
       ,p_assignment_type         => p_assignment_type
       ,p_organization_id         => p_organization_id
       ,p_primary_flag            => p_primary_flag
       ,p_change_reason           => p_change_reason
       ,p_employment_category     => p_employment_category
       ,p_frequency               => p_frequency
       ,p_grade_id                => p_grade_id
       ,p_job_id                  => p_job_id
       ,p_position_id             => p_position_id
       ,p_location_id             => p_location_id
       ,p_normal_hours            => p_normal_hours
       ,p_payroll_id              => p_payroll_id
       ,p_pay_basis_id            => p_pay_basis_id
       ,p_bargaining_unit_code    => p_bargaining_unit_code
       ,p_labour_union_member_flag => p_labour_union_member_flag
            ,p_hourly_salaried_code    => p_hourly_salaried_code
            ,p_people_group_id    => p_people_group_id
       ,p_ass_attribute1 => p_ass_attribute1
       ,p_ass_attribute2 => p_ass_attribute2
       ,p_ass_attribute3 => p_ass_attribute3
       ,p_ass_attribute4 => p_ass_attribute4
       ,p_ass_attribute5 => p_ass_attribute5
       ,p_ass_attribute6 => p_ass_attribute6
       ,p_ass_attribute7 => p_ass_attribute7
       ,p_ass_attribute8 => p_ass_attribute8
       ,p_ass_attribute9 => p_ass_attribute9
       ,p_ass_attribute10 => p_ass_attribute10
       ,p_ass_attribute11 => p_ass_attribute11
       ,p_ass_attribute12 => p_ass_attribute12
       ,p_ass_attribute13 => p_ass_attribute13
       ,p_ass_attribute14 => p_ass_attribute14
       ,p_ass_attribute15 => p_ass_attribute15
       ,p_ass_attribute16 => p_ass_attribute16
       ,p_ass_attribute17 => p_ass_attribute17
       ,p_ass_attribute18 => p_ass_attribute18
       ,p_ass_attribute19 => p_ass_attribute19
       ,p_ass_attribute20 => p_ass_attribute20
       ,p_ass_attribute21 => p_ass_attribute21
       ,p_ass_attribute22 => p_ass_attribute22
       ,p_ass_attribute23 => p_ass_attribute23
       ,p_ass_attribute24 => p_ass_attribute24
       ,p_ass_attribute25 => p_ass_attribute25
       ,p_ass_attribute26 => p_ass_attribute26
       ,p_ass_attribute27 => p_ass_attribute27
       ,p_ass_attribute28 => p_ass_attribute28
       ,p_ass_attribute29 => p_ass_attribute29
       ,p_ass_attribute30 => p_ass_attribute30
            );
--
    hr_utility.set_location(g_package || l_proc, 40);
-- Retrieve Previous assignment_status_id
  select assignment_status_type_id into l_previous_asg_status
   from  per_assignments_f
   where rowid = chartorowid(P_ROW_ID);

    hr_utility.set_location(g_package || l_proc, 45);

  if l_previous_asg_status <> p_assignment_status_type_id
  and p_assignment_type = 'A' then
   IRC_ASG_STATUS_API.create_irc_asg_status
    (p_assignment_id                => p_assignment_id
     , p_assignment_status_type_id  => p_assignment_status_type_id
     , p_status_change_date         => p_effective_start_date
     , p_status_change_reason       => p_change_reason   -- Bug 2676934
     , p_assignment_status_id       => l_assignment_status_id
     , p_object_version_number      => l_asg_status_ovn);
  end if;

    hr_utility.set_location(g_package || l_proc, 50);
   update per_assignments_f a
   set   a.assignment_id = P_ASSIGNMENT_ID,
   a.effective_start_date = P_EFFECTIVE_START_DATE,
   a.effective_end_date = P_EFFECTIVE_END_DATE,
   a.business_group_id = P_BUSINESS_GROUP_ID,
   a.recruiter_id = P_RECRUITER_ID,
   a.grade_id = P_GRADE_ID,
   a.position_id = P_POSITION_ID,
   a.job_id = P_JOB_ID,
   a.assignment_status_type_id = P_ASSIGNMENT_STATUS_TYPE_ID,
   a.payroll_id = P_PAYROLL_ID,
   a.location_id = P_LOCATION_ID,
   a.person_referred_by_id = P_PERSON_REFERRED_BY_ID,
   a.supervisor_id = P_SUPERVISOR_ID,
   a.special_ceiling_step_id = P_SPECIAL_CEILING_STEP_ID,
   a.person_id = P_PERSON_ID,
   a.recruitment_activity_id = P_RECRUITMENT_ACTIVITY_ID,
   a.source_organization_id = P_SOURCE_ORGANIZATION_ID,
   a.organization_id = P_ORGANIZATION_ID,
   a.people_group_id = P_PEOPLE_GROUP_ID,
   a.soft_coding_keyflex_id = P_SOFT_CODING_KEYFLEX_ID,
   a.vacancy_id = P_VACANCY_ID,
   a.assignment_sequence = P_ASSIGNMENT_SEQUENCE,
   a.assignment_type = P_ASSIGNMENT_TYPE,
   a.primary_flag = P_PRIMARY_FLAG,
   a.application_id = P_APPLICATION_ID,
   a.assignment_number = P_ASSIGNMENT_NUMBER,
   a.change_reason = P_CHANGE_REASON,
   a.comment_id = P_COMMENT_ID,
   a.date_probation_end = P_DATE_PROBATION_END,
   a.default_code_comb_id = P_DEFAULT_CODE_COMB_ID,
   a.frequency = P_FREQUENCY,
   a.internal_address_line = P_INTERNAL_ADDRESS_LINE,
   a.manager_flag = P_MANAGER_FLAG,
   a.normal_hours = P_NORMAL_HOURS,
   a.period_of_service_id = P_PERIOD_OF_SERVICE_ID,
   a.probation_period = P_PROBATION_PERIOD,
   a.probation_unit = P_PROBATION_UNIT,
   a.set_of_books_id = P_SET_OF_BOOKS_ID,
   a.source_type = P_SOURCE_TYPE,
   a.time_normal_finish = P_TIME_NORMAL_FINISH,
   a.time_normal_start = P_TIME_NORMAL_START,
   a.request_id = P_REQUEST_ID,
   a.program_application_id = P_PROGRAM_APPLICATION_ID,
   a.program_id = P_PROGRAM_ID,
   a.program_update_date = P_PROGRAM_UPDATE_DATE,
   a.ass_attribute_category = P_ASS_ATTRIBUTE_CATEGORY,
   a.ass_attribute1 = P_ASS_ATTRIBUTE1,
   a.ass_attribute2 = P_ASS_ATTRIBUTE2,
   a.ass_attribute3 = P_ASS_ATTRIBUTE3,
   a.ass_attribute4 = P_ASS_ATTRIBUTE4,
   a.ass_attribute5 = P_ASS_ATTRIBUTE5,
   a.ass_attribute6 = P_ASS_ATTRIBUTE6,
   a.ass_attribute7 = P_ASS_ATTRIBUTE7,
   a.ass_attribute8 = P_ASS_ATTRIBUTE8,
   a.ass_attribute9 = P_ASS_ATTRIBUTE9,
   a.ass_attribute10 = P_ASS_ATTRIBUTE10,
   a.ass_attribute11 = P_ASS_ATTRIBUTE11,
   a.ass_attribute12 = P_ASS_ATTRIBUTE12,
   a.ass_attribute13 = P_ASS_ATTRIBUTE13,
   a.ass_attribute14 = P_ASS_ATTRIBUTE14,
   a.ass_attribute15 = P_ASS_ATTRIBUTE15,
   a.ass_attribute16 = P_ASS_ATTRIBUTE16,
   a.ass_attribute17 = P_ASS_ATTRIBUTE17,
   a.ass_attribute18 = P_ASS_ATTRIBUTE18,
   a.ass_attribute19 = P_ASS_ATTRIBUTE19,
   a.ass_attribute20 = P_ASS_ATTRIBUTE20,
   a.ass_attribute21 = P_ASS_ATTRIBUTE21,
   a.ass_attribute22 = P_ASS_ATTRIBUTE22,
   a.ass_attribute23 = P_ASS_ATTRIBUTE23,
   a.ass_attribute24 = P_ASS_ATTRIBUTE24,
   a.ass_attribute25 = P_ASS_ATTRIBUTE25,
   a.ass_attribute26 = P_ASS_ATTRIBUTE26,
   a.ass_attribute27 = P_ASS_ATTRIBUTE27,
   a.ass_attribute28 = P_ASS_ATTRIBUTE28,
   a.ass_attribute29 = P_ASS_ATTRIBUTE29,
   a.ass_attribute30 = P_ASS_ATTRIBUTE30,
   a.sal_review_period = P_SAL_REVIEW_PERIOD,
   a.sal_review_period_frequency = P_SAL_REVIEW_PERIOD_FREQUENCY,
   a.perf_review_period = P_PERF_REVIEW_PERIOD,
   a.perf_review_period_frequency = P_PERF_REVIEW_PERIOD_FREQUENCY,
   a.pay_basis_id = P_PAY_BASIS_ID,
   a.employment_category = P_EMPLOYMENT_CATEGORY,
        a.bargaining_unit_code = P_BARGAINING_UNIT_CODE,
        a.labour_union_member_flag = P_LABOUR_UNION_MEMBER_FLAG,
        a.hourly_salaried_code = P_HOURLY_SALARIED_CODE,
   a.collective_agreement_id = P_COLLECTIVE_AGREEMENT_ID,
   a.cagr_grade_def_id       = P_CAGR_GRADE_DEF_ID,
   a.establishment_id        = P_ESTABLISHMENT_ID,
   a.contract_id             = P_CONTRACT_ID,
   a.cagr_id_flex_num        = P_CAGR_ID_FLEX_NUM,
        a.notice_period      = P_NOTICE_PERIOD,
        a.notice_period_uom       = P_NOTICE_PERIOD_UOM,
        a.work_at_home       = P_WORK_AT_HOME,
        a.employee_category     = P_EMPLOYEE_CATEGORY,
        a.job_post_source_name    = P_JOB_POST_SOURCE_NAME,
        a.period_of_placement_date_start = p_placement_date_start,
        a.vendor_id               = p_vendor_id,
        a.vendor_employee_number  = p_vendor_employee_number,
        a.vendor_assignment_number = p_vendor_assignment_number,
        a.assignment_category     = p_assignment_category,
        a.title                   = p_title,
        a.project_title           = p_project_title,
        a.grade_ladder_pgm_id     = p_grade_ladder_pgm_id,
        a.supervisor_assignment_id = p_supervisor_assignment_id,
        a.vendor_site_id           = p_vendor_site_id,
        a.po_header_id             = p_po_header_id,
        a.po_line_id               = p_po_line_id,
        a.projected_assignment_end = p_projected_assignment_end
 where a.rowid = chartorowid(P_ROW_ID);
--
-- Start of fix 3815024
    hr_utility.set_location(g_package || l_proc, 60);

/*if l_organization_id = p_business_group_id and
   p_organization_id <> p_business_group_id then*/ -- Commented for bug 6167879
   --
   hr_security_internal.clear_from_person_list(
                        p_person_id => p_person_id);
   --
/*end if;*/ -- Commented for 6167879
--
    hr_utility.set_location(g_package || l_proc, 70);

-- Start of fix 8232830
     open csr_get_assign(p_person_id);
     loop
     fetch csr_get_assign into l_assignment_id;
     exit when csr_get_assign%NOTFOUND;
     hr_security_internal.add_to_person_list(
                     p_effective_date => p_effective_start_date,
                     p_assignment_id  => l_assignment_id);
    end loop;
 -- End of fix 8232830
-- End of fix 3815024
--
/*  OPEN  get_install_info;
FETCH get_install_info INTO l_status;
CLOSE get_install_info; */

/* Added call to maintain the denormalized table, For 420029 lwthomps */
/* Added call to create tax records, 268389 lwthomps */
/* Taken out nocopy comment from if legislation_code = 'US', Bug: 1196833 */
 IF   l_legislation_code = 'US' then
--   AND l_status = 'I'
--   AND p_assignment_type = 'E' THEN

   IF p_assignment_type = 'E' THEN
--

--- Fix For Bug # 8860141 Starts ---
   OPEN csr_defaulting_date(p_assignment_id);
   FETCH csr_defaulting_date INTO l_default_date;
    IF csr_defaulting_date%FOUND THEN

    OPEN csr_defaultpayrollremoved(p_assignment_id,p_effective_start_date);
    FETCH csr_defaultpayrollremoved INTO l_temp_char;

    IF csr_defaultpayrollremoved%FOUND then
      close csr_defaulting_date;
      close csr_defaultpayrollremoved;
      hr_utility.set_message(801,'PAY_75264_US_PAYROLL_REMOVAL');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_defaultpayrollremoved;

   END IF;
   CLOSE csr_defaulting_date;
--- Fix For Bug # 8860141 Ends ---

     IF p_payroll_id IS NOT NULL AND p_pay_basis_id IS NOT NULL THEN
--
--
       if  l_location_id_changed <> 1 then
        l_location_id := NULL;
        l_dt_update_mode := NULL;
       else
        l_location_id := p_location_id;
        l_dt_update_mode := p_dt_update_mode;
       end if;

    hr_utility.set_location(g_package || l_proc, 80);

       pay_us_emp_dt_tax_rules.default_tax_with_validation(
                              p_assignment_id        => p_assignment_id,
                              p_person_id            => p_person_id,
                              p_effective_start_date => p_effective_start_date,
                              p_effective_end_date => p_effective_end_date,
                              p_session_date         => p_session_date,
                              p_business_group_id    => p_business_group_id,
                              p_from_form            => 'Assignment',
                              p_mode                 => l_dt_update_mode,
                              p_location_id          => l_location_id,
                              p_return_code          => l_return_code,
                              p_return_text          => l_return_text);
  END IF;
--
  pay_asg_geo_pkg.pay_us_asg_rpt( p_assignment_id );
--
END IF;
END IF; /* End of legislation code check */
/*
  --WWBUG 2130950 Begin hrwf synchronization --tpapired
    open l_asg_cur;
   fetch l_asg_cur into l_asg_rec;
   close l_asg_cur;
   per_hrwf_synch.PER_ASG_WF(
                  p_rec    => l_asg_rec,
               p_action => 'UPDATE');
  --WWBUG 2130950 End hrwf synchronization --tpapired
*/
--
end update_row;
/****************************/
--
procedure dml_promotion(
        p_assignment_id   number,
        p_promotion_date  date,
        p_prom_flag       char) is
--
  cursor c_promotion_exists is
    select assignment_extra_info_id, object_version_number
    from per_assignment_extra_info
     where  assignment_id = p_assignment_id
     and    information_type = 'PROMOTION'
     and    fnd_date.canonical_to_date(aei_information1) = p_promotion_date;
--
  l_promotion_rec c_promotion_exists%rowtype;
  l_assignment_extra_info_id number;
  l_object_version_number    number;
--
l_proc            varchar2(13) :=  'dml_promotion';
--
begin
--  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  open c_promotion_exists;
  fetch c_promotion_exists into l_promotion_rec;
  if p_prom_flag = 'Y' then
     if c_promotion_exists%notfound then
       hr_assignment_extra_info_api.create_assignment_extra_info(
        p_assignment_id            =>  p_assignment_id
       ,p_information_type         => 'PROMOTION'
       ,p_aei_information_category => 'PROMOTION' -- #1965910
       ,p_aei_information1         => p_promotion_date
       ,p_assignment_extra_info_id => l_assignment_extra_info_id
       ,p_object_version_number    => l_object_version_number
                                                                 );
     end if;
  else
     if c_promotion_exists%found then
       hr_assignment_extra_info_api.delete_assignment_extra_info(
          p_assignment_extra_info_id => l_promotion_rec.assignment_extra_info_id
         ,p_object_version_number    => l_promotion_rec.object_version_number
                                                                );
     end if;
  end if;
--
  close c_promotion_exists;
--
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
--
end dml_promotion;
-----------------------------------------------------------------------------
--
-- ****  End of standard ON-* checks.  ****
--
-----------------------------------------------------------------------------
--
END PER_ASSIGNMENTS_F_PKG;

/
