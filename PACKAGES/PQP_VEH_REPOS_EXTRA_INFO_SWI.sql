--------------------------------------------------------
--  DDL for Package PQP_VEH_REPOS_EXTRA_INFO_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEH_REPOS_EXTRA_INFO_SWI" AUTHID CURRENT_USER As
/* $Header: pqvriswi.pkh 120.0 2005/05/29 02:19 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_repos_extra_info_api.create_veh_repos_extra_info
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
PROCEDURE create_veh_repos_extra_info
  (
   p_validate                     in     number    default hr_api.g_false_num
  ,p_vehicle_repository_id        in     number
  ,p_information_type             in     varchar2
  ,p_vrei_attribute_category      in     varchar2  default null
  ,p_vrei_attribute1              in     varchar2  default null
  ,p_vrei_attribute2              in     varchar2  default null
  ,p_vrei_attribute3              in     varchar2  default null
  ,p_vrei_attribute4              in     varchar2  default null
  ,p_vrei_attribute5              in     varchar2  default null
  ,p_vrei_attribute6              in     varchar2  default null
  ,p_vrei_attribute7              in     varchar2  default null
  ,p_vrei_attribute8              in     varchar2  default null
  ,p_vrei_attribute9              in     varchar2  default null
  ,p_vrei_attribute10             in     varchar2  default null
  ,p_vrei_attribute11             in     varchar2  default null
  ,p_vrei_attribute12             in     varchar2  default null
  ,p_vrei_attribute13             in     varchar2  default null
  ,p_vrei_attribute14             in     varchar2  default null
  ,p_vrei_attribute15             in     varchar2  default null
  ,p_vrei_attribute16             in     varchar2  default null
  ,p_vrei_attribute17             in     varchar2  default null
  ,p_vrei_attribute18             in     varchar2  default null
  ,p_vrei_attribute19             in     varchar2  default null
  ,p_vrei_attribute20             in     varchar2  default null
  ,p_vrei_information_category    in     varchar2  default null
  ,p_vrei_information1            in     varchar2  default null
  ,p_vrei_information2            in     varchar2  default null
  ,p_vrei_information3            in     varchar2  default null
  ,p_vrei_information4            in     varchar2  default null
  ,p_vrei_information5            in     varchar2  default null
  ,p_vrei_information6            in     varchar2  default null
  ,p_vrei_information7            in     varchar2  default null
  ,p_vrei_information8            in     varchar2  default null
  ,p_vrei_information9            in     varchar2  default null
  ,p_vrei_information10           in     varchar2  default null
  ,p_vrei_information11           in     varchar2  default null
  ,p_vrei_information12           in     varchar2  default null
  ,p_vrei_information13           in     varchar2  default null
  ,p_vrei_information14           in     varchar2  default null
   ,p_vrei_information15           in     varchar2  default null
  ,p_vrei_information16           in     varchar2  default null
  ,p_vrei_information17           in     varchar2  default null
  ,p_vrei_information18           in     varchar2  default null
  ,p_vrei_information19           in     varchar2  default null
  ,p_vrei_information20           in     varchar2  default null
  ,p_vrei_information21           in     varchar2  default null
  ,p_vrei_information22           in     varchar2  default null
  ,p_vrei_information23           in     varchar2  default null
  ,p_vrei_information24           in     varchar2  default null
  ,p_vrei_information25           in     varchar2  default null
  ,p_vrei_information26           in     varchar2  default null
  ,p_vrei_information27           in     varchar2  default null
  ,p_vrei_information28           in     varchar2  default null
  ,p_vrei_information29           in     varchar2  default null
  ,p_vrei_information30           in     varchar2  default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_veh_repos_extra_info_id      out    nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_repos_extra_info_api.update_veh_repos_extra_info
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
PROCEDURE update_veh_repos_extra_info
  (
  p_validate                     in     number    default hr_api.g_false_num
  ,p_veh_repos_extra_info_id      in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_repository_id        in     number    default hr_api.g_number
  ,p_information_type             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information1            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information2            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information3            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information4            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information5            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information6            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information7            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information8            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information9            in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information10           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information11           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information12           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information13           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information14           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information15           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information16           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information17           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information18           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information19           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information20           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information21           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information22           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information23           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information24           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information25           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information26           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information27           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information28           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information29           in     varchar2  default hr_api.g_varchar2
  ,p_vrei_information30           in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_veh_repos_extra_info >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_veh_repos_extra_info_api.delete_veh_repos_extra_info
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
PROCEDURE delete_veh_repos_extra_info
  (
  p_validate                     in     number    default hr_api.g_false_num
  ,p_veh_repos_extra_info_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end pqp_veh_repos_extra_info_swi;

 

/
