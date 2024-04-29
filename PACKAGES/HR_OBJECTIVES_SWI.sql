--------------------------------------------------------
--  DDL for Package HR_OBJECTIVES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVES_SWI" AUTHID CURRENT_USER As
/* $Header: peobjswi.pkh 120.3 2006/03/20 14:31:16 svittal noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_objective >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objectives_api.create_objective
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
PROCEDURE create_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_owning_person_id             in     number
  ,p_target_date                  in     date      default null
  ,p_achievement_date             in     date      default null
  ,p_detail                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_success_criteria             in     varchar2  default null
  ,p_appraisal_id                 in     number    default null
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
  ,p_scorecard_id                 in     number    default null
  ,p_copied_from_library_id       in     number    default null
  ,p_copied_from_objective_id     in     number    default null
  ,p_aligned_with_objective_id    in     number    default null
  ,p_next_review_date             in     date      default null
  ,p_group_code                   in     varchar2  default null
  ,p_priority_code                in     varchar2  default null
  ,p_appraise_flag                in     varchar2  default null
  ,p_verified_flag                in     varchar2  default null
  ,p_target_value                 in     number    default null
  ,p_actual_value                 in     number    default null
  ,p_weighting_percent            in     number    default null
  ,p_complete_percent             in     number    default null
  ,p_uom_code                     in     varchar2  default null
  ,p_measurement_style_code       in     varchar2  default null
  ,p_measure_name                 in     varchar2  default null
  ,p_measure_type_code            in     varchar2  default null
  ,p_measure_comments             in     varchar2  default null
  ,p_sharing_access_code          in     varchar2  default null

  ,p_objective_id                 in	 number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_objective >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objectives_api.delete_objective
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
PROCEDURE delete_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_objective_id                 in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_objective >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objectives_api.update_objective
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
PROCEDURE update_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_target_date                  in     date      default hr_api.g_date
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_achievement_date             in     date      default hr_api.g_date
  ,p_detail                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
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
  ,p_scorecard_id                 in     number    default hr_api.g_number
  ,p_copied_from_library_id       in     number    default hr_api.g_number
  ,p_copied_from_objective_id     in     number    default hr_api.g_number
  ,p_aligned_with_objective_id    in     number    default hr_api.g_number
  ,p_next_review_date             in     date      default hr_api.g_date
  ,p_group_code                   in     varchar2  default hr_api.g_varchar2
  ,p_priority_code                in     varchar2  default hr_api.g_varchar2
  ,p_appraise_flag                in     varchar2  default hr_api.g_varchar2
  ,p_verified_flag                in     varchar2  default hr_api.g_varchar2
  ,p_target_value                 in     number    default hr_api.g_number
  ,p_actual_value                 in     number    default hr_api.g_number
  ,p_weighting_percent            in     number    default hr_api.g_number
  ,p_complete_percent             in     number    default hr_api.g_number
  ,p_uom_code                     in     varchar2  default hr_api.g_varchar2
  ,p_measurement_style_code       in     varchar2  default hr_api.g_varchar2
  ,p_measure_name                 in     varchar2  default hr_api.g_varchar2
  ,p_measure_type_code            in     varchar2  default hr_api.g_varchar2
  ,p_measure_comments             in     varchar2  default hr_api.g_varchar2
  ,p_sharing_access_code          in     varchar2  default hr_api.g_varchar2
  ,p_appraisal_id                 in     number    default hr_api.g_number
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
--
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

end hr_objectives_swi;

 

/
