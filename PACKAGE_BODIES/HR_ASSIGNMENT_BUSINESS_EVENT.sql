--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BUSINESS_EVENT" as
/* $Header: peasgbev.pkb 120.0 2005/10/31 04:39:56 bshukla noship $ */

procedure assignment_business_event(
p_event                      in  varchar2,
p_assignment_type            in  varchar2,
p_primary_flag               in  varchar2,
p_effective_date             in  date,
p_datetrack_update_mode      in  varchar2 default hr_api.g_update,
p_assignment_id              in  number,
p_object_version_number      in  number ,
p_grade_id                   in  number default hr_api.g_number,
p_position_id                in  number default hr_api.g_number,
p_job_id                     in  number default hr_api.g_number,
p_payroll_id                 in  number default hr_api.g_number,
p_location_id                in  number default hr_api.g_number,
p_special_ceiling_step_id    in  number default hr_api.g_number,
p_organization_id            in  number default hr_api.g_number,
p_pay_basis_id               in  number default hr_api.g_number,
p_segment1                   in  varchar2 default hr_api.g_varchar2,
p_segment2                   in  varchar2 default hr_api.g_varchar2,
p_segment3                   in  varchar2 default hr_api.g_varchar2,
p_segment4                   in  varchar2 default hr_api.g_varchar2,
p_segment5                   in  varchar2 default hr_api.g_varchar2,
p_segment6                   in  varchar2 default hr_api.g_varchar2,
p_segment7                   in  varchar2 default hr_api.g_varchar2,
p_segment8                   in  varchar2 default hr_api.g_varchar2,
p_segment9                   in  varchar2 default hr_api.g_varchar2,
p_segment10                  in  varchar2 default hr_api.g_varchar2,
p_segment11                  in  varchar2 default hr_api.g_varchar2,
p_segment12                  in  varchar2 default hr_api.g_varchar2,
p_segment13                  in  varchar2 default hr_api.g_varchar2,
p_segment14                  in  varchar2 default hr_api.g_varchar2,
p_segment15                  in  varchar2 default hr_api.g_varchar2,
p_segment16                  in  varchar2 default hr_api.g_varchar2,
p_segment17                  in  varchar2 default hr_api.g_varchar2,
p_segment18                  in  varchar2 default hr_api.g_varchar2,
p_segment19                  in  varchar2 default hr_api.g_varchar2,
p_segment20                  in  varchar2 default hr_api.g_varchar2,
p_segment21                  in  varchar2 default hr_api.g_varchar2,
p_segment22                  in  varchar2 default hr_api.g_varchar2,
p_segment23                  in  varchar2 default hr_api.g_varchar2,
p_segment24                  in  varchar2 default hr_api.g_varchar2,
p_segment25                  in  varchar2 default hr_api.g_varchar2,
p_segment26                  in  varchar2 default hr_api.g_varchar2,
p_segment27                  in  varchar2 default hr_api.g_varchar2,
p_segment28                  in  varchar2 default hr_api.g_varchar2,
p_segment29                  in  varchar2 default hr_api.g_varchar2,
p_segment30                  in  varchar2 default hr_api.g_varchar2,
p_people_group_name          in  varchar2 default hr_api.g_varchar2,
p_group_name                 in  varchar2 default hr_api.g_varchar2,
p_employment_category        in  varchar2 default hr_api.g_varchar2,
p_effective_start_date       in  date default hr_api.g_date,
p_effective_end_date         in  date default hr_api.g_date,
p_people_group_id            in  number default hr_api.g_number,
p_org_now_no_manager_warning in  boolean default false,
p_other_manager_warning      in  boolean default false,
p_spp_delete_warning         in  boolean default false,
p_entries_changed_warning    in  varchar2 default hr_api.g_varchar2,
p_tax_district_changed_warning in boolean default false,
p_concat_segments            in varchar2 default hr_api.g_varchar2,
p_contract_id                in number default hr_api.g_number,
p_establishment_id           in number default hr_api.g_number,
p_concatenated_segments      in varchar2 default hr_api.g_varchar2,
p_soft_coding_keyflex_id     in number default hr_api.g_number,
p_scl_segment1               in varchar2 default hr_api.g_varchar2)
is

l_proc varchar2(72) := 'raise_assignment_business_event';

