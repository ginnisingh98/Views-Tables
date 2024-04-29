--------------------------------------------------------
--  DDL for Package Body PAY_ACTION_INFORMATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ACTION_INFORMATION_SWI" As
/* $Header: pyaifswi.pkb 120.0.12000000.2 2007/03/30 05:37:31 ttagawa noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_action_information_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_action_information >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_context_id            in     number
  ,p_action_context_type          in     varchar2
  ,p_action_information_category  in     varchar2
  ,p_tax_unit_id                  in     number    default null
  ,p_jurisdiction_code            in     varchar2  default null
  ,p_source_id                    in     number    default null
  ,p_source_text                  in     varchar2  default null
  ,p_tax_group                    in     varchar2  default null
  ,p_effective_date               in     date      default null
  ,p_assignment_id                in     number    default null
  ,p_action_information1          in     varchar2  default null
  ,p_action_information2          in     varchar2  default null
  ,p_action_information3          in     varchar2  default null
  ,p_action_information4          in     varchar2  default null
  ,p_action_information5          in     varchar2  default null
  ,p_action_information6          in     varchar2  default null
  ,p_action_information7          in     varchar2  default null
  ,p_action_information8          in     varchar2  default null
  ,p_action_information9          in     varchar2  default null
  ,p_action_information10         in     varchar2  default null
  ,p_action_information11         in     varchar2  default null
  ,p_action_information12         in     varchar2  default null
  ,p_action_information13         in     varchar2  default null
  ,p_action_information14         in     varchar2  default null
  ,p_action_information15         in     varchar2  default null
  ,p_action_information16         in     varchar2  default null
  ,p_action_information17         in     varchar2  default null
  ,p_action_information18         in     varchar2  default null
  ,p_action_information19         in     varchar2  default null
  ,p_action_information20         in     varchar2  default null
  ,p_action_information21         in     varchar2  default null
  ,p_action_information22         in     varchar2  default null
  ,p_action_information23         in     varchar2  default null
  ,p_action_information24         in     varchar2  default null
  ,p_action_information25         in     varchar2  default null
  ,p_action_information26         in     varchar2  default null
  ,p_action_information27         in     varchar2  default null
  ,p_action_information28         in     varchar2  default null
  ,p_action_information29         in     varchar2  default null
  ,p_action_information30         in     varchar2  default null
  ,p_action_information_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_action_information_id        number;
  l_proc    varchar2(72) := g_package ||'create_action_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_action_information_swi;
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
  pay_aif_ins.set_base_key_value
    (p_action_information_id => p_action_information_id
    );
  --
  -- Call API
  --
  pay_action_information_api.create_action_information
    (p_validate                     => l_validate
    ,p_action_context_id            => p_action_context_id
    ,p_action_context_type          => p_action_context_type
    ,p_action_information_category  => p_action_information_category
    ,p_tax_unit_id                  => p_tax_unit_id
    ,p_jurisdiction_code            => p_jurisdiction_code
    ,p_source_id                    => p_source_id
    ,p_source_text                  => p_source_text
    ,p_tax_group                    => p_tax_group
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_action_information1          => p_action_information1
    ,p_action_information2          => p_action_information2
    ,p_action_information3          => p_action_information3
    ,p_action_information4          => p_action_information4
    ,p_action_information5          => p_action_information5
    ,p_action_information6          => p_action_information6
    ,p_action_information7          => p_action_information7
    ,p_action_information8          => p_action_information8
    ,p_action_information9          => p_action_information9
    ,p_action_information10         => p_action_information10
    ,p_action_information11         => p_action_information11
    ,p_action_information12         => p_action_information12
    ,p_action_information13         => p_action_information13
    ,p_action_information14         => p_action_information14
    ,p_action_information15         => p_action_information15
    ,p_action_information16         => p_action_information16
    ,p_action_information17         => p_action_information17
    ,p_action_information18         => p_action_information18
    ,p_action_information19         => p_action_information19
    ,p_action_information20         => p_action_information20
    ,p_action_information21         => p_action_information21
    ,p_action_information22         => p_action_information22
    ,p_action_information23         => p_action_information23
    ,p_action_information24         => p_action_information24
    ,p_action_information25         => p_action_information25
    ,p_action_information26         => p_action_information26
    ,p_action_information27         => p_action_information27
    ,p_action_information28         => p_action_information28
    ,p_action_information29         => p_action_information29
    ,p_action_information30         => p_action_information30
    ,p_action_information_id        => l_action_information_id
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
    rollback to create_action_information_swi;
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
    rollback to create_action_information_swi;
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
end create_action_information;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_action_information >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_information_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_action_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_action_information_swi;
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
  pay_action_information_api.delete_action_information
    (p_validate                     => l_validate
    ,p_action_information_id        => p_action_information_id
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
    rollback to delete_action_information_swi;
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
    rollback to delete_action_information_swi;
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
end delete_action_information;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_action_information >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_action_information
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_information_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_action_information1          in     varchar2  default hr_api.g_varchar2
  ,p_action_information2          in     varchar2  default hr_api.g_varchar2
  ,p_action_information3          in     varchar2  default hr_api.g_varchar2
  ,p_action_information4          in     varchar2  default hr_api.g_varchar2
  ,p_action_information5          in     varchar2  default hr_api.g_varchar2
  ,p_action_information6          in     varchar2  default hr_api.g_varchar2
  ,p_action_information7          in     varchar2  default hr_api.g_varchar2
  ,p_action_information8          in     varchar2  default hr_api.g_varchar2
  ,p_action_information9          in     varchar2  default hr_api.g_varchar2
  ,p_action_information10         in     varchar2  default hr_api.g_varchar2
  ,p_action_information11         in     varchar2  default hr_api.g_varchar2
  ,p_action_information12         in     varchar2  default hr_api.g_varchar2
  ,p_action_information13         in     varchar2  default hr_api.g_varchar2
  ,p_action_information14         in     varchar2  default hr_api.g_varchar2
  ,p_action_information15         in     varchar2  default hr_api.g_varchar2
  ,p_action_information16         in     varchar2  default hr_api.g_varchar2
  ,p_action_information17         in     varchar2  default hr_api.g_varchar2
  ,p_action_information18         in     varchar2  default hr_api.g_varchar2
  ,p_action_information19         in     varchar2  default hr_api.g_varchar2
  ,p_action_information20         in     varchar2  default hr_api.g_varchar2
  ,p_action_information21         in     varchar2  default hr_api.g_varchar2
  ,p_action_information22         in     varchar2  default hr_api.g_varchar2
  ,p_action_information23         in     varchar2  default hr_api.g_varchar2
  ,p_action_information24         in     varchar2  default hr_api.g_varchar2
  ,p_action_information25         in     varchar2  default hr_api.g_varchar2
  ,p_action_information26         in     varchar2  default hr_api.g_varchar2
  ,p_action_information27         in     varchar2  default hr_api.g_varchar2
  ,p_action_information28         in     varchar2  default hr_api.g_varchar2
  ,p_action_information29         in     varchar2  default hr_api.g_varchar2
  ,p_action_information30         in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_action_information';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_action_information_swi;
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
  pay_action_information_api.update_action_information
    (p_validate                     => l_validate
    ,p_action_information_id        => p_action_information_id
    ,p_object_version_number        => p_object_version_number
    ,p_action_information1          => p_action_information1
    ,p_action_information2          => p_action_information2
    ,p_action_information3          => p_action_information3
    ,p_action_information4          => p_action_information4
    ,p_action_information5          => p_action_information5
    ,p_action_information6          => p_action_information6
    ,p_action_information7          => p_action_information7
    ,p_action_information8          => p_action_information8
    ,p_action_information9          => p_action_information9
    ,p_action_information10         => p_action_information10
    ,p_action_information11         => p_action_information11
    ,p_action_information12         => p_action_information12
    ,p_action_information13         => p_action_information13
    ,p_action_information14         => p_action_information14
    ,p_action_information15         => p_action_information15
    ,p_action_information16         => p_action_information16
    ,p_action_information17         => p_action_information17
    ,p_action_information18         => p_action_information18
    ,p_action_information19         => p_action_information19
    ,p_action_information20         => p_action_information20
    ,p_action_information21         => p_action_information21
    ,p_action_information22         => p_action_information22
    ,p_action_information23         => p_action_information23
    ,p_action_information24         => p_action_information24
    ,p_action_information25         => p_action_information25
    ,p_action_information26         => p_action_information26
    ,p_action_information27         => p_action_information27
    ,p_action_information28         => p_action_information28
    ,p_action_information29         => p_action_information29
    ,p_action_information30         => p_action_information30
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
    rollback to update_action_information_swi;
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
    rollback to update_action_information_swi;
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
end update_action_information;
end pay_action_information_swi;

/
