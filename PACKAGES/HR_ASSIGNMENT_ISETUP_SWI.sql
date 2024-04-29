--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_ISETUP_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_ISETUP_SWI" AUTHID CURRENT_USER As
/* $Header: hrasgstp.pkh 120.2 2005/09/16 01:33:01 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< accept_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.accept_apl_asg
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
PROCEDURE accept_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< activate_apl_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.activate_apl_asg
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
PROCEDURE activate_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_secondary_apl_asg >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.create_secondary_apl_asg
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
PROCEDURE create_secondary_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_change_reason                in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_ass_attribute_category       in     varchar2  default null
  ,p_ass_attribute1               in     varchar2  default null
  ,p_ass_attribute2               in     varchar2  default null
  ,p_ass_attribute3               in     varchar2  default null
  ,p_ass_attribute4               in     varchar2  default null
  ,p_ass_attribute5               in     varchar2  default null
  ,p_ass_attribute6               in     varchar2  default null
  ,p_ass_attribute7               in     varchar2  default null
  ,p_ass_attribute8               in     varchar2  default null
  ,p_ass_attribute9               in     varchar2  default null
  ,p_ass_attribute10              in     varchar2  default null
  ,p_ass_attribute11              in     varchar2  default null
  ,p_ass_attribute12              in     varchar2  default null
  ,p_ass_attribute13              in     varchar2  default null
  ,p_ass_attribute14              in     varchar2  default null
  ,p_ass_attribute15              in     varchar2  default null
  ,p_ass_attribute16              in     varchar2  default null
  ,p_ass_attribute17              in     varchar2  default null
  ,p_ass_attribute18              in     varchar2  default null
  ,p_ass_attribute19              in     varchar2  default null
  ,p_ass_attribute20              in     varchar2  default null
  ,p_ass_attribute21              in     varchar2  default null
  ,p_ass_attribute22              in     varchar2  default null
  ,p_ass_attribute23              in     varchar2  default null
  ,p_ass_attribute24              in     varchar2  default null
  ,p_ass_attribute25              in     varchar2  default null
  ,p_ass_attribute26              in     varchar2  default null
  ,p_ass_attribute27              in     varchar2  default null
  ,p_ass_attribute28              in     varchar2  default null
  ,p_ass_attribute29              in     varchar2  default null
  ,p_ass_attribute30              in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_concatenated_segments           out nocopy varchar2
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_posting_content_id           in     number    default null
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                in     number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< offer_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.offer_apl_asg
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
PROCEDURE offer_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< terminate_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.terminate_apl_asg
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
PROCEDURE terminate_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_apl_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.update_apl_asg
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
PROCEDURE update_apl_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_person_referred_by_id        in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in     number    default hr_api.g_number
  ,p_recruitment_activity_id      in     number    default hr_api.g_number
  ,p_source_organization_id       in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_application_id               in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_probation_end           in     date      default hr_api.g_date
  ,p_default_code_comb_id         in     number    default hr_api.g_number
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2  default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_perf_review_period           in     number    default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_unit               in     varchar2  default hr_api.g_varchar2
  ,p_sal_review_period            in     number    default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2  default hr_api.g_varchar2
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_applicant_rank               in     number    default hr_api.g_number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_emp_asg >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.update_emp_asg
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
PROCEDURE update_emp_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_probation_end           in     date      default hr_api.g_date
  ,p_default_code_comb_id         in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2  default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_perf_review_period           in     number    default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2  default hr_api.g_varchar2
  ,p_probation_period             in     number    default hr_api.g_number
  ,p_probation_unit               in     varchar2  default hr_api.g_varchar2
  ,p_sal_review_period            in     number    default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2  default hr_api.g_varchar2
  ,p_set_of_books_id              in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2  default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2  default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2  default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
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
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_cagr_id_flex_num             in     number    default hr_api.g_number
  ,p_cag_segment1                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2  default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2  default hr_api.g_varchar2
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     varchar2  default hr_api.g_number
  ,p_tax_unit_name                in     varchar2  default hr_api.g_varchar2
  ,p_scl_flex_struc_code          in     varchar2  default hr_api.g_varchar2
  ,p_scl_concatenated_segments    in     varchar2  default hr_api.g_varchar2
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
--
--

-- ----------------------------------------------------------------------------
-- |------------------------< update_emp_asg_criteria >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assignment_api.update_emp_asg_criteria
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
PROCEDURE update_emp_asg_criteria
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
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
  ,p_group_name                      out nocopy varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_people_group_id                 out nocopy number
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_soft_coding_keyflex >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is to insert the records in hr_soft_coding_keyflex
--  during the migration using iSetup Migrator.
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_soft_coding_keyflex_id will return keyflex id value.
--
-- Post Failure:
--  none.
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
FUNCTION insert_soft_coding_keyflex
  (p_tax_unit_name    in varchar2
  ,p_bg_id            in number
  ,p_scl_flex_struc_code  in varchar2
  ,p_scl_concat_segments  in varchar2) RETURN NUMBER;
--
--
end hr_assignment_isetup_swi;

 

/
