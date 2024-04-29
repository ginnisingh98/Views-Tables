--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_TYPES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_TYPES_SWI" AUTHID CURRENT_USER As
/* $Header: peastswi.pkh 120.0 2006/02/09 08:04 sansingh noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessment_types_api.create_assessment_type
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
PROCEDURE create_assessment_type
  (p_assessment_type_id          in     number
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_description                  in     varchar2  default null
  ,p_rating_scale_id              in     number    default null
  ,p_weighting_scale_id           in     number    default null
  ,p_rating_scale_comment         in     varchar2  default null
  ,p_weighting_scale_comment      in     varchar2  default null
  ,p_assessment_classification    in     varchar2
  ,p_display_assessment_comments  in     varchar2  default null
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_comments                     in     varchar2  default null
  ,p_instructions                 in     varchar2  default null
  ,p_weighting_classification     in     varchar2  default null
  ,p_line_score_formula           in     varchar2  default null
  ,p_total_score_formula          in     varchar2  default null
  ,p_object_version_number           out nocopy number
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
  ,p_type                         in     varchar2
  ,p_line_score_formula_id        in     number    default null
  ,p_default_job_competencies     in     varchar2  default null
  ,p_available_flag               in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessment_types_api.delete_assessment_type
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
PROCEDURE delete_assessment_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assessment_type_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_assessment_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessment_types_api.update_assessment_type
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
PROCEDURE update_assessment_type
  (p_assessment_type_id           in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_rating_scale_id              in     number    default hr_api.g_number
  ,p_weighting_scale_id           in     number    default hr_api.g_number
  ,p_rating_scale_comment         in     varchar2  default hr_api.g_varchar2
  ,p_weighting_scale_comment      in     varchar2  default hr_api.g_varchar2
  ,p_assessment_classification    in     varchar2  default hr_api.g_varchar2
  ,p_display_assessment_comments  in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_instructions                 in     varchar2  default hr_api.g_varchar2
  ,p_weighting_classification     in     varchar2  default hr_api.g_varchar2
  ,p_line_score_formula           in     varchar2  default hr_api.g_varchar2
  ,p_total_score_formula          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
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
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_line_score_formula_id        in     number    default hr_api.g_number
  ,p_default_job_competencies     in     varchar2  default hr_api.g_varchar2
  ,p_available_flag               in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
 end hr_assessment_types_swi;

 

/
