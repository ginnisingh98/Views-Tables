--------------------------------------------------------
--  DDL for Package Body PQP_ERG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_ERG_SWI" As
/* $Header: pqexgswi.pkb 115.0 2003/02/14 02:04:12 rpinjala noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_erg_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_exception_group >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_name         in     varchar2  default null
  ,p_exception_report_id          in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_exception_group_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_output_format                in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_exception_group';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_exception_group_swi;
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
  pqp_erg_api.create_exception_group
    (p_validate                     => l_validate
    ,p_exception_group_name         => p_exception_group_name
    ,p_exception_report_id          => p_exception_report_id
    ,p_legislation_code             => p_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_consolidation_set_id         => p_consolidation_set_id
    ,p_payroll_id                   => p_payroll_id
    ,p_exception_group_id           => p_exception_group_id
    ,p_object_version_number        => p_object_version_number
    ,p_output_format                => p_output_format
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
    rollback to create_exception_group_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_exception_group_id           := null;
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
    rollback to create_exception_group_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_exception_group_id           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_exception_group;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_exception_group >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_exception_group';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_exception_group_swi;
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
  pqp_erg_api.delete_exception_group
    (p_validate                     => l_validate
    ,p_exception_group_id           => p_exception_group_id
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
    rollback to delete_exception_group_swi;
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
    rollback to delete_exception_group_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_exception_group;
-- ----------------------------------------------------------------------------
-- |------------------------< update_exception_group >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_id           in     number    default hr_api.g_number
  ,p_exception_group_name         in     varchar2  default hr_api.g_varchar2
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_output_format                in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_exception_group';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_exception_group_swi;
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
  pqp_erg_api.update_exception_group
    (p_validate                     => l_validate
    ,p_exception_group_id           => p_exception_group_id
    ,p_exception_group_name         => p_exception_group_name
    ,p_exception_report_id          => p_exception_report_id
    ,p_legislation_code             => p_legislation_code
    ,p_business_group_id            => p_business_group_id
    ,p_consolidation_set_id         => p_consolidation_set_id
    ,p_payroll_id                   => p_payroll_id
    ,p_object_version_number        => p_object_version_number
    ,p_output_format                => p_output_format
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
    rollback to update_exception_group_swi;
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
    rollback to update_exception_group_swi;
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
end update_exception_group;
end pqp_erg_swi;

/
