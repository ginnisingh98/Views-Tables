--------------------------------------------------------
--  DDL for Package OTA_CERTIFICATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERTIFICATION_SWI" AUTHID CURRENT_USER As
/* $Header: otcrtswi.pkh 120.1 2005/06/14 15:13 estreacy noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_certification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_certification_api.create_certification
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
PROCEDURE create_certification
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_name                         in     varchar2
  ,p_business_group_id            in     number
  ,p_public_flag                  in     varchar2  default null
  ,p_initial_completion_date      in     date      default null
  ,p_initial_completion_duration  in     number    default null
  ,p_initial_compl_duration_units in     varchar2  default null
  ,p_renewal_duration             in     number    default null
  ,p_renewal_duration_units       in     varchar2  default null
  ,p_notify_days_before_expire    in     number    default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_objectives                   in     varchar2  default null
  ,p_purpose                      in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_end_date_comments            in     varchar2  default null
  ,p_initial_period_comments      in     varchar2  default null
  ,p_renewal_period_comments      in     varchar2  default null
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
  ,p_VALIDITY_DURATION            in     NUMBER   default null
  ,p_VALIDITY_DURATION_UNITS      in     VARCHAR2 default null
  ,p_RENEWABLE_FLAG               in     VARCHAR2 default null
  ,p_VALIDITY_START_TYPE          in     VARCHAR2 default null
  ,p_COMPETENCY_UPDATE_LEVEL      in     VARCHAR2 default null
  ,p_certification_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_certification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_certification_api.update_certification
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
PROCEDURE update_certification
  (p_effective_date               in     date
  ,p_certification_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_public_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_initial_completion_date      in     date      default hr_api.g_date
  ,p_initial_completion_duration  in     number    default hr_api.g_number
  ,p_initial_compl_duration_units in     varchar2  default hr_api.g_varchar2
  ,p_renewal_duration             in     number    default hr_api.g_number
  ,p_renewal_duration_units       in     varchar2  default hr_api.g_varchar2
  ,p_notify_days_before_expire    in     number    default hr_api.g_number
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_purpose                      in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date_comments            in     varchar2  default hr_api.g_varchar2
  ,p_initial_period_comments      in     varchar2  default hr_api.g_varchar2
  ,p_renewal_period_comments      in     varchar2  default hr_api.g_varchar2
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
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_VALIDITY_DURATION            in     NUMBER    default hr_api.g_number
  ,p_VALIDITY_DURATION_UNITS      in     VARCHAR2  default hr_api.g_varchar2
  ,p_RENEWABLE_FLAG               in     VARCHAR2  default hr_api.g_varchar2
  ,p_VALIDITY_START_TYPE          in     VARCHAR2  default hr_api.g_varchar2
  ,p_COMPETENCY_UPDATE_LEVEL      in     VARCHAR2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_certification >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_certification_api.delete_certification
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
PROCEDURE delete_certification
  (p_certification_id             in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );

FUNCTION check_crt_enrollments_exist
(p_certification_id              in     number
) return varchar2;

PROCEDURE check_duplicate_name
( p_name              IN VARCHAR2
 ,p_certification_id  IN NUMBER
 ,p_business_group_id IN NUMBER
);
 end ota_certification_swi;

 

/
