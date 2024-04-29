--------------------------------------------------------
--  DDL for Package OTA_COURSE_PREREQUISITE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COURSE_PREREQUISITE_SWI" AUTHID CURRENT_USER As
/* $Header: otcprswi.pkh 120.0 2005/05/29 07:08 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_course_prerequisite >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_course_prerequisite_api.create_course_prerequisite
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
PROCEDURE create_course_prerequisite
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_prerequisite_course_id       in     number
  ,p_business_group_id            in     number
  ,p_prerequisite_type            in     varchar2
  ,p_enforcement_mode             in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_course_prerequisite >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_course_prerequisite_api.update_course_prerequisite
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
PROCEDURE update_course_prerequisite
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_prerequisite_course_id       in     number
  ,p_business_group_id            in     number
  ,p_prerequisite_type            in     varchar2
  ,p_enforcement_mode             in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_course_prerequisite >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_course_prerequisite_api.delete_course_prerequisite
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
PROCEDURE delete_course_prerequisite
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_activity_version_id          in     number
  ,p_prerequisite_course_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end ota_course_prerequisite_swi;

 

/
