--------------------------------------------------------
--  DDL for Package Body PAY_AU_MODULE_PARAMETERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_MODULE_PARAMETERS_SWI" As
/* $Header: pyampswi.pkb 120.0 2005/05/29 02:55 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33);
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_id                    in     number
  ,p_internal_name                in     varchar2  default null
  ,p_data_type                    in     varchar2  default null
  ,p_input_flag                   in     varchar2  default null
  ,p_context_flag                 in     varchar2  default null
  ,p_output_flag                  in     varchar2  default null
  ,p_result_flag                  in     varchar2  default null
  ,p_error_message_flag           in     varchar2  default null
  ,p_enabled_flag                 in     varchar2  default null
  ,p_function_return_flag         in     varchar2  default null
  ,p_external_name                in     varchar2  default null
  ,p_database_item_name           in     varchar2  default null
  ,p_constant_value               in     varchar2  default null
  ,p_module_parameter_id             out nocopy number
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
  l_module_parameter_id          number;
  l_proc    varchar2(72);
Begin
  l_proc    := g_package ||'create_au_module_parameter';
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_au_module_parameter_swi;
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
  pay_amp_ins.set_base_key_value
    (p_module_parameter_id => p_module_parameter_id
    );
  --
  -- Call API
  --
  pay_au_module_parameters_api.create_au_module_parameter
    (p_validate                     => l_validate
    ,p_module_id                    => p_module_id
    ,p_internal_name                => p_internal_name
    ,p_data_type                    => p_data_type
    ,p_input_flag                   => p_input_flag
    ,p_context_flag                 => p_context_flag
    ,p_output_flag                  => p_output_flag
    ,p_result_flag                  => p_result_flag
    ,p_error_message_flag           => p_error_message_flag
    ,p_enabled_flag                 => p_enabled_flag
    ,p_function_return_flag         => p_function_return_flag
    ,p_external_name                => p_external_name
    ,p_database_item_name           => p_database_item_name
    ,p_constant_value               => p_constant_value
    ,p_module_parameter_id          => p_module_parameter_id
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
    rollback to create_au_module_parameter_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_module_parameter_id          := null;
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
    rollback to create_au_module_parameter_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_module_parameter_id          := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_au_module_parameter;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_parameter_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72);
Begin
  l_proc := g_package ||'delete_au_module_parameter';
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_au_module_parameter_swi;
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
  pay_au_module_parameters_api.delete_au_module_parameter
    (p_validate                     => l_validate
    ,p_module_parameter_id          => p_module_parameter_id
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
    rollback to delete_au_module_parameter_swi;
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
    rollback to delete_au_module_parameter_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_au_module_parameter;
-- ----------------------------------------------------------------------------
-- |----------------------< update_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_parameter_id          in     number
  ,p_module_id                    in     number
  ,p_internal_name                in     varchar2  default hr_api.g_varchar2
  ,p_data_type                    in     varchar2  default hr_api.g_varchar2
  ,p_input_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_context_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_output_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_result_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_error_message_flag           in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_function_return_flag         in     varchar2  default hr_api.g_varchar2
  ,p_external_name                in     varchar2  default hr_api.g_varchar2
  ,p_database_item_name           in     varchar2  default hr_api.g_varchar2
  ,p_constant_value               in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72);
Begin
  l_proc    := g_package ||'update_au_module_parameter';
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_au_module_parameter_swi;
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
  pay_au_module_parameters_api.update_au_module_parameter
    (p_validate                     => l_validate
    ,p_module_parameter_id          => p_module_parameter_id
    ,p_module_id                    => p_module_id
    ,p_internal_name                => p_internal_name
    ,p_data_type                    => p_data_type
    ,p_input_flag                   => p_input_flag
    ,p_context_flag                 => p_context_flag
    ,p_output_flag                  => p_output_flag
    ,p_result_flag                  => p_result_flag
    ,p_error_message_flag           => p_error_message_flag
    ,p_enabled_flag                 => p_enabled_flag
    ,p_function_return_flag         => p_function_return_flag
    ,p_external_name                => p_external_name
    ,p_database_item_name           => p_database_item_name
    ,p_constant_value               => p_constant_value
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
    rollback to update_au_module_parameter_swi;
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
    rollback to update_au_module_parameter_swi;
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
end update_au_module_parameter;
begin
  g_package  := 'pay_au_module_parameters_swi.';
end pay_au_module_parameters_swi;

/
