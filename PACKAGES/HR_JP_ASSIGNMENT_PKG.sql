--------------------------------------------------------
--  DDL for Package HR_JP_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_ASSIGNMENT_PKG" AUTHID CURRENT_USER as
/* $Header: hrjppasg.pkh 115.1 99/07/17 16:39:09 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_jp_emp_asg_criteria >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls core API hr_assignment_api.update_emp_asg_criteria
--   and is used by ADE to update emp assignments queried on the JP Asg Folder.
--
--   Note: Users must use the core API since this is NOT an API.
--
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
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
  );

end hr_jp_assignment_pkg;

 

/
