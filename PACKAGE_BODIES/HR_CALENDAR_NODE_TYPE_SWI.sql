--------------------------------------------------------
--  DDL for Package Body HR_CALENDAR_NODE_TYPE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CALENDAR_NODE_TYPE_SWI" As
/* $Header: hrpgtswi.pkb 115.0 2003/04/25 13:06:43 cxsimpso noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'HR_CALENDAR_NODE_TYPE_SWI.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_hierarchy_type               in     varchar2
  ,p_child_node_name              in     varchar2
  ,p_child_value_set              in     varchar2
  ,p_child_node_type              in     varchar2  default null
  ,p_parent_node_type             in     varchar2  default null
  ,p_hier_node_type_id            in     number
  ,p_description                  in     varchar2  default null
  ,p_object_version_number           out nocopy  number
  ,p_return_status                   out  nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_ovn                           number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_hier_node_type_id            number;
  l_proc    varchar2(80) := g_package ||'create_node_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  --
  -- Issue a savepoint
  --
  savepoint create_node_type_swi;
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
  per_pgt_ins.set_base_key_value
    (p_hier_node_type_id => p_hier_node_type_id
    );
  --
  -- Call API
  --

  HR_CALENDAR_NODE_TYPE_API.create_node_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_hierarchy_type               => p_hierarchy_type
    ,p_child_node_name              => p_child_node_name
    ,p_child_node_type              => p_child_node_type
    ,p_child_value_set              => p_child_value_set
    ,p_parent_node_type             => p_parent_node_type
    ,p_description                  => p_description
    ,p_hier_node_type_id            => l_hier_node_type_id
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
    rollback to create_node_type_swi;
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
    rollback to create_node_type_swi;
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
end create_node_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_node_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hier_node_type_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_node_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_node_type_swi;
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
  HR_CALENDAR_NODE_TYPE_API.delete_node_type
    (p_validate                     => l_validate
    ,p_hier_node_type_id            => p_hier_node_type_id
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
    rollback to delete_node_type_swi;
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
    rollback to delete_node_type_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_node_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_node_type >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_node_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_hier_node_type_id            in     number
  ,p_object_version_number        in out nocopy  number
  ,p_child_node_name              in     varchar2  default hr_api.g_varchar2
  ,p_child_value_set              in     varchar2  default hr_api.g_varchar2
  ,p_parent_node_type             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy  varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_node_type';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_node_type_swi;
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
  HR_CALENDAR_NODE_TYPE_API.update_node_type
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_hier_node_type_id            => p_hier_node_type_id
    ,p_object_version_number        => p_object_version_number
    ,p_child_node_name              => p_child_node_name
    ,p_child_value_set              => p_child_value_set
    ,p_parent_node_type             => p_parent_node_type
    ,p_description                  => p_description
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
    rollback to update_node_type_swi;
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
    rollback to update_node_type_swi;
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
end update_node_type;
end HR_CALENDAR_NODE_TYPE_SWI;

/
