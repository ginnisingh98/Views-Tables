--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMN_SWI" As
/* $Header: pypucswi.pkb 120.0 2005/05/29 07:59 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_user_column_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_user_column >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_user_column
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_user_table_id                in     number
  ,p_formula_id                   in     number    default null
  ,p_user_column_name             in     varchar2
  ,p_user_column_id                  out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_user_column';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_user_column_swi;
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
  pay_user_column_api.create_user_column
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
    ,p_user_table_id                => p_user_table_id
    ,p_formula_id                   => p_formula_id
    ,p_user_column_name             => p_user_column_name
    ,p_user_column_id               => p_user_column_id
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
    rollback to create_user_column_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_user_column_id               := null;
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
    rollback to create_user_column_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_user_column_id               := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_user_column;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_user_column >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_user_column
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_user_column_id               in     number
  ,p_user_column_name             in     varchar2  default hr_api.g_varchar2
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_formula_warning               boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_user_column';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_user_column_swi;
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
  pay_user_column_api.update_user_column
    (p_validate                     => l_validate
    ,p_user_column_id               => p_user_column_id
    ,p_user_column_name             => p_user_column_name
    ,p_formula_id                   => p_formula_id
    ,p_object_version_number        => p_object_version_number
    ,p_formula_warning              => l_formula_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_formula_warning then
     fnd_message.set_name('PAY', 'PAY_33176_UCOL_FF_NOT_FOUND ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
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
    rollback to update_user_column_swi;
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
    rollback to update_user_column_swi;
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
end update_user_column;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_user_column >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_user_column
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_user_column_id               in     number
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
  l_proc    varchar2(72) := g_package ||'delete_user_column';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_user_column_swi;
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
  pay_user_column_api.delete_user_column
    (p_validate                     => l_validate
    ,p_user_column_id               => p_user_column_id
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
    rollback to delete_user_column_swi;
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
    rollback to delete_user_column_swi;
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
end delete_user_column;
end pay_user_column_swi;

/
