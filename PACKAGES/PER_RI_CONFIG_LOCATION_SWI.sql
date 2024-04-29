--------------------------------------------------------
--  DDL for Package PER_RI_CONFIG_LOCATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIG_LOCATION_SWI" AUTHID CURRENT_USER As
/* $Header: pecnlswi.pkh 120.0 2005/05/31 06:57 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_location >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_location_api.create_location
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
PROCEDURE create_location
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_configuration_code           in     varchar2
  ,p_configuration_context        in     varchar2
  ,p_location_code                in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_style                        in     varchar2  default null
  ,p_address_line_1               in     varchar2  default null
  ,p_address_line_2               in     varchar2  default null
  ,p_address_line_3               in     varchar2  default null
  ,p_town_or_city                 in     varchar2  default null
  ,p_country                      in     varchar2  default null
  ,p_postal_code                  in     varchar2  default null
  ,p_region_1                     in     varchar2  default null
  ,p_region_2                     in     varchar2  default null
  ,p_region_3                     in     varchar2  default null
  ,p_telephone_number_1           in     varchar2  default null
  ,p_telephone_number_2           in     varchar2  default null
  ,p_telephone_number_3           in     varchar2  default null
  ,p_loc_information13            in     varchar2  default null
  ,p_loc_information14            in     varchar2  default null
  ,p_loc_information15            in     varchar2  default null
  ,p_loc_information16            in     varchar2  default null
  ,p_loc_information17            in     varchar2  default null
  ,p_loc_information18            in     varchar2  default null
  ,p_loc_information19            in     varchar2  default null
  ,p_loc_information20            in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_location_id                     out nocopy number
  ,p_return_status                   out nocopy varchar2
   );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_location >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_location_api.update_location
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
PROCEDURE update_location
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_location_id                  in     number
  ,p_configuration_code           in     varchar2
  ,p_configuration_context        in     varchar2
  ,p_location_code                in     varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_style                        in     varchar2  default hr_api.g_varchar2
  ,p_address_line_1               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_2               in     varchar2  default hr_api.g_varchar2
  ,p_address_line_3               in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_loc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_loc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_location >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_config_location_api.delete_location
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
PROCEDURE delete_location
(p_validate                     in     number    default hr_api.g_false_num
  ,p_location_id                  in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end per_ri_config_location_swi;

 

/
