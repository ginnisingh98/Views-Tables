--------------------------------------------------------
--  DDL for Package Body IRC_COMMUNICATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_COMMUNICATIONS_SWI" As
/* $Header: ircomswi.pkb 120.3.12010000.2 2008/11/13 18:44:06 amikukum ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_communications_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< close_communication >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE close_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_communication_id             in     number
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
  l_proc    varchar2(72) := g_package ||'close_communication';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint close_communication_swi;
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
  irc_communications_api.close_communication
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_communication_property_id    => p_communication_property_id
    ,p_object_type                  => p_object_type
    ,p_object_id                    => p_object_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_communication_id             => p_communication_id
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
    rollback to close_communication_swi;
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
    rollback to close_communication_swi;
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
end close_communication;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_communication >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_status                       in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_communication_id             in     number
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
  l_proc    varchar2(72) := g_package ||'update_communication';
Begin
  --hr_utility.trace_on(null,'gaukumar');
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_communication_swi;
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
  irc_communications_api.update_communication
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_communication_property_id    => p_communication_property_id
    ,p_object_type                  => p_object_type
    ,p_object_id                    => p_object_id
    ,p_status                       => p_status
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_communication_id             => p_communication_id
    ,p_object_version_number        => l_object_version_number
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
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  hr_utility.set_location(' Leaving: and status ='||p_return_status ,120);
  --hr_utility.trace_off;
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_communication_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    hr_utility.set_location(' Leaving: and status ='||p_return_status ,121);
    --hr_utility.trace_off;
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_communication_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
    hr_utility.set_location(' Leaving: and status ='||p_return_status ,122);
    --hr_utility.trace_off;
end update_communication;
-- ----------------------------------------------------------------------------
-- |------------------------< define_comm_properties >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE define_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_comm_status          in     varchar2
  ,p_allow_attachment_flag        in     varchar2
  ,p_auto_notification_flag       in     varchar2
  ,p_allow_add_recipients         in     varchar2
  ,p_default_moderator            in     varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_communication_property_id    in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_property_id     number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'define_comm_properties';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint define_comm_properties_swi;
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
  irc_cmp_ins.set_base_key_value
    (p_communication_property_id => p_communication_property_id
    );
  --
  -- Call API
  --
  irc_communications_api.define_comm_properties
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_object_type                  => p_object_type
    ,p_object_id                    => p_object_id
    ,p_default_comm_status          => p_default_comm_status
    ,p_allow_attachment_flag        => p_allow_attachment_flag
    ,p_auto_notification_flag       => p_auto_notification_flag
    ,p_allow_add_recipients         => p_allow_add_recipients
    ,p_default_moderator            => p_default_moderator
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_communication_property_id    => l_communication_property_id
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
    rollback to define_comm_properties_swi;
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
    rollback to define_comm_properties_swi;
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
end define_comm_properties;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_communication >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_status                       in     varchar2
  ,p_start_date                   in     date
  ,p_communication_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_id              number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_communication';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_communication_swi;
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
    irc_cmc_ins.set_base_key_value
    (p_communication_id => p_communication_id
    );
  --
  -- Call API
  --
  irc_communications_api.create_communication
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_communication_property_id    => p_communication_property_id
    ,p_object_type                  => p_object_type
    ,p_object_id                    => p_object_id
    ,p_status                       => p_status
    ,p_start_date                   => p_start_date
    ,p_object_version_number        => p_object_version_number
    ,p_communication_id             => l_communication_id
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
    rollback to create_communication_swi;
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
    rollback to create_communication_swi;
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
end create_communication;
-- ----------------------------------------------------------------------------
-- |------------------------< update_comm_properties >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_comm_status          in     varchar2
  ,p_allow_attachment_flag        in     varchar2
  ,p_auto_notification_flag       in     varchar2
  ,p_allow_add_recipients         in     varchar2
  ,p_default_moderator            in     varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_communication_property_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_object_version_number         number := p_object_version_number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_comm_properties';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_COMM_PROPERTIES_SWI;
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
  irc_communications_api.update_comm_properties
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_object_type                  => p_object_type
    ,p_object_id                    => p_object_id
    ,p_default_comm_status          => p_default_comm_status
    ,p_allow_attachment_flag        => p_allow_attachment_flag
    ,p_auto_notification_flag       => p_auto_notification_flag
    ,p_allow_add_recipients         => p_allow_add_recipients
    ,p_default_moderator            => p_default_moderator
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_information_category         => p_information_category
    ,p_information1                 => p_information1
    ,p_information2                 => p_information2
    ,p_information3                 => p_information3
    ,p_information4                 => p_information4
    ,p_information5                 => p_information5
    ,p_information6                 => p_information6
    ,p_information7                 => p_information7
    ,p_information8                 => p_information8
    ,p_information9                 => p_information9
    ,p_information10                => p_information10
    ,p_communication_property_id    => p_communication_property_id
    ,p_object_version_number        => l_object_version_number
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
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_comm_properties_swi;
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
    rollback to update_comm_properties_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_comm_properties;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_comm_properties >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_communication_property_id    in     number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_comm_properties';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_comm_properties_swi;
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
  irc_communications_api.delete_comm_properties
    (p_validate                     => l_validate
    ,p_object_version_number        => p_object_version_number
    ,p_communication_property_id    => p_communication_property_id
    ,p_effective_date               => p_effective_date
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
    rollback to delete_comm_properties_swi;
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
    rollback to delete_comm_properties_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_comm_properties;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_comm_topic >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comm_topic
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_id             in     number
  ,p_subject                      in     varchar2
  ,p_status                       in     varchar2
  ,p_communication_topic_id       in     number
  ,p_object_version_number        out    nocopy number
  ,p_return_status                out    nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_topic_id     number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_comm_topic';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_COMM_TOPIC;
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
  irc_cmt_ins.set_base_key_value
    (p_communication_topic_id => p_communication_topic_id
    );
  --
  -- Call API
  --
  irc_communications_api.create_comm_topic
   (p_validate                => l_validate
   ,p_effective_date          => p_effective_date
   ,p_communication_id        => p_communication_id
   ,p_subject                 => p_subject
   ,p_status                  => p_status
   ,p_communication_topic_id  => l_communication_topic_id
   ,p_object_version_number   => p_object_version_number
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
    rollback to CREATE_COMM_TOPIC;
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
    rollback to CREATE_COMM_TOPIC;
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
end create_comm_topic;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_MESSAGE >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_topic_id       in     number
  ,p_parent_id                    in     number    default hr_api.g_number
  ,p_message_subject              in     varchar2  default hr_api.g_varchar2
  ,p_message_post_date            in     date
  ,p_sender_type                  in     varchar2
  ,p_sender_id                    in     number
  ,p_message_body                 in     varchar2  default hr_api.g_varchar2
  ,p_document_type                in     varchar2  default hr_api.g_varchar2
  ,p_document_id                  in     number    default hr_api.g_number
  ,p_deleted_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        out    nocopy number
  ,p_return_status                out    nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_message_id     number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_message';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_MESSAGE;
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
  irc_cmm_ins.set_base_key_value
    (p_communication_message_id => p_communication_message_id
    );
  --
  -- Call API
  --
  irc_communications_api.create_message
  (p_validate                     => l_validate
  ,p_effective_date               => p_effective_date
  ,p_communication_topic_id       => p_communication_topic_id
  ,p_parent_id                    => p_parent_id
  ,p_message_subject              => p_message_subject
  ,p_message_post_date            => p_message_post_date
  ,p_sender_type                  => p_sender_type
  ,p_sender_id                    => p_sender_id
  ,p_message_body                 => p_message_body
  ,p_document_type                => p_document_type
  ,p_document_id                  => p_document_id
  ,p_deleted_flag                 => p_deleted_flag
  ,p_communication_message_id     => l_communication_message_id
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
    rollback to CREATE_MESSAGE;
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
    rollback to CREATE_MESSAGE;
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
end create_message;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_MESSAGE >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_deleted_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                out    nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_object_version_number     number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_message';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_MESSAGE;
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
  l_object_version_number := p_object_version_number;
  --
  -- Call API
  --
  irc_communications_api.update_message
  (p_validate                     => l_validate
  ,p_effective_date               => p_effective_date
  ,p_deleted_flag                 => p_deleted_flag
  ,p_communication_message_id     => p_communication_message_id
  ,p_object_version_number        => l_object_version_number
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
  p_object_version_number := l_object_version_number;
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to UPDATE_MESSAGE;
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
    rollback to UPDATE_MESSAGE;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_message;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ADD_RECIPIENT >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure ADD_RECIPIENT
  (p_validate                      in     number     default hr_api.g_false_num
  ,p_effective_date                in     date
  ,p_communication_object_type     in     varchar2
  ,p_communication_object_id       in     number
  ,p_recipient_type                in     varchar2
  ,p_recipient_id                  in     number
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date      default hr_api.g_date
  ,p_primary_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_communication_recipient_id    in     number
  ,p_object_version_number         out nocopy number
  ,p_return_status                 out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_recipient_id     number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'add_recipient';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint ADD_RECIPIENT;
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
  irc_cmr_ins.set_base_key_value
    (p_communication_recipient_id => p_communication_recipient_id
    );
  --
  -- Call API
  --
  irc_communications_api.add_recipient
  (p_validate                      => l_validate
  ,p_effective_date                => p_effective_date
  ,p_communication_object_type     => p_communication_object_type
  ,p_communication_object_id       => p_communication_object_id
  ,p_recipient_type                => p_recipient_type
  ,p_recipient_id                  => p_recipient_id
  ,p_start_date_active             => p_start_date_active
  ,p_end_date_active               => p_end_date_active
  ,p_primary_flag                  => p_primary_flag
  ,p_communication_recipient_id    => l_communication_recipient_id
  ,p_object_version_number         => p_object_version_number
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
    rollback to ADD_RECIPIENT;
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
    rollback to ADD_RECIPIENT;
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
end add_recipient;
--
--Save For Later Code Changes
-- ----------------------------------------------------------------------------
-- |-------------------------< process_com_api >--------------------------|
-- ----------------------------------------------------------------------------

procedure process_com_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_object_version_number number;
   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'PROCESS_COM_API';

   -- Variables for OUT parameters
   l_communication_property_id     number;
   l_vacancy_id                    number;
   l_effective_date                date  :=  trunc(sysdate);
   --
BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));
--

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
--
--Get the values for in/out parameters
--
   l_communication_property_id :=  hr_transaction_swi.getNumberValue(l_CommitNode,'CommunicationPropertyId');
   l_object_version_number     := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');
--
   if p_effective_date is null
   then
   --
     l_effective_date := trunc(sysdate);
   --
   else
   --
     l_effective_date := p_effective_date;
   --
   end if;
   --

   if l_postState = '0' then
   define_comm_properties(
    p_validate                  =>  p_validate
   ,p_effective_date            =>  l_effective_date
   ,p_object_type               =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'ObjectType')
   ,p_object_id                 =>  hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectId')
   ,p_default_comm_status       =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'DefaultCommStatus')
   ,p_allow_attachment_flag     =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AllowAttachmentFlag')
   ,p_auto_notification_flag    =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AutoNotificationFlag')
   ,p_allow_add_recipients      =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AllowAddRecipients')
   ,p_default_moderator         =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'DefaultModerator')
   ,p_attribute_category        =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
   ,p_attribute1                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
   ,p_attribute2                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
   ,p_attribute3                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
   ,p_attribute4                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
   ,p_attribute5                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
   ,p_attribute6                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
   ,p_attribute7                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
   ,p_attribute8                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
   ,p_attribute9                =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
   ,p_attribute10               =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
   ,p_information_category      =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'InformationCategory')
   ,p_information1              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information1')
   ,p_information2              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information2')
   ,p_information3              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information3')
   ,p_information4              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information4')
   ,p_information5              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information5')
   ,p_information6              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information6')
   ,p_information7              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information7')
   ,p_information8              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information8')
   ,p_information9              =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information9')
   ,p_information10             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information10')
   ,p_communication_property_id =>  l_communication_property_id
   ,p_object_version_number     =>  l_object_version_number
   ,p_return_status             =>  l_return_status
   ) ;

   elsif l_postState = '2' then
     -- call update offer
     --
     update_comm_properties(
      p_validate                     =>       p_validate
     ,p_effective_date               =>       l_effective_date
     ,p_object_type                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'ObjectType')
     ,p_object_id                    =>       hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectId')
     ,p_default_comm_status          =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DefaultCommStatus')
     ,p_allow_attachment_flag        =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AllowAttachmentFlag')
     ,p_auto_notification_flag       =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AutoNotificationFlag')
     ,p_allow_add_recipients         =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AllowAddRecipients')
     ,p_default_moderator            =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'DefaultModerator')
     ,p_attribute_category           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
     ,p_attribute1                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
     ,p_attribute2                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
     ,p_attribute3                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
     ,p_attribute4                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
     ,p_attribute5                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
     ,p_attribute6                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
     ,p_attribute7                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
     ,p_attribute8                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
     ,p_attribute9                   =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
     ,p_attribute10                  =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
     ,p_information_category           =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'InformationCategory')
     ,p_information1                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information1')
     ,p_information2                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information2')
     ,p_information3                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information3')
     ,p_information4                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information4')
     ,p_information5                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information5')
     ,p_information6                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information6')
     ,p_information7                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information7')
     ,p_information8                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information8')
     ,p_information9                 =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information9')
     ,p_information10                =>       hr_transaction_swi.getVarchar2Value(l_CommitNode,'Information10')
     ,p_communication_property_id    =>       l_communication_property_id
     ,p_object_version_number        =>       l_object_version_number
     ,p_return_status                =>       l_return_status
     );
     --
   elsif l_postState = '3' then
     -- call delete offer
     --
     delete_comm_properties(
      p_validate                     =>       p_validate
     ,p_object_version_number        =>       l_object_version_number
     ,p_communication_property_id    =>       l_communication_property_id
     ,p_effective_date               =>       l_effective_date
     ,p_return_status                =>       l_return_status
     );
     --
   end if;

   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);

end process_com_api;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< start_mass_communication >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE start_mass_communication
  (
   p_assignmentIdListGIn in  varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_id              number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'start_mass_communication_gui';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint start_mass_communication;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Call API
  --
  irc_communications_api.start_mass_communication
    (p_assignmentIdListIn                     => p_assignmentIdListGIn
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
    rollback to start_mass_communication;
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
    rollback to start_mass_communication;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end start_mass_communication;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< close_mass_communication >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE close_mass_communication
  (
   p_assignmentIdListGIn in  varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_communication_id              number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'close_mass_communication_gui';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint close_mass_communication;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Call API
  --
  irc_communications_api.close_mass_communication
    (p_assignmentIdListIn                     => p_assignmentIdListGIn
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
    rollback to close_mass_communication;
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
    rollback to close_mass_communication;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end close_mass_communication;

end irc_communications_swi;

/
