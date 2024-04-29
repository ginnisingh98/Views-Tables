--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_INFORMATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_INFORMATION_SWI" AUTHID CURRENT_USER As
/* $Header: pecniswi.pkh 120.0 2005/05/31 06:50 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_config_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_information_api.create_config_information
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
PROCEDURE create_config_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_configuration_code             in   varchar2
  ,p_config_information_category  in     varchar2
  ,p_config_sequence              in     number
  ,p_config_information1          in     varchar2  default null
  ,p_config_information2          in     varchar2  default null
  ,p_config_information3          in     varchar2  default null
  ,p_config_information4          in     varchar2  default null
  ,p_config_information5          in     varchar2  default null
  ,p_config_information6          in     varchar2  default null
  ,p_config_information7          in     varchar2  default null
  ,p_config_information8          in     varchar2  default null
  ,p_config_information9          in     varchar2  default null
  ,p_config_information10         in     varchar2  default null
  ,p_config_information11         in     varchar2  default null
  ,p_config_information12         in     varchar2  default null
  ,p_config_information13         in     varchar2  default null
  ,p_config_information14         in     varchar2  default null
  ,p_config_information15         in     varchar2  default null
  ,p_config_information16         in     varchar2  default null
  ,p_config_information17         in     varchar2  default null
  ,p_config_information18         in     varchar2  default null
  ,p_config_information19         in     varchar2  default null
  ,p_config_information20         in     varchar2  default null
  ,p_config_information21         in     varchar2  default null
  ,p_config_information22         in     varchar2  default null
  ,p_config_information23         in     varchar2  default null
  ,p_config_information24         in     varchar2  default null
  ,p_config_information25         in     varchar2  default null
  ,p_config_information26         in     varchar2  default null
  ,p_config_information27         in     varchar2  default null
  ,p_config_information28         in     varchar2  default null
  ,p_config_information29         in     varchar2  default null
  ,p_config_information30         in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_config_information_id           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_config_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_information_api.update_config_information
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
PROCEDURE update_config_information
  (  p_validate                     in     number    default hr_api.g_false_num
  ,p_config_information_id        in     number
  ,p_configuration_code             in   varchar2
  ,p_config_information_category  in     varchar2
  ,p_config_sequence              in     number    default hr_api.g_number
  ,p_config_information1          in     varchar2  default hr_api.g_varchar2
  ,p_config_information2          in     varchar2  default hr_api.g_varchar2
  ,p_config_information3          in     varchar2  default hr_api.g_varchar2
  ,p_config_information4          in     varchar2  default hr_api.g_varchar2
  ,p_config_information5          in     varchar2  default hr_api.g_varchar2
  ,p_config_information6          in     varchar2  default hr_api.g_varchar2
  ,p_config_information7          in     varchar2  default hr_api.g_varchar2
  ,p_config_information8          in     varchar2  default hr_api.g_varchar2
  ,p_config_information9          in     varchar2  default hr_api.g_varchar2
  ,p_config_information10         in     varchar2  default hr_api.g_varchar2
  ,p_config_information11         in     varchar2  default hr_api.g_varchar2
  ,p_config_information12         in     varchar2  default hr_api.g_varchar2
  ,p_config_information13         in     varchar2  default hr_api.g_varchar2
  ,p_config_information14         in     varchar2  default hr_api.g_varchar2
  ,p_config_information15         in     varchar2  default hr_api.g_varchar2
  ,p_config_information16         in     varchar2  default hr_api.g_varchar2
  ,p_config_information17         in     varchar2  default hr_api.g_varchar2
  ,p_config_information18         in     varchar2  default hr_api.g_varchar2
  ,p_config_information19         in     varchar2  default hr_api.g_varchar2
  ,p_config_information20         in     varchar2  default hr_api.g_varchar2
  ,p_config_information21         in     varchar2  default hr_api.g_varchar2
  ,p_config_information22         in     varchar2  default hr_api.g_varchar2
  ,p_config_information23         in     varchar2  default hr_api.g_varchar2
  ,p_config_information24         in     varchar2  default hr_api.g_varchar2
  ,p_config_information25         in     varchar2  default hr_api.g_varchar2
  ,p_config_information26         in     varchar2  default hr_api.g_varchar2
  ,p_config_information27         in     varchar2  default hr_api.g_varchar2
  ,p_config_information28         in     varchar2  default hr_api.g_varchar2
  ,p_config_information29         in     varchar2  default hr_api.g_varchar2
  ,p_config_information30         in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_config_information >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_information_api.delete_config_information
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
PROCEDURE delete_config_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_config_information_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end per_ri_config_information_swi;

 

/
