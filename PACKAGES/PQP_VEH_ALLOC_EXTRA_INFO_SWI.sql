--------------------------------------------------------
--  DDL for Package PQP_VEH_ALLOC_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEH_ALLOC_EXTRA_INFO_SWI" AUTHID CURRENT_USER As
/* $Header: pqvaiswi.pkh 120.0 2005/05/29 02:16 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_veh_alloc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_alloc_extra_info_api.create_veh_alloc_extra_info
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
PROCEDURE create_veh_alloc_extra_info
  (
   p_validate                     in     number    default hr_api.g_false_num
  ,p_vehicle_allocation_id        in     number
  ,p_information_type             in     varchar2
  ,p_vaei_attribute_category      in     varchar2  default null
  ,p_vaei_attribute1              in     varchar2  default null
  ,p_vaei_attribute2              in     varchar2  default null
  ,p_vaei_attribute3              in     varchar2  default null
  ,p_vaei_attribute4              in     varchar2  default null
  ,p_vaei_attribute5              in     varchar2  default null
  ,p_vaei_attribute6              in     varchar2  default null
  ,p_vaei_attribute7              in     varchar2  default null
  ,p_vaei_attribute8              in     varchar2  default null
  ,p_vaei_attribute9              in     varchar2  default null
  ,p_vaei_attribute10             in     varchar2  default null
  ,p_vaei_attribute11             in     varchar2  default null
  ,p_vaei_attribute12             in     varchar2  default null
  ,p_vaei_attribute13             in     varchar2  default null
  ,p_vaei_attribute14             in     varchar2  default null
  ,p_vaei_attribute15             in     varchar2  default null
  ,p_vaei_attribute16             in     varchar2  default null
  ,p_vaei_attribute17             in     varchar2  default null
  ,p_vaei_attribute18             in     varchar2  default null
  ,p_vaei_attribute19             in     varchar2  default null
  ,p_vaei_attribute20             in     varchar2  default null
  ,p_vaei_information_category    in     varchar2  default null
  ,p_vaei_information1            in     varchar2  default null
  ,p_vaei_information2            in     varchar2  default null
  ,p_vaei_information3            in     varchar2  default null
  ,p_vaei_information4            in     varchar2  default null
  ,p_vaei_information5            in     varchar2  default null
  ,p_vaei_information6            in     varchar2  default null
  ,p_vaei_information7            in     varchar2  default null
  ,p_vaei_information8            in     varchar2  default null
  ,p_vaei_information9            in     varchar2  default null
  ,p_vaei_information10           in     varchar2  default null
  ,p_vaei_information11           in     varchar2  default null
  ,p_vaei_information12           in     varchar2  default null
  ,p_vaei_information13           in     varchar2  default null
  ,p_vaei_information14           in     varchar2  default null
  ,p_vaei_information15           in     varchar2  default null
  ,p_vaei_information16           in     varchar2  default null
  ,p_vaei_information17           in     varchar2  default null
  ,p_vaei_information18           in     varchar2  default null
  ,p_vaei_information19           in     varchar2  default null
  ,p_vaei_information20           in     varchar2  default null
  ,p_vaei_information21           in     varchar2  default null
  ,p_vaei_information22           in     varchar2  default null
  ,p_vaei_information23           in     varchar2  default null
  ,p_vaei_information24           in     varchar2  default null
  ,p_vaei_information25           in     varchar2  default null
  ,p_vaei_information26           in     varchar2  default null
  ,p_vaei_information27           in     varchar2  default null
  ,p_vaei_information28           in     varchar2  default null
  ,p_vaei_information29           in     varchar2  default null
  ,p_vaei_information30           in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_veh_alloc_extra_info_id      in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_veh_alloc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_alloc_extra_info_api.update_veh_alloc_extra_info
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
PROCEDURE update_veh_alloc_extra_info
  (
  p_validate                     in     number    default hr_api.g_false_num
  ,p_veh_alloc_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_allocation_id        in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information1            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information2            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information3            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information4            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information5            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information6            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information7            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information8            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information9            in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information10           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information11           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information12           in     varchar2  default hr_api.g_varchar2
   ,p_vaei_information13           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information14           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information15           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information16           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information17           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information18           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information19           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information20           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information21           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information22           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information23           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information24           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information25           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information26           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information27           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information28           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information29           in     varchar2  default hr_api.g_varchar2
  ,p_vaei_information30           in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_veh_alloc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_alloc_extra_info_api.delete_veh_alloc_extra_info
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
PROCEDURE delete_veh_alloc_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_veh_alloc_extra_info_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end pqp_veh_alloc_extra_info_swi;

 

/
