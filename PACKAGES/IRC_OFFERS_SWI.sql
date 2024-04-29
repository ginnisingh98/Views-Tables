--------------------------------------------------------
--  DDL for Package IRC_OFFERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFERS_SWI" AUTHID CURRENT_USER As
/* $Header: iriofswi.pkh 120.12.12010000.2 2009/05/19 11:07:17 vmummidi ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_offer >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.create_offer
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
PROCEDURE create_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_offer_status                 in     varchar2
  ,p_discretionary_job_title      in     varchar2  default null
  ,p_offer_extended_method        in     varchar2  default null
  ,p_respondent_id                in     number    default null
  ,p_expiry_date                  in     date      default null
  ,p_proposed_start_date          in     date      default null
  ,p_offer_letter_tracking_code   in     varchar2  default null
  ,p_offer_postal_service         in     varchar2  default null
  ,p_offer_shipping_date          in     date      default null
  ,p_applicant_assignment_id      in     number
  ,p_offer_assignment_id          in     number
  ,p_address_id                   in     number    default null
  ,p_template_id                  in     number    default null
  ,p_offer_letter_file_type       in     varchar2  default null
  ,p_offer_letter_file_name       in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
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
  ,p_status_change_date           in     date      default null
  ,p_offer_id                     in out nocopy number
  ,p_offer_version                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_offer >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.update_offer
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
PROCEDURE update_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_status                 in     varchar2  default hr_api.g_varchar2
  ,p_discretionary_job_title      in     varchar2  default hr_api.g_varchar2
  ,p_offer_extended_method        in     varchar2  default hr_api.g_varchar2
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_expiry_date                  in     date      default hr_api.g_date
  ,p_proposed_start_date          in     date      default hr_api.g_date
  ,p_offer_letter_tracking_code   in     varchar2  default hr_api.g_varchar2
  ,p_offer_postal_service         in     varchar2  default hr_api.g_varchar2
  ,p_offer_shipping_date          in     date      default hr_api.g_date
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_assignment_id          in     number    default hr_api.g_number
  ,p_address_id                   in     number    default hr_api.g_number
  ,p_template_id                  in     number    default hr_api.g_number
  ,p_offer_letter_file_type       in     varchar2  default hr_api.g_varchar2
  ,p_offer_letter_file_name       in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
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
  ,p_change_reason                in     varchar2  default null
  ,p_decline_reason               in     varchar2  default null
  ,p_note_text                    in     varchar2  default null
  ,p_status_change_date           in     date      default null
  ,p_offer_id                     in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_offer_version                   out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_offer >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.delete_offer
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
PROCEDURE delete_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_offer_id                     in     number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< close_offer >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.close_offer
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
PROCEDURE close_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_id                     in     number    default hr_api.g_number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_decline_reason               in     varchar2  default hr_api.g_varchar2
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< hold_offer >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.hold_offer
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
PROCEDURE hold_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_id                     in     number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< release_offer >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.release_offer
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
PROCEDURE release_offer
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_id                     in     number
  ,p_respondent_id                in     number    default hr_api.g_number
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.create_offer_assignment
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
PROCEDURE create_offer_assignment
  (p_assignment_id                in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                      out nocopy number
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
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
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
  ,p_validate_df_flex             in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.update_offer_assignment
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
PROCEDURE update_offer_assignment
  (p_assignment_id                in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_business_group_id               out nocopy number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_person_referred_by_id        in     number    default hr_api.g_number
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_special_ceiling_step_id      in     number    default hr_api.g_number
  ,p_recruitment_activity_id      in     number    default hr_api.g_number
  ,p_source_organization_id       in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_soft_coding_keyflex_id       in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_pay_basis_id                 in     number    default hr_api.g_number
  ,p_assignment_type              in     varchar2  default hr_api.g_varchar2
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_application_id               in     number    default hr_api.g_number
  ,p_assignment_number            in     varchar2  default hr_api.g_varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_comment_id                      out nocopy number
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
  ,p_period_of_service_id         in     number    default hr_api.g_number
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
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
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
  ,p_contract_id                  in     number    default hr_api.g_number
  ,p_establishment_id             in     number    default hr_api.g_number
  ,p_collective_agreement_id      in     number    default hr_api.g_number
  ,p_cagr_grade_def_id            in     number    default hr_api.g_number
  ,p_cagr_id_flex_num             in     number    default hr_api.g_number
  ,p_asg_object_version_number    in out nocopy number
  ,p_notice_period                in     number    default hr_api.g_number
  ,p_notice_period_uom            in     varchar2  default hr_api.g_varchar2
  ,p_employee_category            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_placement_date_start         in     date      default hr_api.g_date
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_vendor_employee_number       in     varchar2  default hr_api.g_varchar2
  ,p_vendor_assignment_number     in     varchar2  default hr_api.g_varchar2
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_project_title                in     varchar2  default hr_api.g_varchar2
  ,p_applicant_rank               in     number    default hr_api.g_number
  ,p_grade_ladder_pgm_id          in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_vendor_site_id               in     number    default hr_api.g_number
  ,p_po_header_id                 in     number    default hr_api.g_number
  ,p_po_line_id                   in     number    default hr_api.g_number
  ,p_projected_assignment_end     in     date      default hr_api.g_date
  ,p_payroll_id_updated              out nocopy number
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_datetrack_mode               in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_id                     in out nocopy number
  ,p_offer_status                 in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_offer_assignment >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.delete_offer_assignment
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
PROCEDURE delete_offer_assignment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_assignment_id          in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< upload_offer_letter >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offers_api.upload_offer_letter
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
PROCEDURE upload_offer_letter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_letter                 in     BLOB
  ,p_offer_id                     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< run_benmgle_for_irec >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure calls the benifits wrapper for iRecruitment
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
PROCEDURE run_benmgle_for_irec
  (p_assignment_id                in     number
  ,p_effective_start_date         in     date      default trunc(sysdate)
  ,p_effective_end_date           in     date      default hr_api.g_eot
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence          in     number    default 1
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in     varchar2  default null
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                   in     number    default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
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
  ,p_object_version_number        in     number    default 1
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_effective_date               in     date
  ,p_return_status                out nocopy varchar2
  );
 --
-- ----------------------------------------------------------------------------
-- |--------------------< is_run_benmgle_for_irec_reqd >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE is_run_benmgle_for_irec_reqd
  (p_assignment_id                in     number
  ,p_effective_start_date         in     date      default trunc(sysdate)
  ,p_effective_end_date           in     date      default hr_api.g_eot
  ,p_business_group_id            in     number
  ,p_recruiter_id                 in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number    default null
  ,p_location_id                  in     number    default null
  ,p_person_referred_by_id        in     number    default null
  ,p_supervisor_id                in     number    default null
  ,p_special_ceiling_step_id      in     number    default null
  ,p_person_id                    in     number
  ,p_recruitment_activity_id      in     number    default null
  ,p_source_organization_id       in     number    default null
  ,p_organization_id              in     number
  ,p_people_group_id              in     number    default null
  ,p_soft_coding_keyflex_id       in     number    default null
  ,p_vacancy_id                   in     number    default null
  ,p_pay_basis_id                 in     number    default null
  ,p_assignment_sequence          in     number    default 1
  ,p_assignment_type              in     varchar2
  ,p_primary_flag                 in     varchar2
  ,p_application_id               in     number    default null
  ,p_assignment_number            in     varchar2  default null
  ,p_change_reason                in     varchar2  default null
  ,p_comment_id                   in     number    default null
  ,p_date_probation_end           in     date      default null
  ,p_default_code_comb_id         in     number    default null
  ,p_employment_category          in     varchar2  default null
  ,p_frequency                    in     varchar2  default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_manager_flag                 in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_perf_review_period           in     number    default null
  ,p_perf_review_period_frequency in     varchar2  default null
  ,p_period_of_service_id         in     number    default null
  ,p_probation_period             in     number    default null
  ,p_probation_unit               in     varchar2  default null
  ,p_sal_review_period            in     number    default null
  ,p_sal_review_period_frequency  in     varchar2  default null
  ,p_set_of_books_id              in     number    default null
  ,p_source_type                  in     varchar2  default null
  ,p_time_normal_finish           in     varchar2  default null
  ,p_time_normal_start            in     varchar2  default null
  ,p_bargaining_unit_code         in     varchar2  default null
  ,p_labour_union_member_flag     in     varchar2  default null
  ,p_hourly_salaried_code         in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
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
  ,p_object_version_number        in     number    default 1
  ,p_contract_id                  in     number    default null
  ,p_establishment_id             in     number    default null
  ,p_collective_agreement_id      in     number    default null
  ,p_cagr_grade_def_id            in     number    default null
  ,p_cagr_id_flex_num             in     number    default null
  ,p_notice_period                in     number    default null
  ,p_notice_period_uom            in     varchar2  default null
  ,p_employee_category            in     varchar2  default null
  ,p_work_at_home                 in     varchar2  default null
  ,p_job_post_source_name         in     varchar2  default null
  ,p_posting_content_id           in     number    default null
  ,p_placement_date_start         in     date      default null
  ,p_vendor_id                    in     number    default null
  ,p_vendor_employee_number       in     varchar2  default null
  ,p_vendor_assignment_number     in     varchar2  default null
  ,p_assignment_category          in     varchar2  default null
  ,p_project_title                in     varchar2  default null
  ,p_applicant_rank               in     number    default null
  ,p_grade_ladder_pgm_id          in     number    default null
  ,p_supervisor_assignment_id     in     number    default null
  ,p_vendor_site_id               in     number    default null
  ,p_po_header_id                 in     number    default null
  ,p_po_line_id                   in     number    default null
  ,p_projected_assignment_end     in     date      default null
  ,p_effective_date               in     date
  --
  -- pay proposal details
  --
  ,p_pay_proposal_id              in     number
  ,p_event_id                     in     number    default null
  ,p_change_date                  in     date      default null
  ,p_last_change_date             in     date      default null
  ,p_next_perf_review_date        in     date      default null
  ,p_next_sal_review_date         in     date      default null
  ,p_performance_rating           in     varchar2  default null
  ,p_proposal_reason              in     varchar2  default null
  ,p_proposed_salary              in     varchar2  default null
  ,p_review_date                  in     date      default null
  ,p_attribute_category           in     varchar2  default null
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
  ,p_pay_proposal_ovn             in     number    default null
  ,p_approved                     in     varchar2  default null
  ,p_multiple_components          in     varchar2  default null
  ,p_forced_ranking               in     number    default null
  ,p_performance_review_id        in     number    default null
  ,p_proposed_salary_n            in     number    default null
  ,p_comments                     in     long      default null
  --
  ,p_is_run_reqd                  out nocopy varchar2
  ,p_return_status                out nocopy varchar2
  );
--
-- Define global variables
--
  g_old_offer_assignment_record   per_all_assignments_f%rowtype;
  g_old_pay_proposal_record       per_pay_proposals%rowtype;
--

 --Save For Later Code Changes
-- ----------------------------------------------------------------------------
-- |-------------------------< process_offers_api >--------------------------|
-- ----------------------------------------------------------------------------

procedure process_offers_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);

-- ----------------------------------------------------------------------------
-- |-------------------------< process_asg_api >-----------------------------|
-- ----------------------------------------------------------------------------

procedure process_asg_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);

-- ----------------------------------------------------------------------------
-- |-------------------------< finalize_transaction >-------------------------|
-- ----------------------------------------------------------------------------

procedure finalize_transaction
(
 p_transaction_id       in         number
,p_event                in         varchar2
,p_return_status        out nocopy varchar2
);

-- ----------------------------------------------------------------------------
-- |-----------------------------< void_ben_records >-------------------------|
-- ----------------------------------------------------------------------------

procedure void_ben_records
( p_applicant_assignment_id   in  number default null
 ,p_offer_assignment_id       in  number default null
 ,p_status_code               in  varchar2 default null
 ,p_effective_date            in  date default trunc(sysdate)
 ,p_transaction_id            in  number default null
 ,p_void_single_per_in_ler    in  varchar2 default 'N'
);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenCommit >---------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenCommit(p_applicant_assignment_id in number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenRejected >-------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenRejected(p_applicant_assignment_id in number);

-- ---------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenEditing >--------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenEdit(p_applicant_assignment_id in number);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clear_global_data >-------------------------|
-- ----------------------------------------------------------------------------
procedure clear_global_data;
--
end irc_offers_swi;

/
