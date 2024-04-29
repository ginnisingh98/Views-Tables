--------------------------------------------------------
--  DDL for Package OTA_BOOKING_STATUS_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BOOKING_STATUS_TYPE_SWI" AUTHID CURRENT_USER As
/* $Header: otbstswi.pkh 120.0 2005/05/29 07:05 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_booking_status_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_booking_status_type_api.create_booking_status_type
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
PROCEDURE create_booking_status_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_active_flag                  in     varchar2  default null
  ,p_default_flag                 in     varchar2  default null
  ,p_name                         in     varchar2  default null
  ,p_type                         in     varchar2  default null
  ,p_place_used_flag              in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_bst_information_category     in     varchar2  default null
  ,p_bst_information1             in     varchar2  default null
  ,p_bst_information2             in     varchar2  default null
  ,p_bst_information3             in     varchar2  default null
  ,p_bst_information4             in     varchar2  default null
  ,p_bst_information5             in     varchar2  default null
  ,p_bst_information6             in     varchar2  default null
  ,p_bst_information7             in     varchar2  default null
  ,p_bst_information8             in     varchar2  default null
  ,p_bst_information9             in     varchar2  default null
  ,p_bst_information10            in     varchar2  default null
  ,p_bst_information11            in     varchar2  default null
  ,p_bst_information12            in     varchar2  default null
  ,p_bst_information13            in     varchar2  default null
  ,p_bst_information14            in     varchar2  default null
  ,p_bst_information15            in     varchar2  default null
  ,p_bst_information16            in     varchar2  default null
  ,p_bst_information17            in     varchar2  default null
  ,p_bst_information18            in     varchar2  default null
  ,p_bst_information19            in     varchar2  default null
  ,p_bst_information20            in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_booking_status_type_id       in     number
--  ,p_data_source                  in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) ;
-- ----------------------------------------------------------------------------
-- |----------------------< update_booking_status_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_booking_status_type_api.update_booking_status_type
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
PROCEDURE update_booking_status_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_active_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_default_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_place_used_flag              in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_bst_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_bst_information1             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information2             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information3             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information4             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information5             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information6             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information7             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information8             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information9             in     varchar2  default hr_api.g_varchar2
  ,p_bst_information10            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information11            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information12            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information13            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information14            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information15            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information16            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information17            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information18            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information19            in     varchar2  default hr_api.g_varchar2
  ,p_bst_information20            in     varchar2  default hr_api.g_varchar2
  ,p_booking_status_type_id       in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
--  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) ;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_booking_status_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_booking_status_type_api.delete_booking_status_type
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
PROCEDURE delete_booking_status_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_booking_status_type_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) ;
 end ota_booking_status_type_swi;

 

/
