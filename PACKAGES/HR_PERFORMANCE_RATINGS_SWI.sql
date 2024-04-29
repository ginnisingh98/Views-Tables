--------------------------------------------------------
--  DDL for Package HR_PERFORMANCE_RATINGS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERFORMANCE_RATINGS_SWI" AUTHID CURRENT_USER As
/* $Header: peprtswi.pkh 120.1 2006/02/13 14:13:28 vbala noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_performance_rating >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_performance_ratings_api.create_performance_rating
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
PROCEDURE create_performance_rating
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_appraisal_id                 in     number
  ,p_person_id                    in     number    default null
  ,p_objective_id                 in     number
  ,p_performance_level_id         in     number    default null
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
  ,p_performance_rating_id        in	 number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_appr_line_score              in     number   default null
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_performance_rating >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_performance_ratings_api.delete_performance_rating
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
PROCEDURE delete_performance_rating
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_performance_rating_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_performance_rating >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_performance_ratings_api.update_performance_rating
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
PROCEDURE update_performance_rating
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_performance_rating_id        in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_appraisal_id                 in     number    default hr_api.g_number
  ,p_objective_id                 in     number    default hr_api.g_number
  ,p_performance_level_id         in     number    default hr_api.g_number
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
  ,p_return_status                   out nocopy varchar2
  ,p_appr_line_score              in     number    default hr_api.g_number
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
-- This procedure is responsible for commiting data from transaction
-- table (hr_api_transaction_step_id) to the base table.
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
end hr_performance_ratings_swi;

 

/