begin
hr_utility.set_location('Entering: raise_assignment_business_event'|| l_proc, 10);
if p_event = 'UPDATE' then
hr_utility.set_location('Entering: UPDATE'|| l_proc, 20);
   if p_assignment_type = 'E' and p_primary_flag = 'Y' then
	hr_assignment_be3.update_emp_asg_criteria_a(
		p_effective_date               => p_effective_date,
		p_datetrack_update_mode        => p_datetrack_update_mode,
		p_assignment_id                => p_assignment_id,
		p_object_version_number        => p_object_version_number,
		p_grade_id                     => p_grade_id,
		p_position_id                  => p_position_id,
		p_job_id                       => p_job_id,
		p_payroll_id                   => p_payroll_id,
		p_location_id                  => p_location_id,
		p_special_ceiling_step_id      => p_special_ceiling_step_id,
		p_organization_id              => p_organization_id,
		p_pay_basis_id                 => p_pay_basis_id,
		p_segment1                     => p_segment1,
		p_segment2                     => p_segment2,
		p_segment3                     => p_segment3,
		p_segment4                     => p_segment4,
		p_segment5                     => p_segment5,
		p_segment6                     => p_segment6,
		p_segment7                     => p_segment7,
		p_segment8                     => p_segment8,
		p_segment9                     => p_segment9,
		p_segment10                    => p_segment10,
		p_segment11                    => p_segment11,
		p_segment12                    => p_segment12,
		p_segment13                    => p_segment13,
		p_segment14                    => p_segment14,
		p_segment15                    => p_segment15,
		p_segment16                    => p_segment16,
		p_segment17                    => p_segment17,
		p_segment18                    => p_segment18,
		p_segment19                    => p_segment19,
		p_segment20                    => p_segment20,
		p_segment21                    => p_segment21,
		p_segment22                    => p_segment22,
		p_segment23                    => p_segment23,
		p_segment24                    => p_segment24,
		p_segment25                    => p_segment25,
		p_segment26                    => p_segment26,
		p_segment27                    => p_segment27,
		p_segment28                    => p_segment28,
		p_segment29                    => p_segment29,
		p_segment30                    => p_segment30,
		p_group_name                   => p_group_name,
		p_employment_category          => p_employment_category,
		p_effective_start_date         => p_effective_start_date,
		p_effective_end_date           => p_effective_end_date,
		p_people_group_id              => p_people_group_id,
		p_org_now_no_manager_warning   => p_org_now_no_manager_warning,
		p_other_manager_warning        => p_other_manager_warning,
		p_spp_delete_warning           => p_spp_delete_warning,
		p_entries_changed_warning      => p_entries_changed_warning,
		p_tax_district_changed_warning => p_tax_district_changed_warning,
		p_concat_segments              => p_concat_segments,
		p_contract_id                  => p_contract_id,
		p_establishment_id             => p_establishment_id,
		p_concatenated_segments        => p_concatenated_segments,
		p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id,
		p_scl_segment1                 => p_scl_segment1
               );

   elsif p_assignment_type = 'C' and p_primary_flag = 'Y' then
	hr_assignment_beO.update_cwk_asg_criteria_a(
		p_effective_date               => p_effective_date,
		p_datetrack_update_mode        => p_datetrack_update_mode,
		p_assignment_id                => p_assignment_id,
		p_object_version_number        => p_object_version_number,
		p_grade_id                     => p_grade_id,
		p_position_id                  => p_position_id,
		p_job_id                       => p_job_id,
		p_location_id                  => p_location_id,
		p_organization_id              => p_organization_id,
		p_pay_basis_id                 => p_pay_basis_id,
		p_segment1                     => p_segment1,
		p_segment2                     => p_segment2,
		p_segment3                     => p_segment3,
		p_segment4                     => p_segment4,
		p_segment5                     => p_segment5,
		p_segment6                     => p_segment6,
		p_segment7                     => p_segment7,
		p_segment8                     => p_segment8,
		p_segment9                     => p_segment9,
		p_segment10                    => p_segment10,
		p_segment11                    => p_segment11,
		p_segment12                    => p_segment12,
		p_segment13                    => p_segment13,
		p_segment14                    => p_segment14,
		p_segment15                    => p_segment15,
		p_segment16                    => p_segment16,
		p_segment17                    => p_segment17,
		p_segment18                    => p_segment18,
		p_segment19                    => p_segment19,
		p_segment20                    => p_segment20,
		p_segment21                    => p_segment21,
		p_segment22                    => p_segment22,
		p_segment23                    => p_segment23,
		p_segment24                    => p_segment24,
		p_segment25                    => p_segment25,
		p_segment26                    => p_segment26,
		p_segment27                    => p_segment27,
		p_segment28                    => p_segment28,
		p_segment29                    => p_segment29,
		p_segment30                    => p_segment30,
		p_people_group_name            => p_people_group_name,
		p_effective_start_date         => p_effective_start_date,
		p_effective_end_date           => p_effective_end_date,
		p_people_group_id              => p_people_group_id,
		p_org_now_no_manager_warning   => p_org_now_no_manager_warning,
		p_other_manager_warning        => p_other_manager_warning,
		p_spp_delete_warning           => p_spp_delete_warning,
		p_entries_changed_warning      => p_entries_changed_warning,
		p_tax_district_changed_warning => p_tax_district_changed_warning,
		p_concat_segments              => p_concat_segments
		);
    end if;
    hr_utility.set_location('Leaving: UPDATE'|| l_proc, 30);
end if;
hr_utility.set_location('Leaving:'|| l_proc, 20);
end assignment_business_event;

end HR_ASSIGNMENT_BUSINESS_EVENT;

/