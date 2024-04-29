--------------------------------------------------------
--  DDL for Package HR_ASSESSMENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENTS_SWI" AUTHID CURRENT_USER As
/* $Header: peasnswi.pkh 120.0 2005/05/31 05:50:24 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_assessment >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessments_api.create_assessment
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
PROCEDURE create_assessment
  (p_assessment_id                in    number
  ,p_assessment_type_id           in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_assessment_group_id          in     number    default null
  ,p_assessment_period_start_date in     date      default null
  ,p_assessment_period_end_date   in     date      default null
  ,p_assessment_date              in     date
  ,p_assessor_person_id           in     number
  ,p_appraisal_id                 in     number    default null
  ,p_group_date                   in     date      default null
  ,p_group_initiator_id           in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_total_score                  in     number    default null
  ,p_status                       in     varchar2  default null
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
  ,p_object_version_number           out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_assessment >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessments_api.delete_assessment
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
PROCEDURE delete_assessment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assessment_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_assessment >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_assessments_api.update_assessment
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
PROCEDURE update_assessment
  (p_assessment_id                in     number
  ,p_assessment_type_id           in     number    default hr_api.g_number
  ,p_assessment_group_id          in     number    default hr_api.g_number
  ,p_assessment_period_start_date in     date      default hr_api.g_date
  ,p_assessment_period_end_date   in     date      default hr_api.g_date
  ,p_assessment_date              in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_total_score                  in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
  ,p_object_version_number        in out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
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

end hr_assessments_swi;

 

/
