--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BK3" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_emp_asg_criteria_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_emp_asg_criteria_b
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_special_ceiling_step_id      in     number
  ,p_organization_id              in     number
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
 -- Bug 94911
-- Amended p_group_name to p_concat_segments
  ,p_concat_segments              in     varchar2
  ,p_employment_category          in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_emp_asg_criteria_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_emp_asg_criteria_a
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_special_ceiling_step_id      in     number
  ,p_organization_id              in     number
  ,p_pay_basis_id                 in     number
  ,p_segment1                     in     varchar2
  ,p_segment2                     in     varchar2
  ,p_segment3                     in     varchar2
  ,p_segment4                     in     varchar2
  ,p_segment5                     in     varchar2
  ,p_segment6                     in     varchar2
  ,p_segment7                     in     varchar2
  ,p_segment8                     in     varchar2
  ,p_segment9                     in     varchar2
  ,p_segment10                    in     varchar2
  ,p_segment11                    in     varchar2
  ,p_segment12                    in     varchar2
  ,p_segment13                    in     varchar2
  ,p_segment14                    in     varchar2
  ,p_segment15                    in     varchar2
  ,p_segment16                    in     varchar2
  ,p_segment17                    in     varchar2
  ,p_segment18                    in     varchar2
  ,p_segment19                    in     varchar2
  ,p_segment20                    in     varchar2
  ,p_segment21                    in     varchar2
  ,p_segment22                    in     varchar2
  ,p_segment23                    in     varchar2
  ,p_segment24                    in     varchar2
  ,p_segment25                    in     varchar2
  ,p_segment26                    in     varchar2
  ,p_segment27                    in     varchar2
  ,p_segment28                    in     varchar2
  ,p_segment29                    in     varchar2
  ,p_segment30                    in     varchar2
  ,p_group_name                   in     varchar2
  ,p_employment_category          in     varchar2
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
  ,p_people_group_id              in     number
  ,p_org_now_no_manager_warning   in     boolean
  ,p_other_manager_warning        in     boolean
  ,p_spp_delete_warning           in     boolean
  ,p_entries_changed_warning      in     varchar2
  ,p_tax_district_changed_warning in     boolean
-- Added new param p_concat_segments
  ,p_concat_segments		  in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_concatenated_segments        in   	 varchar2
  ,p_soft_coding_keyflex_id       in 	 number
  ,p_scl_segment1                 in     varchar2
  );
--
end hr_assignment_bk3;

/
