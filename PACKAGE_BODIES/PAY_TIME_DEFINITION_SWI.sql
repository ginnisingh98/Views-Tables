--------------------------------------------------------
--  DDL for Package Body PAY_TIME_DEFINITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TIME_DEFINITION_SWI" As
/* $Header: pytdfswi.pkb 120.1 2005/06/14 14:13 tvankayl noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_time_definition_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_definition >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_short_name                   in     varchar2
  ,p_definition_name              in     varchar2
  ,p_period_type                  in     varchar2  default null
  ,p_period_unit                  in     varchar2  default null
  ,p_day_adjustment               in     varchar2  default null
  ,p_dynamic_code                 in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_definition_type              in     varchar2  default null
  ,p_number_of_years              in     number    default null
  ,p_start_date                   in     date      default null
  ,p_period_time_definition_id    in     number    default null
  ,p_creator_id                   in     number    default null
  ,p_creator_type                 in     varchar2  default null
  ,p_time_definition_id           in     number
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
  l_time_definition_id           number;
  l_proc    varchar2(72) := g_package ||'create_time_definition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_time_definition_swi;
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
  pay_tdf_ins.set_base_key_value
    (p_time_definition_id => p_time_definition_id
    );
  --
  -- Call API
  --
  pay_time_definition_api.create_time_definition
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_short_name                   => p_short_name
    ,p_definition_name              => p_definition_name
    ,p_period_type                  => p_period_type
    ,p_period_unit                  => p_period_unit
    ,p_day_adjustment               => p_day_adjustment
    ,p_dynamic_code                 => p_dynamic_code
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_definition_type              => p_definition_type
    ,p_number_of_years              => p_number_of_years
    ,p_start_date                   => p_start_date
    ,p_period_time_definition_id    => p_period_time_definition_id
    ,p_creator_id                   => p_creator_id
    ,p_creator_type                 => p_creator_type
    ,p_time_definition_id           => l_time_definition_id
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
    rollback to create_time_definition_swi;
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
    rollback to create_time_definition_swi;
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
end create_time_definition;
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_definition >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
  ,p_definition_name              in     varchar2  default hr_api.g_varchar2
  ,p_period_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_unit                  in     varchar2  default hr_api.g_varchar2
  ,p_day_adjustment               in     varchar2  default hr_api.g_varchar2
  ,p_dynamic_code                 in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_period_time_definition_id    in     number    default hr_api.g_number
  ,p_creator_id                   in     number    default hr_api.g_number
  ,p_creator_type                 in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_time_definition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_time_definition_swi;
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
  pay_time_definition_api.update_time_definition
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_time_definition_id           => p_time_definition_id
    ,p_definition_name              => p_definition_name
    ,p_period_type                  => p_period_type
    ,p_period_unit                  => p_period_unit
    ,p_day_adjustment               => p_day_adjustment
    ,p_dynamic_code                 => p_dynamic_code
    ,p_number_of_years              => p_number_of_years
    ,p_start_date                   => p_start_date
    ,p_period_time_definition_id    => p_period_time_definition_id
    ,p_creator_id                   => p_creator_id
    ,p_creator_type                 => p_creator_type
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
    rollback to update_time_definition_swi;
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
    rollback to update_time_definition_swi;
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
end update_time_definition;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_definition >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_time_definition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_time_definition_swi;
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
  pay_time_definition_api.delete_time_definition
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_time_definition_id           => p_time_definition_id
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
    rollback to delete_time_definition_swi;
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
    rollback to delete_time_definition_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_time_definition;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_time_def_usage >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION chk_time_def_usage
  (p_time_definition_id  IN number
  ,p_definition_type     IN varchar2
  ) Return Number is
  --
  -- Variables for API Boolean parameters
  l_time_def_usage_boolean  boolean;
  l_time_def_usage_number   number;

  l_proc    varchar2(72) := g_package ||'chk_time_def_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  l_time_def_usage_boolean := pay_tdf_bus.chk_time_def_usage
                                ( p_time_definition_id  => p_time_definition_id
                                 ,p_definition_type     => p_definition_type
                                );

  l_time_def_usage_number := hr_api.boolean_to_constant
                                (p_boolean_value => l_time_def_usage_boolean);

  hr_utility.set_location(' Leaving:' || l_proc,20);

  return l_time_def_usage_number;
  --
end chk_time_def_usage;
end pay_time_definition_swi;

/
