--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_CLASS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_CLASS_SWI" As
/* $Header: pypecswi.pkb 120.0 2006/01/25 16:10 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pay_element_class_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_row >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_row
  (x_classification_id            in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_row_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.delete_row
    (x_classification_id            => x_classification_id
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
    rollback to delete_row_swi;
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
    rollback to delete_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_row;
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_row >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_row
  (x_rowid                        in out nocopy varchar2
  ,x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_creation_date                in     date
  ,x_created_by                   in     number
  ,x_last_update_date             in     date
  ,x_last_updated_by              in     number
  ,x_last_update_login            in     number
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  l_rowid                         varchar2(60);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'insert_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_row_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_rowid                         := x_rowid;
  --
  -- Convert constant values to their corresponding boolean value
  --
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.insert_row
    (x_rowid                        => l_rowid
    ,x_classification_id            => x_classification_id
    ,x_business_group_id            => x_business_group_id
    ,x_legislation_code             => x_legislation_code
    ,x_legislation_subgroup         => x_legislation_subgroup
    ,x_costable_flag                => x_costable_flag
    ,x_default_high_priority        => x_default_high_priority
    ,x_default_low_priority         => x_default_low_priority
    ,x_default_priority             => x_default_priority
    ,x_distributable_over_flag      => x_distributable_over_flag
    ,x_non_payments_flag            => x_non_payments_flag
    ,x_costing_debit_or_credit      => x_costing_debit_or_credit
    ,x_parent_classification_id     => x_parent_classification_id
    ,x_create_by_default_flag       => x_create_by_default_flag
    ,x_balance_initialization_flag  => x_balance_initialization_flag
    ,x_object_version_number        => x_object_version_number
    ,x_classification_name          => x_classification_name
    ,x_description                  => x_description
    ,x_creation_date                => x_creation_date
    ,x_created_by                   => x_created_by
    ,x_last_update_date             => x_last_update_date
    ,x_last_updated_by              => x_last_updated_by
    ,x_last_update_login            => x_last_update_login
    ,x_freq_rule_enabled            => x_freq_rule_enabled
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
    rollback to insert_row_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    x_rowid                        := l_rowid;
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
    rollback to insert_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    x_rowid                        := l_rowid;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end insert_row;
-- ----------------------------------------------------------------------------
-- |-------------------------------< lock_row >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lock_row
  (x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'lock_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint lock_row_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.lock_row
    (x_classification_id            => x_classification_id
    ,x_business_group_id            => x_business_group_id
    ,x_legislation_code             => x_legislation_code
    ,x_legislation_subgroup         => x_legislation_subgroup
    ,x_costable_flag                => x_costable_flag
    ,x_default_high_priority        => x_default_high_priority
    ,x_default_low_priority         => x_default_low_priority
    ,x_default_priority             => x_default_priority
    ,x_distributable_over_flag      => x_distributable_over_flag
    ,x_non_payments_flag            => x_non_payments_flag
    ,x_costing_debit_or_credit      => x_costing_debit_or_credit
    ,x_parent_classification_id     => x_parent_classification_id
    ,x_create_by_default_flag       => x_create_by_default_flag
    ,x_balance_initialization_flag  => x_balance_initialization_flag
    ,x_object_version_number        => x_object_version_number
    ,x_classification_name          => x_classification_name
    ,x_description                  => x_description
    ,x_freq_rule_enabled            => x_freq_rule_enabled
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
    rollback to lock_row_swi;
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
    rollback to lock_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end lock_row;
-- ----------------------------------------------------------------------------
-- |------------------------< set_translation_globals >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'set_translation_globals';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint set_translation_globals_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.set_translation_globals
    (p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
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
    rollback to set_translation_globals_swi;
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
    rollback to set_translation_globals_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end set_translation_globals;
-- ----------------------------------------------------------------------------
-- |-----------------------------< translate_row >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE translate_row
  (x_e_classification_name        in     varchar2
  ,x_e_legislation_code           in     varchar2
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_owner                        in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'translate_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint translate_row_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.translate_row
    (x_e_classification_name        => x_e_classification_name
    ,x_e_legislation_code           => x_e_legislation_code
    ,x_classification_name          => x_classification_name
    ,x_description                  => x_description
    ,x_owner                        => x_owner
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
    rollback to translate_row_swi;
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
    rollback to translate_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end translate_row;
-- ----------------------------------------------------------------------------
-- |------------------------------< update_row >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_row
  (x_classification_id            in     number
  ,x_business_group_id            in     number
  ,x_legislation_code             in     varchar2
  ,x_legislation_subgroup         in     varchar2
  ,x_costable_flag                in     varchar2
  ,x_default_high_priority        in     number
  ,x_default_low_priority         in     number
  ,x_default_priority             in     number
  ,x_distributable_over_flag      in     varchar2
  ,x_non_payments_flag            in     varchar2
  ,x_costing_debit_or_credit      in     varchar2
  ,x_parent_classification_id     in     number
  ,x_create_by_default_flag       in     varchar2
  ,x_balance_initialization_flag  in     varchar2
  ,x_object_version_number        in     number
  ,x_classification_name          in     varchar2
  ,x_description                  in     varchar2
  ,x_last_update_date             in     date
  ,x_last_updated_by              in     number
  ,x_last_update_login            in     number
  ,x_mesg_flg                        out nocopy number
  ,x_freq_rule_enabled            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_mesg_flg                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_row';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_row_swi;
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
  l_mesg_flg :=
    hr_api.constant_to_boolean
      (p_constant_value => x_mesg_flg);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.update_row
    (x_classification_id            => x_classification_id
    ,x_business_group_id            => x_business_group_id
    ,x_legislation_code             => x_legislation_code
    ,x_legislation_subgroup         => x_legislation_subgroup
    ,x_costable_flag                => x_costable_flag
    ,x_default_high_priority        => x_default_high_priority
    ,x_default_low_priority         => x_default_low_priority
    ,x_default_priority             => x_default_priority
    ,x_distributable_over_flag      => x_distributable_over_flag
    ,x_non_payments_flag            => x_non_payments_flag
    ,x_costing_debit_or_credit      => x_costing_debit_or_credit
    ,x_parent_classification_id     => x_parent_classification_id
    ,x_create_by_default_flag       => x_create_by_default_flag
    ,x_balance_initialization_flag  => x_balance_initialization_flag
    ,x_object_version_number        => x_object_version_number
    ,x_classification_name          => x_classification_name
    ,x_description                  => x_description
    ,x_last_update_date             => x_last_update_date
    ,x_last_updated_by              => x_last_updated_by
    ,x_last_update_login            => x_last_update_login
    ,x_mesg_flg                     => l_mesg_flg
    ,x_freq_rule_enabled            => x_freq_rule_enabled
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  x_mesg_flg :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_mesg_flg
      );
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
    rollback to update_row_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    x_mesg_flg                     := null;
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
    rollback to update_row_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    x_mesg_flg                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_row;
-- ----------------------------------------------------------------------------
-- |-------------------------< validate_translation >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_translation
  (classification_id              in     number
  ,language                       in     varchar2
  ,classification_name            in     varchar2
  ,description                    in     varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'validate_translation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint validate_translation_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pay_element_class_pkg.validate_translation
    (classification_id              => classification_id
    ,language                       => language
    ,classification_name            => classification_name
    ,description                    => description
    ,p_business_group_id            => p_business_group_id
    ,p_legislation_code             => p_legislation_code
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
    rollback to validate_translation_swi;
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
    rollback to validate_translation_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end validate_translation;
end pay_element_class_swi;

/
