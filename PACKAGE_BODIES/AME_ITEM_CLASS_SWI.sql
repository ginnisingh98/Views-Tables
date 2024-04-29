--------------------------------------------------------
--  DDL for Package Body AME_ITEM_CLASS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITEM_CLASS_SWI" As
/* $Header: amitcswi.pkb 120.1 2005/12/08 21:02 santosin noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ame_item_class_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_name                         in     varchar2
  ,p_user_item_class_name         in     varchar2
  ,p_item_class_id                in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_item_class_id                number;
  l_proc    varchar2(72) := g_package ||'create_ame_item_class';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_item_class_swi;
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
  ame_itc_ins.set_base_key_value
    (p_item_class_id => p_item_class_id
    );
  --
  -- Call API
  --
  ame_item_class_api.create_ame_item_class
    (p_validate                     => l_validate
    ,p_name                         => p_name
    ,p_user_item_class_name         => p_user_item_class_name
    ,p_item_class_id                => l_item_class_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to create_ame_item_class_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to create_ame_item_class_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_item_class;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_class_id                in     number
  ,p_user_item_class_name         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'update_ame_item_class';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_item_class_swi;
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
  ame_item_class_api.update_ame_item_class
    (p_validate                     => l_validate
    ,p_item_class_id                => p_item_class_id
    ,p_user_item_class_name         => p_user_item_class_name
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to update_ame_item_class_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to update_ame_item_class_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_ame_item_class;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_class_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_ame_item_class';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_item_class_swi;
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
  ame_item_class_api.delete_ame_item_class
    (p_validate                     => l_validate
    ,p_item_class_id                => p_item_class_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to delete_ame_item_class_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to delete_ame_item_class_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_ame_item_class;
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_id_query                in     varchar2
  ,p_item_class_order_number      in     number
  ,p_item_class_par_mode          in     varchar2
  ,p_item_class_sublist_mode      in     varchar2
  ,p_application_id               in out nocopy number
  ,p_item_class_id                in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_application_id                number;
  l_item_class_id                 number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_ame_item_class_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_itemclass_usage_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_application_id                := p_application_id;
  l_item_class_id                 := p_item_class_id;
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
  ame_item_class_api.create_ame_item_class_usage
    (p_validate                     => l_validate
    ,p_item_id_query                => p_item_id_query
    ,p_item_class_order_number      => p_item_class_order_number
    ,p_item_class_par_mode          => p_item_class_par_mode
    ,p_item_class_sublist_mode      => p_item_class_sublist_mode
    ,p_application_id               => p_application_id
    ,p_item_class_id                => p_item_class_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to create_ame_itemclass_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_application_id               := l_application_id;
    p_item_class_id                := l_item_class_id;
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to create_ame_itemclass_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_application_id               := l_application_id;
    p_item_class_id                := l_item_class_id;
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_item_class_usage;
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_item_class_id                in     number
  ,p_item_id_query                in     varchar2  default hr_api.g_varchar2
  ,p_item_class_order_number      in     number    default hr_api.g_number
  ,p_item_class_par_mode          in     varchar2  default hr_api.g_varchar2
  ,p_item_class_sublist_mode      in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'update_ame_item_class_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_ameitem_class_usage_swi;
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
  ame_item_class_api.update_ame_item_class_usage
    (p_validate                     => l_validate
    ,p_application_id               => p_application_id
    ,p_item_class_id                => p_item_class_id
    ,p_item_id_query                => p_item_id_query
    ,p_item_class_order_number      => p_item_class_order_number
    ,p_item_class_par_mode          => p_item_class_par_mode
    ,p_item_class_sublist_mode      => p_item_class_sublist_mode
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to update_ame_itemclass_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to update_ame_itemclass_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_ame_item_class_usage;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_item_class_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_ame_item_class_usage';
  l_found   varchar2(1);
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_itemclass_usage_swi;
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
  ame_item_class_api.delete_ame_item_class_usage
    (p_validate                     => l_validate
    ,p_application_id               => p_application_id
    ,p_item_class_id                => p_item_class_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to delete_ame_itemclass_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    fnd_msg_pub.set_search_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_name('PER','AME_400774_ITU_CHILD_EXISTS');
    l_found := fnd_msg_pub.change_msg;
    fnd_msg_pub.set_search_name('PAY','HR_7215_DT_CHILD_EXISTS');
    l_found := fnd_msg_pub.delete_msg;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_ame_itemclass_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_ame_item_class_usage;
end ame_item_class_swi;

/
