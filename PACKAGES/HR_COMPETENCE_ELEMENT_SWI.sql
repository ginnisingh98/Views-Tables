--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_SWI" AUTHID CURRENT_USER As
/* $Header: hrcelswi.pkh 120.3.12010000.1 2008/07/28 03:07:26 appldev ship $ */

g_session_id number;
g_competence_element_id number;

-- ----------------------------------------------------------------------------
-- |---------------------------< copy_competencies >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.copy_competencies
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
PROCEDURE copy_competencies
  (p_activity_version_from        in     number
  ,p_activity_version_to          in     number
  ,p_competence_type              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_competence_element >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.create_competence_element
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
PROCEDURE create_competence_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_element_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_type                         in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_enterprise_id                in     number    default null
  ,p_competence_id                in     number    default null
  ,p_proficiency_level_id         in     number    default null
  ,p_high_proficiency_level_id    in     number    default null
  ,p_weighting_level_id           in     number    default null
  ,p_rating_level_id              in     number    default null
  ,p_person_id                    in     number    default null
  ,p_job_id                       in     number    default null
  ,p_valid_grade_id               in     number    default null
  ,p_position_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_parent_competence_element_id in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_assessment_id                in     number    default null
  ,p_assessment_type_id           in     number    default null
  ,p_mandatory                    in     varchar2  default null
  ,p_effective_date_from          in     date      default null
  ,p_effective_date_to            in     date      default null
  ,p_group_competence_type        in     varchar2  default null
  ,p_competence_type              in     varchar2  default null
  ,p_normal_elapse_duration       in     number    default null
  ,p_normal_elapse_duration_unit  in     varchar2  default null
  ,p_sequence_number              in     number    default null
  ,p_source_of_proficiency_level  in     varchar2  default null
  ,p_line_score                   in     number    default null
  ,p_certification_date           in     date      default null
  ,p_certification_method         in     varchar2  default null
  ,p_next_certification_date      in     date      default null
  ,p_comments                     in     varchar2  default null
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
  ,p_effective_date               in     date
  ,p_object_id                    in     number    default null
  ,p_object_name                  in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_return_status                out nocopy varchar2
  ,p_appr_line_score              in    number     default null
  ,p_status                       in varchar2      default null
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_competence_element >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.delete_competence_element
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
PROCEDURE delete_competence_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_element_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< maintain_student_comp_element >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.maintain_student_comp_element
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
PROCEDURE maintain_student_comp_element
  (p_person_id                    in     number
  ,p_competence_id                in     number
  ,p_proficiency_level_id         in     number
  ,p_business_group_id            in     number
  ,p_effective_date_from          in     date
  ,p_effective_date_to            in     date
  ,p_certification_date           in     date
  ,p_certification_method         in     varchar2
  ,p_next_certification_date      in     date
  ,p_source_of_proficiency_level  in     varchar2
  ,p_comments                     in     varchar2
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_competence_created              out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_competence_element >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.update_competence_element
--
--   We allow competence_id to be updated in this call by calling delete then
--   insert internally
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
PROCEDURE update_competence_element
  (p_competence_element_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_competence_id                in     number    default hr_api.g_number
  ,p_proficiency_level_id         in     number    default hr_api.g_number
  ,p_high_proficiency_level_id    in     number    default hr_api.g_number
  ,p_weighting_level_id           in     number    default hr_api.g_number
  ,p_rating_level_id              in     number    default hr_api.g_number
  ,p_mandatory                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_date_from          in     date      default hr_api.g_date
  ,p_effective_date_to            in     date      default hr_api.g_date
  ,p_group_competence_type        in     varchar2  default hr_api.g_varchar2
  ,p_competence_type              in     varchar2  default hr_api.g_varchar2
  ,p_normal_elapse_duration       in     number    default hr_api.g_number
  ,p_normal_elapse_duration_unit  in     varchar2  default hr_api.g_varchar2
  ,p_sequence_number              in     number    default hr_api.g_number
  ,p_source_of_proficiency_level  in     varchar2  default hr_api.g_varchar2
  ,p_line_score                   in     number    default hr_api.g_number
  ,p_certification_date           in     date      default hr_api.g_date
  ,p_certification_method         in     varchar2  default hr_api.g_varchar2
  ,p_next_certification_date      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_party_id                     in     number
  ,p_return_status                out    nocopy varchar2
  ,p_datetrack_update_mode        in      varchar2 default hr_api.g_correction
  ,p_appr_line_score              in     number    default hr_api.g_number
  ,p_status                       in varchar2      default null
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_delivered_dates >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.update_delivered_dates
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
PROCEDURE update_delivered_dates
  (p_activity_version_id          in     number
  ,p_old_start_date               in     date
  ,p_start_date                   in     date
  ,p_old_end_date                 in     date
  ,p_end_date                     in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_personal_comp_element >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_competence_element_api.update_personal_comp_element
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
PROCEDURE update_personal_comp_element
  (p_competence_element_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_proficiency_level_id         in     number    default hr_api.g_number
  ,p_effective_date_from          in     date      default hr_api.g_date
  ,p_effective_date_to            in     date      default hr_api.g_date
  ,p_source_of_proficiency_level  in     varchar2  default hr_api.g_varchar2
  ,p_certification_date           in     date      default hr_api.g_date
  ,p_certification_method         in     varchar2  default hr_api.g_varchar2
  ,p_next_certification_date      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
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
  ,p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_ins_ovn                         out nocopy number
  ,p_ins_comp_id                     out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
-- This procedure is responsible for commiting data from transaction
-- table (hr_api_transaction_step_id) to the base table
--
-- Parameters:
-- p_document is the document having the data that needs to be committed
-- p_return_status is the return status after committing the date. In case of
-- any errors/warnings the p_return_status is populated with 'E' or 'W'
-- p_validate is the flag to indicate whether to rollback data or not
-- p_effective_date is the current effective date
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document                in           CLOB
 ,p_return_status           out  nocopy  VARCHAR2
 ,p_validate                in           number    default hr_api.g_false_num
 ,p_effective_date          in           date      default null
);



end hr_competence_element_swi;

/
