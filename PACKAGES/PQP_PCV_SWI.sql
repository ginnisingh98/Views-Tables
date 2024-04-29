--------------------------------------------------------
--  DDL for Package PQP_PCV_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_SWI" AUTHID CURRENT_USER As
/* $Header: pqpcvswi.pkh 120.0 2005/05/29 01:55 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pcv_api.create_configuration_value
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
PROCEDURE create_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_pcv_attribute_category       in     varchar2  default null
  ,p_pcv_attribute1               in     varchar2  default null
  ,p_pcv_attribute2               in     varchar2  default null
  ,p_pcv_attribute3               in     varchar2  default null
  ,p_pcv_attribute4               in     varchar2  default null
  ,p_pcv_attribute5               in     varchar2  default null
  ,p_pcv_attribute6               in     varchar2  default null
  ,p_pcv_attribute7               in     varchar2  default null
  ,p_pcv_attribute8               in     varchar2  default null
  ,p_pcv_attribute9               in     varchar2  default null
  ,p_pcv_attribute10              in     varchar2  default null
  ,p_pcv_attribute11              in     varchar2  default null
  ,p_pcv_attribute12              in     varchar2  default null
  ,p_pcv_attribute13              in     varchar2  default null
  ,p_pcv_attribute14              in     varchar2  default null
  ,p_pcv_attribute15              in     varchar2  default null
  ,p_pcv_attribute16              in     varchar2  default null
  ,p_pcv_attribute17              in     varchar2  default null
  ,p_pcv_attribute18              in     varchar2  default null
  ,p_pcv_attribute19              in     varchar2  default null
  ,p_pcv_attribute20              in     varchar2  default null
  ,p_pcv_information_category     in     varchar2  default null
  ,p_pcv_information1             in     varchar2  default null
  ,p_pcv_information2             in     varchar2  default null
  ,p_pcv_information3             in     varchar2  default null
  ,p_pcv_information4             in     varchar2  default null
  ,p_pcv_information5             in     varchar2  default null
  ,p_pcv_information6             in     varchar2  default null
  ,p_pcv_information7             in     varchar2  default null
  ,p_pcv_information8             in     varchar2  default null
  ,p_pcv_information9             in     varchar2  default null
  ,p_pcv_information10            in     varchar2  default null
  ,p_pcv_information11            in     varchar2  default null
  ,p_pcv_information12            in     varchar2  default null
  ,p_pcv_information13            in     varchar2  default null
  ,p_pcv_information14            in     varchar2  default null
  ,p_pcv_information15            in     varchar2  default null
  ,p_pcv_information16            in     varchar2  default null
  ,p_pcv_information17            in     varchar2  default null
  ,p_pcv_information18            in     varchar2  default null
  ,p_pcv_information19            in     varchar2  default null
  ,p_pcv_information20            in     varchar2  default null
  ,p_configuration_name           in     varchar2  default null
  ,p_configuration_value_id          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pcv_api.update_configuration_value
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
PROCEDURE update_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_configuration_value_id       in     number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information1             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pcv_information20            in     varchar2  default hr_api.g_varchar2
  ,p_configuration_name           in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_configuration_value >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_pcv_api.delete_configuration_value
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
PROCEDURE delete_configuration_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_configuration_value_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end pqp_pcv_swi;

 

/
