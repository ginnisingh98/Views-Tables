--------------------------------------------------------
--  DDL for Package OTA_ACTIVITY_CATEGORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACTIVITY_CATEGORY_SWI" AUTHID CURRENT_USER As
/* $Header: otaciswi.pkh 115.1 2003/12/30 17:45:04 dhmulia noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_aci_api.create_act_cat_inclusion
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
PROCEDURE create_act_cat_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_category            in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_aci_information_category     in     varchar2  default null
  ,p_aci_information1             in     varchar2  default null
  ,p_aci_information2             in     varchar2  default null
  ,p_aci_information3             in     varchar2  default null
  ,p_aci_information4             in     varchar2  default null
  ,p_aci_information5             in     varchar2  default null
  ,p_aci_information6             in     varchar2  default null
  ,p_aci_information7             in     varchar2  default null
  ,p_aci_information8             in     varchar2  default null
  ,p_aci_information9             in     varchar2  default null
  ,p_aci_information10            in     varchar2  default null
  ,p_aci_information11            in     varchar2  default null
  ,p_aci_information12            in     varchar2  default null
  ,p_aci_information13            in     varchar2  default null
  ,p_aci_information14            in     varchar2  default null
  ,p_aci_information15            in     varchar2  default null
  ,p_aci_information16            in     varchar2  default null
  ,p_aci_information17            in     varchar2  default null
  ,p_aci_information18            in     varchar2  default null
  ,p_aci_information19            in     varchar2  default null
  ,p_aci_information20            in     varchar2  default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_primary_flag                 in     varchar2  default null
  ,p_category_usage_id            in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_aci_api.delete_act_cat_inclusion
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
PROCEDURE delete_act_cat_inclusion
  (p_activity_version_id          in     number
  ,p_category_usage_id            in     varchar2
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_aci_api.update_act_cat_inclusion
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
PROCEDURE update_act_cat_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_category            in     varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_aci_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_aci_information1             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information2             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information3             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information4             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information5             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information6             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information7             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information8             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information9             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information10            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information11            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information12            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information13            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information14            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information15            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information16            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information17            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information18            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information19            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information20            in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_category_usage_id            in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< validate_delete_aci >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service procedure to validate the row being
--  deleted.Called before ota_aci_api.delete_act_cat_inclusion
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
  PROCEDURE validate_delete_aci
  (p_activity_version_id          in     number
  ,p_category_usage_id          in     number
  ,p_return_status                   out nocopy varchar2
  );
end ota_activity_category_swi;

 

/
