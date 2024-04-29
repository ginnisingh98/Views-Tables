--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_LOCATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_LOCATION_SWI" As
/* $Header: pecnlswi.pkb 120.0 2005/05/31 06:56 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_ri_config_location_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_location >---------------------------|
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_location';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_location_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  per_ri_config_location_api.create_location
    (p_validate                     => l_validate
    ,p_configuration_code           => p_configuration_code
    ,p_configuration_context        => p_configuration_context
    ,p_location_code                => p_location_code
    ,p_description                  => p_description
    ,p_style                        => p_style
    ,p_address_line_1               => p_address_line_1
    ,p_address_line_2               => p_address_line_2
    ,p_address_line_3               => p_address_line_3
    ,p_town_or_city                 => p_town_or_city
    ,p_country                      => p_country
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_loc_information13            => p_loc_information13
    ,p_loc_information14            => p_loc_information14
    ,p_loc_information15            => p_loc_information15
    ,p_loc_information16            => p_loc_information16
    ,p_loc_information17            => p_loc_information17
    ,p_loc_information18            => p_loc_information18
    ,p_loc_information19            => p_loc_information19
    ,p_loc_information20            => p_loc_information20
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_location_id                  => p_location_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_location_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_location_id                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_location_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_location_id                  := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_location;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_location >---------------------------|
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_location';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_location_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  per_ri_config_location_api.update_location
    (p_validate                     => l_validate
    ,p_location_id                  => p_location_id
    ,p_configuration_code           => p_configuration_code
    ,p_configuration_context        => p_configuration_context
    ,p_location_code                => p_location_code
    ,p_description                  => p_description
    ,p_style                        => p_style
    ,p_address_line_1               => p_address_line_1
    ,p_address_line_2               => p_address_line_2
    ,p_address_line_3               => p_address_line_3
    ,p_town_or_city                 => p_town_or_city
    ,p_country                      => p_country
    ,p_postal_code                  => p_postal_code
    ,p_region_1                     => p_region_1
    ,p_region_2                     => p_region_2
    ,p_region_3                     => p_region_3
    ,p_telephone_number_1           => p_telephone_number_1
    ,p_telephone_number_2           => p_telephone_number_2
    ,p_telephone_number_3           => p_telephone_number_3
    ,p_loc_information13            => p_loc_information13
    ,p_loc_information14            => p_loc_information14
    ,p_loc_information15            => p_loc_information15
    ,p_loc_information16            => p_loc_information16
    ,p_loc_information17            => p_loc_information17
    ,p_loc_information18            => p_loc_information18
    ,p_loc_information19            => p_loc_information19
    ,p_loc_information20            => p_loc_information20
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_location_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_location_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_location;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_location >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_location
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_location_id                  in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_location';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_location_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  per_ri_config_location_api.delete_location
    (p_validate                     => l_validate
    ,p_location_id                  => p_location_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_location_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_location_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_location;
end per_ri_config_location_swi;

/
