--------------------------------------------------------
--  DDL for Package Body HR_JP_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_ASSIGNMENT_PKG" as
/* $Header: hrjppasg.pkb 115.1 99/07/17 16:39:01 porting ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_jp_assignment_pkg.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_jp_emp_asg_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_jp_emp_asg_criteria
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_special_ceiling_step_id      in out number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category_code     in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out date
  ,p_effective_end_date              out date
  ,p_people_group_id                 out number
  ,p_group_name                      out varchar2
  ,p_org_now_no_manager_warning      out boolean
  ,p_other_manager_warning           out boolean
  ,p_spp_delete_warning              out boolean
  ,p_entries_changed_warning         out varchar2
  ,p_tax_district_changed_warning    out boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) :=
                                    g_package || 'update_jp_emp_asg_criteria';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  hr_assignment_api.update_emp_asg_criteria
    (p_validate                => p_validate
    ,p_effective_date          => p_effective_date
    ,p_datetrack_update_mode   => p_datetrack_update_mode
    ,p_assignment_id           => p_assignment_id
    ,p_object_version_number   => p_object_version_number
    ,p_grade_id                => p_grade_id
    ,p_position_id             => p_position_id
    ,p_job_id                  => p_job_id
    ,p_payroll_id              => p_payroll_id
    ,p_location_id             => p_location_id
    ,p_special_ceiling_step_id => p_special_ceiling_step_id
    ,p_organization_id         => p_organization_id
    ,p_pay_basis_id            => p_pay_basis_id
    ,p_segment1                => p_segment1
    ,p_segment2                => p_segment2
    ,p_segment3                => p_segment3
    ,p_segment4                => p_segment4
    ,p_segment5                => p_segment5
    ,p_segment6                => p_segment6
    ,p_segment7                => p_segment7
    ,p_segment8                => p_segment8
    ,p_segment9                => p_segment9
    ,p_segment10               => p_segment10
    ,p_segment11               => p_segment11
    ,p_segment12               => p_segment12
    ,p_segment13               => p_segment13
    ,p_segment14               => p_segment14
    ,p_segment15               => p_segment15
    ,p_segment16               => p_segment16
    ,p_segment17               => p_segment17
    ,p_segment18               => p_segment18
    ,p_segment19               => p_segment19
    ,p_segment20               => p_segment20
    ,p_segment21               => p_segment21
    ,p_segment22               => p_segment22
    ,p_segment23               => p_segment23
    ,p_segment24               => p_segment24
    ,p_segment25               => p_segment25
    ,p_segment26               => p_segment26
    ,p_segment27               => p_segment27
    ,p_segment28               => p_segment28
    ,p_segment29               => p_segment29
    ,p_segment30               => p_segment30
    ,p_employment_category     => p_employment_category_code
    ,p_effective_start_date    => p_effective_start_date
    ,p_effective_end_date      => p_effective_end_date
    ,p_people_group_id         => p_people_group_id
    ,p_group_name              => p_group_name
    ,p_org_now_no_manager_warning => p_org_now_no_manager_warning
    ,p_other_manager_warning   => p_other_manager_warning
    ,p_spp_delete_warning      => p_spp_delete_warning
    ,p_entries_changed_warning => p_entries_changed_warning
    ,p_tax_district_changed_warning => p_tax_district_changed_warning
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 270);
  --
end update_jp_emp_asg_criteria;
--
end hr_jp_assignment_pkg;

/
