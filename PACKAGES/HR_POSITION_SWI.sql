--------------------------------------------------------
--  DDL for Package HR_POSITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_SWI" AUTHID CURRENT_USER As
/* $Header: hrposswi.pkh 115.1 2002/12/03 00:57:34 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_position >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_position_api.create_position
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_position
  (p_position_id                     out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_position_definition_id          out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_object_version_number           out nocopy number
  ,p_job_id                       in     number
  ,p_organization_id              in     number
  ,p_effective_date               in     date
  ,p_date_effective               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_availability_status_id       in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_entry_step_id                in     number    default null
  ,p_entry_grade_rule_id          in     number    default null
  ,p_location_id                  in     number    default null
  ,p_pay_freq_payroll_id          in     number    default null
  ,p_position_transaction_id      in     number    default null
  ,p_prior_position_id            in     number    default null
  ,p_relief_position_id           in     number    default null
  ,p_entry_grade_id               in     number    default null
  ,p_successor_position_id        in     number    default null
  ,p_supervisor_position_id       in     number    default null
  ,p_amendment_date               in     date      default null
  ,p_amendment_recommendation     in     varchar2  default null
  ,p_amendment_ref_number         in     varchar2  default null
  ,p_bargaining_unit_cd           in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_current_job_prop_end_date    in     date      default null
  ,p_current_org_prop_end_date    in     date      default null
  ,p_avail_status_prop_end_date   in     date      default null
  ,p_date_end                     in     date      default null
  ,p_earliest_hire_date           in     date      default null
  ,p_fill_by_date                 in     date      default null
  ,p_frequency                    in     varchar2  default null
  ,p_fte                          in     number    default null
  ,p_max_persons                  in     number    default null
  ,p_overlap_period               in     number    default null
  ,p_overlap_unit_cd              in     varchar2  default null
  ,p_pay_term_end_day_cd          in     varchar2  default null
  ,p_pay_term_end_month_cd        in     varchar2  default null
  ,p_permanent_temporary_flag     in     varchar2  default null
  ,p_permit_recruitment_flag      in     varchar2  default null
  ,p_position_type                in     varchar2  default null
  ,p_posting_description          in     varchar2  default null
  ,p_probation_period             in     number    default null
  ,p_probation_period_unit_cd     in     varchar2  default null
  ,p_replacement_required_flag    in     varchar2  default null
  ,p_review_flag                  in     varchar2  default null
  ,p_seasonal_flag                in     varchar2  default null
  ,p_security_requirements        in     varchar2  default null
  ,p_status                       in     varchar2  default null
  ,p_term_start_day_cd            in     varchar2  default null
  ,p_term_start_month_cd          in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_update_source_cd             in     varchar2  default null
  ,p_working_hours                in     number    default null
  ,p_works_council_approval_flag  in     varchar2  default null
  ,p_work_period_type_cd          in     varchar2  default null
  ,p_work_term_end_day_cd         in     varchar2  default null
  ,p_work_term_end_month_cd       in     varchar2  default null
  ,p_proposed_fte_for_layoff      in     number    default null
  ,p_proposed_date_for_layoff     in     date      default null
  ,p_pay_basis_id                 in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_information21                in     varchar2  default null
  ,p_information22                in     varchar2  default null
  ,p_information23                in     varchar2  default null
  ,p_information24                in     varchar2  default null
  ,p_information25                in     varchar2  default null
  ,p_information26                in     varchar2  default null
  ,p_information27                in     varchar2  default null
  ,p_information28                in     varchar2  default null
  ,p_information29                in     varchar2  default null
  ,p_information30                in     varchar2  default null
  ,p_information_category         in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_segment1                     in     varchar2  default null
  ,p_segment2                     in     varchar2  default null
  ,p_segment3                     in     varchar2  default null
  ,p_segment4                     in     varchar2  default null
  ,p_segment5                     in     varchar2  default null
  ,p_segment6                     in     varchar2  default null
  ,p_segment7                     in     varchar2  default null
  ,p_segment8                     in     varchar2  default null
  ,p_segment9                     in     varchar2  default null
  ,p_segment10                    in     varchar2  default null
  ,p_segment11                    in     varchar2  default null
  ,p_segment12                    in     varchar2  default null
  ,p_segment13                    in     varchar2  default null
  ,p_segment14                    in     varchar2  default null
  ,p_segment15                    in     varchar2  default null
  ,p_segment16                    in     varchar2  default null
  ,p_segment17                    in     varchar2  default null
  ,p_segment18                    in     varchar2  default null
  ,p_segment19                    in     varchar2  default null
  ,p_segment20                    in     varchar2  default null
  ,p_segment21                    in     varchar2  default null
  ,p_segment22                    in     varchar2  default null
  ,p_segment23                    in     varchar2  default null
  ,p_segment24                    in     varchar2  default null
  ,p_segment25                    in     varchar2  default null
  ,p_segment26                    in     varchar2  default null
  ,p_segment27                    in     varchar2  default null
  ,p_segment28                    in     varchar2  default null
  ,p_segment29                    in     varchar2  default null
  ,p_segment30                    in     varchar2  default null
  ,p_concat_segments              in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_security_profile_id          in     number    default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_position >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_position_api.delete_position
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_position
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_position_id                  in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_security_profile_id          in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_position_api.lck
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_position_id                  in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_position >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_position_api.update_position
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_position
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_position_id                  in     number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_position_definition_id          out nocopy number
  ,p_name                            out nocopy varchar2
  ,p_availability_status_id       in     number    default hr_api.g_number
  ,p_entry_step_id                in     number    default hr_api.g_number
  ,p_entry_grade_rule_id          in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_pay_freq_payroll_id          in     number    default hr_api.g_number
  ,p_position_transaction_id      in     number    default hr_api.g_number
  ,p_prior_position_id            in     number    default hr_api.g_number
  ,p_relief_position_id           in     number    default hr_api.g_number
  ,p_entry_grade_id               in     number    default hr_api.g_number
  ,p_successor_position_id        in     number    default hr_api.g_number
  ,p_supervisor_position_id       in     number    default hr_api.g_number
  ,p_amendment_date               in     date      default hr_api.g_date
  ,p_amendment_recommendation     in     varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number         in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_cd           in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_current_job_prop_end_date    in     date      default hr_api.g_date
  ,p_current_org_prop_end_date    in     date      default hr_api.g_date
  ,p_avail_status_prop_end_date   in     date      default hr_api.g_date
  ,p_date_effective               in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_earliest_hire_date           in     date      default hr_api.g_date
  ,p_fill_by_date                 in     date      default hr_api.g_date
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_fte                          in     number    default hr_api.g_number
  ,p_max_persons                  in     number    default hr_api.g_number
  ,p_overlap_period               in     number    default hr_api.g_number
  ,p_overlap_unit_cd              in     varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd          in     varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd        in     varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag     in     varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag      in     varchar2  default hr_api.g_varchar2
  ,p_position_type                in     varchar2  default hr_api.g_varchar2
  ,p_posting_description          in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_period_unit_cd     in     varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag    in     varchar2  default hr_api.g_varchar2
  ,p_review_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                in     varchar2  default hr_api.g_varchar2
  ,p_security_requirements        in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd            in     varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd          in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_update_source_cd             in     varchar2  default hr_api.g_varchar2
  ,p_working_hours                in     number    default hr_api.g_number
  ,p_works_council_approval_flag  in     varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd          in     varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd         in     varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd       in     varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff      in     number    default hr_api.g_number
  ,p_proposed_date_for_layoff     in     date      default hr_api.g_date
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_segment1                     in     varchar2  default hr_api.g_varchar2
  ,p_segment2                     in     varchar2  default hr_api.g_varchar2
  ,p_segment3                     in     varchar2  default hr_api.g_varchar2
  ,p_segment4                     in     varchar2  default hr_api.g_varchar2
  ,p_segment5                     in     varchar2  default hr_api.g_varchar2
  ,p_segment6                     in     varchar2  default hr_api.g_varchar2
  ,p_segment7                     in     varchar2  default hr_api.g_varchar2
  ,p_segment8                     in     varchar2  default hr_api.g_varchar2
  ,p_segment9                     in     varchar2  default hr_api.g_varchar2
  ,p_segment10                    in     varchar2  default hr_api.g_varchar2
  ,p_segment11                    in     varchar2  default hr_api.g_varchar2
  ,p_segment12                    in     varchar2  default hr_api.g_varchar2
  ,p_segment13                    in     varchar2  default hr_api.g_varchar2
  ,p_segment14                    in     varchar2  default hr_api.g_varchar2
  ,p_segment15                    in     varchar2  default hr_api.g_varchar2
  ,p_segment16                    in     varchar2  default hr_api.g_varchar2
  ,p_segment17                    in     varchar2  default hr_api.g_varchar2
  ,p_segment18                    in     varchar2  default hr_api.g_varchar2
  ,p_segment19                    in     varchar2  default hr_api.g_varchar2
  ,p_segment20                    in     varchar2  default hr_api.g_varchar2
  ,p_segment21                    in     varchar2  default hr_api.g_varchar2
  ,p_segment22                    in     varchar2  default hr_api.g_varchar2
  ,p_segment23                    in     varchar2  default hr_api.g_varchar2
  ,p_segment24                    in     varchar2  default hr_api.g_varchar2
  ,p_segment25                    in     varchar2  default hr_api.g_varchar2
  ,p_segment26                    in     varchar2  default hr_api.g_varchar2
  ,p_segment27                    in     varchar2  default hr_api.g_varchar2
  ,p_segment28                    in     varchar2  default hr_api.g_varchar2
  ,p_segment29                    in     varchar2  default hr_api.g_varchar2
  ,p_segment30                    in     varchar2  default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
end hr_position_swi;

 

/
