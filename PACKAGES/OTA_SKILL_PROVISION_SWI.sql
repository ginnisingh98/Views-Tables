--------------------------------------------------------
--  DDL for Package OTA_SKILL_PROVISION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SKILL_PROVISION_SWI" AUTHID CURRENT_USER As
/* $Header: ottspswi.pkh 115.0 2003/12/31 00:48 arkashya noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tsp_api.create_skill_provision
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
PROCEDURE create_skill_provision
  (p_skill_provision_id           in     number
  ,p_activity_version_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_type                         in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_tsp_information_category     in     varchar2  default null
  ,p_tsp_information1             in     varchar2  default null
  ,p_tsp_information2             in     varchar2  default null
  ,p_tsp_information3             in     varchar2  default null
  ,p_tsp_information4             in     varchar2  default null
  ,p_tsp_information5             in     varchar2  default null
  ,p_tsp_information6             in     varchar2  default null
  ,p_tsp_information7             in     varchar2  default null
  ,p_tsp_information8             in     varchar2  default null
  ,p_tsp_information9             in     varchar2  default null
  ,p_tsp_information10            in     varchar2  default null
  ,p_tsp_information11            in     varchar2  default null
  ,p_tsp_information12            in     varchar2  default null
  ,p_tsp_information13            in     varchar2  default null
  ,p_tsp_information14            in     varchar2  default null
  ,p_tsp_information15            in     varchar2  default null
  ,p_tsp_information16            in     varchar2  default null
  ,p_tsp_information17            in     varchar2  default null
  ,p_tsp_information18            in     varchar2  default null
  ,p_tsp_information19            in     varchar2  default null
  ,p_tsp_information20            in     varchar2  default null
  ,p_analysis_criteria_id         in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tsp_api.delete_skill_provision
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
PROCEDURE delete_skill_provision
  (p_skill_provision_id           in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tsp_api.update_skill_provision
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
PROCEDURE update_skill_provision
  (p_skill_provision_id           in     number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information20            in     varchar2  default hr_api.g_varchar2
  ,p_analysis_criteria_id         in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
end ota_skill_provision_swi;

 

/
