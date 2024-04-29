--------------------------------------------------------
--  DDL for Package Body HR_HIERARCHY_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HIERARCHY_ELEMENT_SWI" As
/* $Header: hroseswi.pkb 115.1 2002/12/03 00:35:56 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_hierarchy_element_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_organization_id_parent       in     number
  ,p_org_structure_version_id     in     number
  ,p_organization_id_child        in     number
  ,p_business_group_id            in     number    default null
  ,p_effective_date               in     date
  ,p_date_from                    in     date
  ,p_security_profile_id          in     number
  ,p_view_all_orgs                in     varchar2
  ,p_end_of_time                  in     date
  ,p_hr_installed                 in     varchar2
  ,p_pa_installed                 in     varchar2
  ,p_pos_control_enabled_flag     in     varchar2
  ,p_warning_raised               in out nocopy varchar2
  ,p_org_structure_element_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate        boolean;
  --
  -- Variables for IN/OUT parameters
  l_warning_raised  varchar2(1);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_hierarchy_element';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_hierarchy_element_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_warning_raised                := p_warning_raised;
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
  hr_hierarchy_element_api.create_hierarchy_element
    (p_validate                     => l_validate
    ,p_organization_id_parent       => p_organization_id_parent
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_organization_id_child        => p_organization_id_child
    ,p_business_group_id            => p_business_group_id
    ,p_effective_date               => p_effective_date
    ,p_date_from                    => p_date_from
    ,p_security_profile_id          => p_security_profile_id
    ,p_view_all_orgs                => p_view_all_orgs
    ,p_end_of_time                  => p_end_of_time
    ,p_hr_installed                 => p_hr_installed
    ,p_pa_installed                 => p_pa_installed
    ,p_pos_control_enabled_flag     => p_pos_control_enabled_flag
    ,p_warning_raised               => p_warning_raised
    ,p_org_structure_element_id     => p_org_structure_element_id
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
    rollback to create_hierarchy_element_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_warning_raised               := l_warning_raised;
    p_org_structure_element_id     := null;
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
    rollback to create_hierarchy_element_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_warning_raised               := l_warning_raised;
    p_org_structure_element_id     := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_hierarchy_element;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_org_structure_element_id     in     number
  ,p_object_version_number        in     number
  ,p_hr_installed                 in     varchar2
  ,p_pa_installed                 in     varchar2
  ,p_exists_in_hierarchy          in out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_exists_in_hierarchy           varchar2 (1);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_hierarchy_element';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_hierarchy_element_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_exists_in_hierarchy           := p_exists_in_hierarchy;
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
  hr_hierarchy_element_api.delete_hierarchy_element
    (p_validate                     => l_validate
    ,p_org_structure_element_id     => p_org_structure_element_id
    ,p_object_version_number        => p_object_version_number
    ,p_hr_installed                 => p_hr_installed
    ,p_pa_installed                 => p_pa_installed
    ,p_exists_in_hierarchy          => p_exists_in_hierarchy
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
    rollback to delete_hierarchy_element_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_exists_in_hierarchy          := l_exists_in_hierarchy;
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
    rollback to delete_hierarchy_element_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_exists_in_hierarchy          := l_exists_in_hierarchy;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_hierarchy_element;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_hierarchy_element >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_hierarchy_element
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_org_structure_element_id     in     number
  ,p_organization_id_parent       in     number    default hr_api.g_number
  ,p_organization_id_child        in     number    default hr_api.g_number
  ,p_pos_control_enabled_flag     in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_hierarchy_element';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_hierarchy_element_swi;
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
  hr_hierarchy_element_api.update_hierarchy_element
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_org_structure_element_id     => p_org_structure_element_id
    ,p_organization_id_parent       => p_organization_id_parent
    ,p_organization_id_child        => p_organization_id_child
    ,p_pos_control_enabled_flag     => p_pos_control_enabled_flag
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
    rollback to update_hierarchy_element_swi;
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
    rollback to update_hierarchy_element_swi;
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
end update_hierarchy_element;
end hr_hierarchy_element_swi;

/
