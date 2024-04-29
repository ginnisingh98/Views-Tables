--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_USAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_USAGE_SWI" AUTHID CURRENT_USER As
/* $Header: otrudswi.pkh 115.1 2003/12/30 19:04 asud noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_resource >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_usage_api.create_resource
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
PROCEDURE create_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number    default null
  ,p_required_flag                in     varchar2
  ,p_start_date                   in     date
  ,p_supplied_resource_id         in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_quantity                     in     number    default null
  ,p_resource_type                in     varchar2  default null
  ,p_role_to_play                 in     varchar2  default null
  ,p_usage_reason                 in     varchar2  default null
  ,p_rud_information_category     in     varchar2  default null
  ,p_rud_information1             in     varchar2  default null
  ,p_rud_information2             in     varchar2  default null
  ,p_rud_information3             in     varchar2  default null
  ,p_rud_information4             in     varchar2  default null
  ,p_rud_information5             in     varchar2  default null
  ,p_rud_information6             in     varchar2  default null
  ,p_rud_information7             in     varchar2  default null
  ,p_rud_information8             in     varchar2  default null
  ,p_rud_information9             in     varchar2  default null
  ,p_rud_information10            in     varchar2  default null
  ,p_rud_information11            in     varchar2  default null
  ,p_rud_information12            in     varchar2  default null
  ,p_rud_information13            in     varchar2  default null
  ,p_rud_information14            in     varchar2  default null
  ,p_rud_information15            in     varchar2  default null
  ,p_rud_information16            in     varchar2  default null
  ,p_rud_information17            in     varchar2  default null
  ,p_rud_information18            in     varchar2  default null
  ,p_rud_information19            in     varchar2  default null
  ,p_rud_information20            in     varchar2  default null
  ,p_resource_usage_id            in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_offering_id                  in     number    default null
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_resource >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_usage_api.delete_resource
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
PROCEDURE delete_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_resource >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_resource_usage_api.update_resource
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
PROCEDURE update_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_resource_type                in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_usage_reason                 in     varchar2  default hr_api.g_varchar2
  ,p_rud_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_rud_information1             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information2             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information3             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information4             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information5             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information6             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information7             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information8             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information9             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information10            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information11            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information12            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information13            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information14            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information15            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information16            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information17            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information18            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information19            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information20            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_offering_id                  in     number    default hr_api.g_number
  );
end ota_resource_usage_swi;

 

/
