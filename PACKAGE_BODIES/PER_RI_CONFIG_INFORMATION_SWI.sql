--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_INFORMATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_INFORMATION_SWI" As
/* $Header: pecniswi.pkb 120.0 2005/05/31 06:50 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_ri_config_information_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_config_information >----------------------|
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_config_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_config_information_swi;
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
  per_ri_config_information_api.create_config_information
    (p_validate                     => l_validate
    ,p_configuration_code             => p_configuration_code
    ,p_config_information_category  => p_config_information_category
    ,p_config_sequence              => p_config_sequence
    ,p_config_information1          => p_config_information1
    ,p_config_information2          => p_config_information2
    ,p_config_information3          => p_config_information3
    ,p_config_information4          => p_config_information4
    ,p_config_information5          => p_config_information5
    ,p_config_information6          => p_config_information6
    ,p_config_information7          => p_config_information7
    ,p_config_information8          => p_config_information8
    ,p_config_information9          => p_config_information9
    ,p_config_information10         => p_config_information10
    ,p_config_information11         => p_config_information11
    ,p_config_information12         => p_config_information12
    ,p_config_information13         => p_config_information13
    ,p_config_information14         => p_config_information14
    ,p_config_information15         => p_config_information15
    ,p_config_information16         => p_config_information16
    ,p_config_information17         => p_config_information17
    ,p_config_information18         => p_config_information18
    ,p_config_information19         => p_config_information19
    ,p_config_information20         => p_config_information20
    ,p_config_information21         => p_config_information21
    ,p_config_information22         => p_config_information22
    ,p_config_information23         => p_config_information23
    ,p_config_information24         => p_config_information24
    ,p_config_information25         => p_config_information25
    ,p_config_information26         => p_config_information26
    ,p_config_information27         => p_config_information27
    ,p_config_information28         => p_config_information28
    ,p_config_information29         => p_config_information29
    ,p_config_information30         => p_config_information30
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_config_information_id        => p_config_information_id
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
    rollback to create_config_information_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_config_information_id        := null;
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
    rollback to create_config_information_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_config_information_id        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_config_information;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_config_information >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_config_information
  (p_validate                     in     number    default hr_api.g_false_num
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
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_config_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_config_information_swi;
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
  per_ri_config_information_api.update_config_information
    (p_validate                     => l_validate
    ,p_config_information_id        => p_config_information_id
    ,p_configuration_code             => p_configuration_code
    ,p_config_information_category  => p_config_information_category
    ,p_config_sequence              => p_config_sequence
    ,p_config_information1          => p_config_information1
    ,p_config_information2          => p_config_information2
    ,p_config_information3          => p_config_information3
    ,p_config_information4          => p_config_information4
    ,p_config_information5          => p_config_information5
    ,p_config_information6          => p_config_information6
    ,p_config_information7          => p_config_information7
    ,p_config_information8          => p_config_information8
    ,p_config_information9          => p_config_information9
    ,p_config_information10         => p_config_information10
    ,p_config_information11         => p_config_information11
    ,p_config_information12         => p_config_information12
    ,p_config_information13         => p_config_information13
    ,p_config_information14         => p_config_information14
    ,p_config_information15         => p_config_information15
    ,p_config_information16         => p_config_information16
    ,p_config_information17         => p_config_information17
    ,p_config_information18         => p_config_information18
    ,p_config_information19         => p_config_information19
    ,p_config_information20         => p_config_information20
    ,p_config_information21         => p_config_information21
    ,p_config_information22         => p_config_information22
    ,p_config_information23         => p_config_information23
    ,p_config_information24         => p_config_information24
    ,p_config_information25         => p_config_information25
    ,p_config_information26         => p_config_information26
    ,p_config_information27         => p_config_information27
    ,p_config_information28         => p_config_information28
    ,p_config_information29         => p_config_information29
    ,p_config_information30         => p_config_information30
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
    rollback to update_config_information_swi;
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
    rollback to update_config_information_swi;
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
end update_config_information;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_config_information >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_config_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_config_information_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_config_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_config_information_swi;
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
  per_ri_config_information_api.delete_config_information
    (p_validate                     => l_validate
    ,p_config_information_id        => p_config_information_id
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
    rollback to delete_config_information_swi;
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
    rollback to delete_config_information_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_config_information;
end per_ri_config_information_swi;

/
