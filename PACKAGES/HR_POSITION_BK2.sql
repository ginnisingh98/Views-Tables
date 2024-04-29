--------------------------------------------------------
--  DDL for Package HR_POSITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_BK2" AUTHID CURRENT_USER as
/* $Header: peposapi.pkh 120.5.12010000.1 2008/07/28 05:23:44 appldev ship $ */
--
--
g_debug boolean := hr_utility.debug_enabled;
--
--
-- Date track position update hooks will be added here
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_position_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_b
  (
   p_position_id                    in  number
  ,p_availability_status_id         in  number
--  ,p_business_group_id              in  number
  ,p_entry_step_id                  in  number
  ,p_entry_grade_rule_id            in  number
--  ,p_job_id                         in  number
  ,p_location_id                    in  number
--  ,p_organization_id                in  number
  ,p_pay_freq_payroll_id            in  number
  ,p_position_definition_id         in  number
  ,p_position_transaction_id        in  number
  ,p_prior_position_id              in  number
  ,p_relief_position_id             in  number
  ,p_entry_grade_id                 in  number
  ,p_successor_position_id          in  number
  ,p_supervisor_position_id         in  number
  ,p_amendment_date                 in  date
  ,p_amendment_recommendation       in  varchar2
  ,p_amendment_ref_number           in  varchar2
  ,p_bargaining_unit_cd             in  varchar2
  ,p_comments                       in  long
  ,p_current_job_prop_end_date      in  date
  ,p_current_org_prop_end_date      in  date
  ,p_avail_status_prop_end_date     in  date
  ,p_date_effective                 in  date
  ,p_date_end                       in  date
  ,p_earliest_hire_date             in  date
  ,p_fill_by_date                   in  date
  ,p_frequency                      in  varchar2
  ,p_fte                            in  number
  ,p_max_persons                    in  number
  ,p_name                           in  varchar2
  ,p_overlap_period                 in  number
  ,p_overlap_unit_cd                in  varchar2
  ,p_pay_term_end_day_cd            in  varchar2
  ,p_pay_term_end_month_cd          in  varchar2
  ,p_permanent_temporary_flag       in  varchar2
  ,p_permit_recruitment_flag        in  varchar2
  ,p_position_type                  in  varchar2
  ,p_posting_description            in  varchar2
  ,p_probation_period               in  number
  ,p_probation_period_unit_cd       in  varchar2
  ,p_replacement_required_flag      in  varchar2
  ,p_review_flag                    in  varchar2
  ,p_seasonal_flag                  in  varchar2
  ,p_security_requirements          in  varchar2
  ,p_status                         in  varchar2
  ,p_term_start_day_cd              in  varchar2
  ,p_term_start_month_cd            in  varchar2
  ,p_time_normal_finish             in  varchar2
  ,p_time_normal_start              in  varchar2
  ,p_update_source_cd               in  varchar2
  ,p_working_hours                  in  number
  ,p_works_council_approval_flag    in  varchar2
  ,p_work_period_type_cd            in  varchar2
  ,p_work_term_end_day_cd           in  varchar2
  ,p_work_term_end_month_cd         in  varchar2
  ,p_proposed_fte_for_layoff        in  number
  ,p_proposed_date_for_layoff       in  date
  ,p_pay_basis_id                   in  number
  ,p_supervisor_id                  in  number
  -- ,p_copied_to_old_table_flag       in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_information_category           in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_language_code                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_position_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_position_a
  (
   p_position_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_availability_status_id         in  number
--  ,p_business_group_id              in  number
  ,p_entry_step_id                  in  number
  ,p_entry_grade_rule_id            in  number
--  ,p_job_id                         in  number
  ,p_location_id                    in  number
--  ,p_organization_id                in  number
  ,p_pay_freq_payroll_id            in  number
  ,p_position_definition_id         in  number
  ,p_position_transaction_id        in  number
  ,p_prior_position_id              in  number
  ,p_relief_position_id             in  number
  ,p_entry_grade_id                 in  number
  ,p_successor_position_id          in  number
  ,p_supervisor_position_id         in  number
  ,p_amendment_date                 in  date
  ,p_amendment_recommendation       in  varchar2
  ,p_amendment_ref_number           in  varchar2
  ,p_bargaining_unit_cd             in  varchar2
  ,p_comments                       in  long
  ,p_current_job_prop_end_date      in  date
  ,p_current_org_prop_end_date      in  date
  ,p_avail_status_prop_end_date     in  date
  ,p_date_effective                 in  date
  ,p_date_end                       in  date
  ,p_earliest_hire_date             in  date
  ,p_fill_by_date                   in  date
  ,p_frequency                      in  varchar2
  ,p_fte                            in  number
  ,p_max_persons                    in  number
  ,p_name                           in  varchar2
  ,p_overlap_period                 in  number
  ,p_overlap_unit_cd                in  varchar2
  ,p_pay_term_end_day_cd            in  varchar2
  ,p_pay_term_end_month_cd          in  varchar2
  ,p_permanent_temporary_flag       in  varchar2
  ,p_permit_recruitment_flag        in  varchar2
  ,p_position_type                  in  varchar2
  ,p_posting_description            in  varchar2
  ,p_probation_period               in  number
  ,p_probation_period_unit_cd       in  varchar2
  ,p_replacement_required_flag      in  varchar2
  ,p_review_flag                    in  varchar2
  ,p_seasonal_flag                  in  varchar2
  ,p_security_requirements          in  varchar2
  ,p_status                         in  varchar2
  ,p_term_start_day_cd              in  varchar2
  ,p_term_start_month_cd            in  varchar2
  ,p_time_normal_finish             in  varchar2
  ,p_time_normal_start              in  varchar2
  ,p_update_source_cd               in  varchar2
  ,p_working_hours                  in  number
  ,p_works_council_approval_flag    in  varchar2
  ,p_work_period_type_cd            in  varchar2
  ,p_work_term_end_day_cd           in  varchar2
  ,p_work_term_end_month_cd         in  varchar2
  ,p_proposed_fte_for_layoff        in  number
  ,p_proposed_date_for_layoff       in  date
  ,p_pay_basis_id                   in  number
  ,p_supervisor_id                  in  number
  -- ,p_copied_to_old_table_flag       in  varchar2
  ,p_information1                   in  varchar2
  ,p_information2                   in  varchar2
  ,p_information3                   in  varchar2
  ,p_information4                   in  varchar2
  ,p_information5                   in  varchar2
  ,p_information6                   in  varchar2
  ,p_information7                   in  varchar2
  ,p_information8                   in  varchar2
  ,p_information9                   in  varchar2
  ,p_information10                  in  varchar2
  ,p_information11                  in  varchar2
  ,p_information12                  in  varchar2
  ,p_information13                  in  varchar2
  ,p_information14                  in  varchar2
  ,p_information15                  in  varchar2
  ,p_information16                  in  varchar2
  ,p_information17                  in  varchar2
  ,p_information18                  in  varchar2
  ,p_information19                  in  varchar2
  ,p_information20                  in  varchar2
  ,p_information21                  in  varchar2
  ,p_information22                  in  varchar2
  ,p_information23                  in  varchar2
  ,p_information24                  in  varchar2
  ,p_information25                  in  varchar2
  ,p_information26                  in  varchar2
  ,p_information27                  in  varchar2
  ,p_information28                  in  varchar2
  ,p_information29                  in  varchar2
  ,p_information30                  in  varchar2
  ,p_information_category           in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_attribute_category             in  varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_concat_segments               in     varchar2
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_language_code                 in  varchar2
  );
--
--
-- end of date tracked position update hooks
--
end hr_position_bk2;

/
