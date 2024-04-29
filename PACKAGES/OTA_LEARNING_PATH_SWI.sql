--------------------------------------------------------
--  DDL for Package OTA_LEARNING_PATH_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNING_PATH_SWI" AUTHID CURRENT_USER As
/* $Header: otlpsswi.pkh 120.0 2005/05/29 07:24:28 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_learning_path_api.create_learning_path
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
PROCEDURE create_learning_path
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_path_name                    in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_objectives                   in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_purpose                      in     varchar2  default null
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
  ,p_path_source_code             in     varchar2  default null
  ,p_source_function_code         in     varchar2  default null
  ,p_assignment_id                in     number    default null
  ,p_source_id                    in     number    default null
  ,p_notify_days_before_target    in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_display_to_learner_flag      in     varchar2  default null
  ,p_public_flag                  in     varchar2  default null
,p_competency_update_level        in     varchar2  default null
  ,p_learning_path_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_learning_path_api.delete_learning_path
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
PROCEDURE delete_learning_path
  (p_learning_path_id             in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_learning_path >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_learning_path_api.update_learning_path
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
PROCEDURE update_learning_path
  (p_effective_date               in     date
  ,p_learning_path_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_path_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_purpose                      in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
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
  ,p_path_source_code             in     varchar2  default hr_api.g_varchar2
  ,p_source_function_code         in     varchar2  default hr_api.g_varchar2
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_source_id                    in     number    default hr_api.g_number
  ,p_notify_days_before_target    in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_display_to_learner_flag      in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );


-- ----------------------------------------------------------------------------
-- |-------------------------< check_lp_enrollments_exist >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This function checks whether enrollments exist for the given Learning Path
--
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
FUNCTION check_lp_enrollments_exist
  (p_learning_path_id             in     number
  ) return varchar2 ;


PROCEDURE check_duplicate_name
( p_name             IN VARCHAR2
 ,p_learning_path_id IN NUMBER
 ,p_business_group_id IN NUMBER
 ,p_person_id         IN NUMBER
 ,p_contact_id        IN NUMBER
 ,p_path_source_code  IN VARCHAR2
 );

 FUNCTION is_Duration_updateable
  ( p_learning_path_id IN NUMBER
  ) return varchar2;

end ota_learning_path_swi;

 

/
