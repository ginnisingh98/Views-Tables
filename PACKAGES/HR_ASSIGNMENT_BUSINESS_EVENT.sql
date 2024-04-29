--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_BUSINESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_BUSINESS_EVENT" AUTHID CURRENT_USER as
/* $Header: peasgbev.pkh 120.0 2005/10/31 04:39:32 bshukla noship $ */
--
-- -----------------------------------------------------------------------------------
-- |--------------------------< assignment_business_event >--------------------------|
-- -----------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This package raises a business event when an assignment is updated.
--
-- Prerequisites:
-- None
-- In Parameters:
--
--   Name                     Reqd	 Type         Description
-- p_event                      Y  	varchar2
-- p_assignment_type            Y  	varchar2
-- p_primary_flag               Y  	varchar2
-- p_effective_date             Y  	date
-- p_datetrack_update_mode      N 	varchar2
-- p_assignment_id              Y  	number
-- p_object_version_number      N  	number
-- p_grade_id                   N  	number
-- p_position_id                N  	number
-- p_job_id                     N  	number
-- p_payroll_id                 N  	number
-- p_location_id                N  	number
-- p_special_ceiling_step_id    N  	number
-- p_organization_id            N  	number
-- p_pay_basis_id               N 	number
-- p_segment1                   N  	varchar2
-- p_segment2                   N  	varchar2
-- p_segment3                   N  	varchar2
-- p_segment4                   N  	varchar2
-- p_segment5                   N  	varchar2
-- p_segment6                   N  	varchar2
-- p_segment7                   N 	varchar2
-- p_segment8                   N  	varchar2
-- p_segment9                   N  	varchar2
-- p_segment10                  N  	varchar2
-- p_segment11                  N  	varchar2
-- p_segment12                  N 	varchar2
-- p_segment13                  N  	varchar2
-- p_segment14                  N  	varchar2
-- p_segment15                  N  	varchar2
-- p_segment16                  N  	varchar2
-- p_segment17                  N  	varchar2
-- p_segment18                  N  	varchar2
-- p_segment19                  N  	varchar2
-- p_segment20                  N  	varchar2
-- p_segment21                  N  	varchar2
-- p_segment22                  N  	varchar2
-- p_segment23                  N  	varchar2
-- p_segment24                  N  	varchar2
-- p_segment25                  N  	varchar2
-- p_segment26                  N  	varchar2
-- p_segment27                  N 	varchar2
-- p_segment28                  N 	varchar2
-- p_segment29                  N  	varchar2
-- p_segment30                  N  	varchar2
-- p_people_group_name          N  	varchar2
-- p_group_name                 N  	varchar2
-- p_employment_category        N  	varchar2
-- p_effective_start_date       N  	date
-- p_effective_end_date         N 	date
-- p_people_group_id            N  	number
-- p_org_now_no_manager_warning N  	boolean
-- p_other_manager_warning      N  	boolean
-- p_spp_delete_warning         N 	boolean
-- p_entries_changed_warning    N 	varchar2
-- p_tax_district_changed_warning  N	boolean
-- p_concat_segments            N	varchar2
-- p_contract_id                N 	number
-- p_establishment_id           N 	number
-- p_concatenated_segments      N 	varchar2
-- p_soft_coding_keyflex_id     N 	number
-- p_scl_segment1               N	varchar2
--
-- Post Success:
--  A Business Event will be raised on update of Assignment.
--
--
-- Post Failure:
-- Business Event will not be raised and an error will be raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}


procedure assignment_business_event(
p_event                      in  varchar2,
p_assignment_type            in  varchar2,
p_primary_flag               in  varchar2,
p_effective_date             in  date,
p_datetrack_update_mode      in  varchar2 default hr_api.g_update,
p_assignment_id              in  number,
p_object_version_number      in  number,
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
p_scl_segment1               in varchar2 default hr_api.g_varchar2);

end HR_ASSIGNMENT_BUSINESS_EVENT;

 

/
