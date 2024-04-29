--------------------------------------------------------
--  DDL for Package Body OTA_BOOKING_STATUS_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BOOKING_STATUS_TYPE_SWI" As
/* $Header: otbstswi.pkb 120.0 2005/05/29 07:04 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_booking_status_type_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_booking_status_type >----------------------|
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_booking_status_type_id       number;
  l_proc    varchar2(72) := g_package ||'create_booking_status_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_booking_status_type_swi;
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
  ota_bst_api.set_base_key_value
    (p_booking_status_type_id => p_booking_status_type_id
    );
  --
  -- Call API
  --
  ota_booking_status_type_api.create_booking_status_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_active_flag                  => p_active_flag
    ,p_default_flag                 => p_default_flag
    ,p_name                         => p_name
    ,p_type                         => p_type
    ,p_place_used_flag              => p_place_used_flag
    ,p_comments                     => p_comments
    ,p_description                  => p_description
    ,p_bst_information_category     => p_bst_information_category
    ,p_bst_information1             => p_bst_information1
    ,p_bst_information2             => p_bst_information2
    ,p_bst_information3             => p_bst_information3
    ,p_bst_information4             => p_bst_information4
    ,p_bst_information5             => p_bst_information5
    ,p_bst_information6             => p_bst_information6
    ,p_bst_information7             => p_bst_information7
    ,p_bst_information8             => p_bst_information8
    ,p_bst_information9             => p_bst_information9
    ,p_bst_information10            => p_bst_information10
    ,p_bst_information11            => p_bst_information11
    ,p_bst_information12            => p_bst_information12
    ,p_bst_information13            => p_bst_information13
    ,p_bst_information14            => p_bst_information14
    ,p_bst_information15            => p_bst_information15
    ,p_bst_information16            => p_bst_information16
    ,p_bst_information17            => p_bst_information17
    ,p_bst_information18            => p_bst_information18
    ,p_bst_information19            => p_bst_information19
    ,p_bst_information20            => p_bst_information20
    ,p_object_version_number        => p_object_version_number
    ,p_booking_status_type_id       => l_booking_status_type_id
 --   ,p_data_source                  => p_data_source
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
    rollback to create_booking_status_type_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
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
    rollback to create_booking_status_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_booking_status_type;
-- ----------------------------------------------------------------------------
-- |----------------------< update_booking_status_type >----------------------|
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_booking_status_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_booking_status_type_swi;
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
  ota_booking_status_type_api.update_booking_status_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_active_flag                  => p_active_flag
    ,p_default_flag                 => p_default_flag
    ,p_name                         => p_name
    ,p_type                         => p_type
    ,p_place_used_flag              => p_place_used_flag
    ,p_comments                     => p_comments
    ,p_description                  => p_description
    ,p_bst_information_category     => p_bst_information_category
    ,p_bst_information1             => p_bst_information1
    ,p_bst_information2             => p_bst_information2
    ,p_bst_information3             => p_bst_information3
    ,p_bst_information4             => p_bst_information4
    ,p_bst_information5             => p_bst_information5
    ,p_bst_information6             => p_bst_information6
    ,p_bst_information7             => p_bst_information7
    ,p_bst_information8             => p_bst_information8
    ,p_bst_information9             => p_bst_information9
    ,p_bst_information10            => p_bst_information10
    ,p_bst_information11            => p_bst_information11
    ,p_bst_information12            => p_bst_information12
    ,p_bst_information13            => p_bst_information13
    ,p_bst_information14            => p_bst_information14
    ,p_bst_information15            => p_bst_information15
    ,p_bst_information16            => p_bst_information16
    ,p_bst_information17            => p_bst_information17
    ,p_bst_information18            => p_bst_information18
    ,p_bst_information19            => p_bst_information19
    ,p_bst_information20            => p_bst_information20
    ,p_booking_status_type_id       => p_booking_status_type_id
    ,p_object_version_number        => p_object_version_number
--    ,p_data_source                  => p_data_source
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
    rollback to update_booking_status_type_swi;
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
    rollback to update_booking_status_type_swi;
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
end update_booking_status_type;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_booking_status_type >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_booking_status_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_booking_status_type_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_booking_status_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_booking_status_type_swi;
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
  ota_booking_status_type_api.delete_booking_status_type
    (p_validate                     => l_validate
    ,p_booking_status_type_id       => p_booking_status_type_id
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
    rollback to delete_booking_status_type_swi;
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
    rollback to delete_booking_status_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_booking_status_type;
end ota_booking_status_type_swi;

/
