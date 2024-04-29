--------------------------------------------------------
--  DDL for Package HR_APPRAISALS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISALS_SWI" AUTHID CURRENT_USER As
/* $Header: peaprswi.pkh 120.1.12010000.3 2009/08/12 14:15:53 rvagvala ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisals_api.create_appraisal
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
PROCEDURE create_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_appraisal_template_id        in     number
  ,p_appraisee_person_id          in     number
  ,p_appraiser_person_id          in     number
  ,p_appraisal_date               in     date      default null
  ,p_appraisal_period_start_date  in     date
  ,p_appraisal_period_end_date    in     date
  ,p_type                         in     varchar2  default null
  ,p_next_appraisal_date          in     date      default null
  ,p_status                       in     varchar2  default null
  ,p_group_date                   in     date      default null
  ,p_group_initiator_id           in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_overall_performance_level_id in     number    default null
  ,p_open                         in     varchar2  default null
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
  ,p_system_type                  in     varchar2  default null
  ,p_system_params                in     varchar2  default null
  ,p_appraisee_access             in     varchar2  default null
  ,p_main_appraiser_id            in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_assignment_start_date        in     date      default null
  ,p_asg_business_group_id        in     number    default null
  ,p_assignment_organization_id   in     number    default null
  ,p_assignment_job_id            in     number    default null
  ,p_assignment_position_id       in     number    default null
  ,p_assignment_grade_id          in     number    default null
  ,p_appraisal_id                 in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_appraisal_system_status	  in 	varchar2 default null
  ,p_potential_readiness_level    in 	varchar2        default null
  ,p_potential_short_term_workopp in 	varchar2        default null
  ,p_potential_long_term_workopp  in 	varchar2        default null
  ,p_potential_details            in 	varchar2        default null
  ,p_event_id                     in 	number          default null
  ,p_show_competency_ratings      in varchar2           default null
  ,p_show_objective_ratings       in varchar2           default null
  ,p_show_questionnaire_info      in varchar2           default null
  ,p_show_participant_details     in varchar2           default null
  ,p_show_participant_ratings     in varchar2           default null
  ,p_show_participant_names       in varchar2           default null
  ,p_show_overall_ratings         in varchar2           default null
  ,p_show_overall_comments        in varchar2           default null
  ,p_update_appraisal             in varchar2           default null
  ,p_provide_overall_feedback     in varchar2           default null
  ,p_appraisee_comments           in varchar2           default null
  ,p_offline_status               in varchar2           default null
,p_retention_potential          in varchar2           default null
,p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisals_api.delete_appraisal
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
PROCEDURE delete_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_appraisal_id                 in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisals_api.update_appraisal
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
PROCEDURE update_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_appraisal_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_appraiser_person_id          in     number    default hr_api.g_number
  ,p_appraisal_date               in     date      default hr_api.g_date
  ,p_appraisal_period_end_date    in     date      default hr_api.g_date
  ,p_appraisal_period_start_date  in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_next_appraisal_date          in     date      default hr_api.g_date
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_overall_performance_level_id in     number    default hr_api.g_number
  ,p_open                         in     varchar2  default hr_api.g_varchar2
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
  ,p_system_type                  in     varchar2  default hr_api.g_varchar2
  ,p_system_params                in     varchar2  default hr_api.g_varchar2
  ,p_appraisee_access             in     varchar2  default hr_api.g_varchar2
  ,p_main_appraiser_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_start_date        in     date      default hr_api.g_date
  ,p_asg_business_group_id        in     number    default hr_api.g_number
  ,p_assignment_organization_id   in     number    default hr_api.g_number
  ,p_assignment_job_id            in     number    default hr_api.g_number
  ,p_assignment_position_id       in     number    default hr_api.g_number
  ,p_assignment_grade_id          in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ,p_appraisal_system_status      in     varchar2  default hr_api.g_varchar2
  ,p_potential_readiness_level    in     varchar2  default hr_api.g_varchar2
  ,p_potential_short_term_workopp in     varchar2  default hr_api.g_varchar2
  ,p_potential_long_term_workopp  in     varchar2  default hr_api.g_varchar2
  ,p_potential_details            in     varchar2  default hr_api.g_varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_show_competency_ratings      in     varchar2  default hr_api.g_varchar2
  ,p_show_objective_ratings       in     varchar2  default hr_api.g_varchar2
  ,p_show_questionnaire_info      in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_details     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_ratings     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_names       in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_ratings         in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_comments        in     varchar2  default hr_api.g_varchar2
  ,p_update_appraisal             in     varchar2  default hr_api.g_varchar2
  ,p_provide_overall_feedback     in     varchar2  default hr_api.g_varchar2
  ,p_appraisee_comments           in     varchar2  default hr_api.g_varchar2
  ,p_offline_status               in     varchar2  default hr_api.g_varchar2
 ,p_retention_potential                in varchar2         default hr_api.g_varchar2
,p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix

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
end hr_appraisals_swi;

/
