--------------------------------------------------------
--  DDL for Package Body HR_RATE_VALUES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RATE_VALUES_SWI" AS
/* $Header: hrpgrswi.pkb 115.9 2004/04/01 10:46 svittal noship $ */
--
-- Package variables
-- Global Variables
l_trans_tbl hr_transaction_ss.transaction_table;
g_package      Varchar2(30):='HR_RATE_VALUES_SWI';

--
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_assignment_rate_value >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_assignment_rate_value
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_rate_id                      in     number
  ,p_assignment_id                in     number
  ,p_rate_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_value                        in     varchar2
  ,p_grade_rule_id                in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables

  l_grade_rule_id                number;
  l_grade_rule_id_temp           number;
  l_proc    varchar2(72) := g_package ||'create_assignment_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  l_grade_rule_id_temp := p_grade_rule_id;
  savepoint create_assignment_rate_value;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  --
  -- Call API
  --
  hr_rate_values_api.create_assignment_rate_value
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_rate_id                      => p_rate_id
    ,p_assignment_id                => p_assignment_id
    ,p_rate_type                    => p_rate_type
    ,p_currency_code                => p_currency_code
    ,p_value                        => p_value
    ,p_grade_rule_id                => l_grade_rule_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    );
    p_grade_rule_id := l_grade_rule_id;
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
    rollback to create_assignment_rate_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to create_assignment_rate_value;


    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_grade_rule_id := l_grade_rule_id_temp;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_assignment_rate_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< create_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_rate_id                      in     number
  ,p_grade_or_spinal_point_id     in     number
  ,p_rate_type                    in     varchar2
  ,p_currency_code                in     varchar2  default null
  ,p_maximum                      in     varchar2  default null
  ,p_mid_value                    in     varchar2  default null
  ,p_minimum                      in     varchar2  default null
  ,p_sequence                     in     number    default null
  ,p_value                        in     varchar2  default null
  ,p_grade_rule_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_grade_rule_id                number;
  l_proc    varchar2(72) := g_package ||'create_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_rate_value_swi;
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
  pay_pgr_ins.set_base_key_value
    (p_grade_rule_id => p_grade_rule_id
    );
  --
  -- Call API
  --
  hr_rate_values_api.create_rate_value
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_rate_id                      => p_rate_id
    ,p_grade_or_spinal_point_id     => p_grade_or_spinal_point_id
    ,p_rate_type                    => p_rate_type
    ,p_currency_code                => p_currency_code
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_sequence                     => p_sequence
    ,p_value                        => p_value
    ,p_grade_rule_id                => l_grade_rule_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to create_rate_value_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to create_rate_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_rate_value;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_rate_value >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_assignment_rate_value
  (p_validate                     in     boolean   default false
  ,p_grade_rule_id                in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_assignment_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_assignment_rate_value;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  --
  -- Call API
  --
  hr_rate_values_api.update_assignment_rate_value
    (p_validate                     => p_validate
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_currency_code                => p_currency_code
    ,p_value                        => p_value
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to update_assignment_rate_value;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_assignment_rate_value;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_assignment_rate_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_grade_rule_id                in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_maximum                      in     varchar2  default hr_api.g_varchar2
  ,p_mid_value                    in     varchar2  default hr_api.g_varchar2
  ,p_minimum                      in     varchar2  default hr_api.g_varchar2
  ,p_sequence                     in     number    default hr_api.g_number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'update_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_rate_value_swi;
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
  hr_rate_values_api.update_rate_value
    (p_validate                     => l_validate
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_currency_code                => p_currency_code
    ,p_maximum                      => p_maximum
    ,p_mid_value                    => p_mid_value
    ,p_minimum                      => p_minimum
    ,p_sequence                     => p_sequence
    ,p_value                        => p_value
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to update_rate_value_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_rate_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_rate_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_rate_value
  (p_validate                     in     boolean    default false
  ,p_grade_rule_id                in     number
  ,p_datetrack_mode               in     varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rate_value_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_rate_values_api.delete_rate_value
    (p_validate                     => l_validate
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to delete_rate_value_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to delete_rate_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_rate_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_rate_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_grade_rule_id                in     number
  ,p_datetrack_mode               in     varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_rate_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rate_value_swi;
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
  hr_rate_values_api.delete_rate_value
    (p_validate                     => l_validate
    ,p_grade_rule_id                => p_grade_rule_id
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_effective_date               => p_effective_date
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to delete_rate_value_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to delete_rate_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_rate_value;
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_grade_rule_id                in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_validation_start_date           out nocopy date
  ,p_validation_end_date             out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'lck';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint lck_swi;
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
  hr_rate_values_api.lck
    (p_grade_rule_id                => p_grade_rule_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_validation_start_date        => p_validation_start_date
    ,p_validation_end_date          => p_validation_end_date
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
    rollback to lck_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_validation_start_date        := null;
    p_validation_end_date          := null;
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
    rollback to lck_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_validation_start_date        := null;
    p_validation_end_date          := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end lck;
-- ---------------------------------------------------------------------------
-- ---------------------------- < process_api > ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure is used by the WF procedures to commit or validate
--          the transaction step with HRMS system
-- ---------------------------------------------------------------------------
PROCEDURE process_api
  (p_validate             in  boolean  default false
  ,p_transaction_step_id  in  number   default null
  ,p_effective_date       in  varchar2 default null
  ) is

  l_return_status    VARCHAR2(5) := 'S';
  l_asg_rate_rec     HR_ASG_RATE_TYPE;
  l_effective_date   date;
  l_record_status    VARCHAR2(15);
  l_assignment_id    NUMBER;

  l_po_line_id NUMBER;
  l_stp_value_name varchar2(20);
  l_po_installed boolean default false;

  cursor get_step_values (p_transaction_step_id in number) is
  select name, number_value from hr_api_transaction_values
  where transaction_step_id = p_transaction_step_id
  and name = 'P_PO_LINE_ID';

  not_a_valid_po_txn exception;

Begin


  -- check to see if there exists a old SFL (before PO integration) and trying
  -- to retrieve this SFL after PO is installed.
  -- to be modified
  --l_po_installed :=  hr_po_info.full_cwk_enabled;

  if l_po_installed then
    open get_step_values(p_transaction_step_id);
    fetch get_step_values into l_stp_value_name, l_po_line_id;
    if get_step_values%NOTFOUND then
      raise not_a_valid_po_txn;
    else
      return;
    end if;
  end if;

  l_effective_date:= to_date(hr_transaction_ss.get_wf_effective_date
                               (p_transaction_step_id => p_transaction_step_id),
                             hr_transaction_ss.g_date_format
                             );
  dt_fndate.set_effective_date(l_effective_date);
-- start registration
-- If its a new user registration flow then the assignmentId which is coming
-- from transaction table will not be valid because the person has just been
-- created by the process_api of the hr_process_person_ss.process_api.
-- We can get that person Id and assignment id by making a call
-- to the global parameters but we need to branch out the code.
-- Adding the session id check to avoid connection pooling problems.
  if (( hr_process_person_ss.g_assignment_id is not null) and
     (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
  then
    -- Set the Assignment Id to the one just created, don't use the
    -- transaction table.
    l_assignment_id := hr_process_person_ss.g_assignment_id;
  else
    l_assignment_id := hr_transaction_api.get_number_value(p_transaction_step_id, 'P_ASSIGNMENT_ID');
  end if;
-- end registration
--
  l_asg_rate_rec := HR_ASG_RATE_TYPE
                      (hr_transaction_api.get_number_value(p_transaction_step_id, 'P_BUSINESS_GROUP_ID')
                      ,hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_RATE_NAME')
                      ,hr_transaction_api.get_number_value(p_transaction_step_id, 'P_RATE_ID')
                      ,hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_RATE_BASIS_NAME')
                      ,hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_CURRENCY_NAME')
                      ,l_assignment_id
                      ,hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_CURRENCY_CODE')
                      ,hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_VALUE')
                      ,hr_transaction_api.get_number_value(p_transaction_step_id, 'P_GRADE_RULE_ID')
                      ,null
                      ,hr_transaction_api.get_number_value(p_transaction_step_id, 'P_OBJECT_VERSION_NUMBER')
                      ,l_effective_date
                      ,hr_transaction_api.get_date_value(p_transaction_step_id, 'P_EFFECTIVE_END_DATE')
                      ,null
                      );

  l_record_status := hr_transaction_api.get_varchar2_value(p_transaction_step_id, 'P_ASG_RATE_REC_STATUS');
  validate_record
      (p_validate       => false
      ,p_asg_rate_rec   => l_asg_rate_rec
      ,p_record_status  => l_record_status
      ,p_effective_date => l_effective_date
      ,p_return_status  => l_return_status
      );
 exception
    when not_a_valid_po_txn then
    hr_utility.set_message(800, 'HR_NOT_VALID_PO_TXN');
    hr_utility.raise_error;
    when others then
    raise;
end process_api;

PROCEDURE process_save
  (p_mode                  in     VARCHAR2 default '#'
  ,p_flow_mode             in     VARCHAR2 default NULL
  ,p_item_type             in     VARCHAR2 default hr_api.g_varchar2
  ,p_item_key              in     VARCHAR2 default hr_api.g_varchar2
  ,p_activity_id           in     VARCHAR2 default hr_api.g_varchar2
  ,p_effective_date_option in     VARCHAR2 default hr_api.g_varchar2
  ,p_asg_rate_tab          in     HR_ASG_RATE_TABLE
  ,p_return_status            out nocopy VARCHAR2
  ,p_transaction_step_id      out nocopy NUMBER
  ) is

l_login_person_id     NUMBER := NULL;
l_effective_date      DATE;
l_transaction_id      NUMBER := NULL;
l_transaction_step_id NUMBER := NULL;
l_return_status       VARCHAR2(5) := 'S';
l_transaction_ovn     NUMBER := NULL;
l_result              VARCHAR2(100);
l_count               NUMBER;
l_asg_rate_rec        HR_ASG_RATE_TYPE;
l_record_status       VARCHAR2(15) := g_no_change;
l_rec_old_end_date    DATE := null;
l_validate            BOOLEAN := true;

cursor csr_basetb_data(grade_id NUMBER, business_gp_id NUMBER,
  asg_id NUMBER, effective_date date) is
  select currency_code,
         value,
         effective_end_date
  from pay_grade_rules_f pgr
  where pgr.grade_rule_id = nvl(grade_id, -1)
  and pgr.rate_type = 'A'
  and pgr.business_group_id = business_gp_id
  and pgr.grade_or_spinal_point_id = asg_id
  and effective_date between pgr.effective_start_date
  and pgr.effective_end_date;

l_current_rec csr_basetb_data%rowtype;
Begin
  l_login_person_id := fnd_global.employee_id;
  l_transaction_id :=
    hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);
  l_asg_rate_rec := p_asg_rate_tab(1);


  if l_transaction_id is NULL
  then
    hr_transaction_ss.start_transaction
      (itemtype                => p_item_type
      ,itemkey                 => p_item_key
      ,actid                   => p_activity_id
      ,funmode                 => 'RUN'
      ,p_effective_date_option => p_effective_date_option
      ,p_login_person_id       => l_login_person_id
      ,result                  => l_result
      );
    l_transaction_id :=
      hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);
  end if;

  open csr_basetb_data(l_asg_rate_rec.grade_rule_id,
    l_asg_rate_rec.business_group_id, l_asg_rate_rec.assignment_id,
    l_asg_rate_rec.effective_start_date);
  fetch csr_basetb_data into l_current_rec;
  if csr_basetb_data%notfound
  then
    -- New Record - INSERT MODE
    close csr_basetb_data;
    if (l_asg_rate_rec.effective_end_date is not null and
       (trunc(l_asg_rate_rec.effective_end_date) <> trunc(hr_api.g_eot)))
    then
      l_record_status := g_insert_delete;
    else
      l_record_status := g_insert_only;
    end if;
  else
    -- Existing Record - UPDATE MODE
    close csr_basetb_data;
    if l_current_rec.value = l_asg_rate_rec.value and
       l_current_rec.currency_code = l_asg_rate_rec.currency_code
    then
      if is_date_change_required(l_asg_rate_rec.effective_end_date,
         l_current_rec.effective_end_date)
      then
         l_record_status := g_delete_only;
         --if l_asg_rate_rec.effective_end_date is null
         --then
         --  l_asg_rate_rec.effective_end_date := hr_api.g_eot;
         --end if;
      end if;
    else
      if is_date_change_required(l_asg_rate_rec.effective_end_date,
         l_current_rec.effective_end_date)
      then
         l_record_status := g_update_delete;
         --if l_asg_rate_rec.effective_end_date is null
         --then
         --  l_asg_rate_rec.effective_end_date := hr_api.g_eot;
         --end if;
      else
        l_record_status := g_update_only;
      end if;
    end if;
  end if;

  if l_record_status = g_no_change
  then
    if l_asg_rate_rec.transaction_step_id is not null
    then
      delete from hr_api_transaction_values
        where transaction_step_id = l_asg_rate_rec.transaction_step_id;
      delete from hr_api_transaction_steps
        where transaction_step_id = l_asg_rate_rec.transaction_step_id;
    end if;
    goto end_of_process;
  end if;


  begin
    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      savepoint newhire_point;
      hr_new_user_reg_ss.process_selected_transaction
        (p_item_type => p_item_type
        ,p_item_key => p_item_key);
      if (( hr_process_person_ss.g_assignment_id is not null) and
         (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
      then
       -- Set the Assignment Id to the one just created, don't use the
       -- transaction table.
       l_asg_rate_rec.assignment_id := hr_process_person_ss.g_assignment_id;
      end if;
    end if;
    --For SFL no validation is required.
    if nvl(p_mode,'#') <> 'S'
    then
      validate_record
        (p_validate       => l_validate
        ,p_asg_rate_rec   => l_asg_rate_rec
        ,p_record_status  => l_record_status
        ,p_effective_date => l_effective_date
        ,p_return_status  => l_return_status
        );
    end if;

    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      rollback to newhire_point;
    end if;

  exception
  when others then
    -- Rollback dummy person in case of NewHire flow
    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      rollback to newhire_point;
    end if;
  end;

  --Not saving to tx table if l_return_message <> 'S' and l_return_message
  --is set in the validate_record call
  l_transaction_step_id := l_asg_rate_rec.transaction_step_id;
  if l_return_status = 'S'
  then
    if l_transaction_step_id is NULL
    then
      hr_transaction_api.create_transaction_step
	    (p_validate              => false
        ,p_creator_person_id     => l_login_person_id
        ,p_transaction_id        => l_transaction_id
        ,p_api_name              => g_package||'.PROCESS_API'
        ,p_item_type             => p_item_type
        ,p_item_key              => p_item_key
	    ,p_activity_id           => p_activity_id
	    ,p_transaction_step_id   => l_transaction_step_id
        ,p_object_version_number => l_transaction_ovn
        );
    end if;
    -- populating transaction table

    l_count := 1;
    l_trans_tbl(l_count).param_name := 'P_BUSINESS_GROUP_ID';
    l_trans_tbl(l_count).param_value := l_asg_rate_rec.business_group_id;
 	l_trans_tbl(l_count).param_data_type := 'NUMBER';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_RATE_NAME';
    l_trans_tbl(l_count).param_value := l_asg_rate_rec.rate_name;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_RATE_ID';
    l_trans_tbl(l_count).param_value := l_asg_rate_rec.rate_id;
 	l_trans_tbl(l_count).param_data_type := 'NUMBER';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_RATE_BASIS_NAME';
  	l_trans_tbl(l_count).param_value := l_asg_rate_rec.rate_basis_name;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_CURRENCY_NAME';
    l_trans_tbl(l_count).param_value := l_asg_rate_rec.currency_name;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_ASSIGNMENT_ID';
  	l_trans_tbl(l_count).param_value := l_asg_rate_rec.assignment_id;
    l_trans_tbl(l_count).param_data_type := 'NUMBER';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_CURRENCY_CODE';
    l_trans_tbl(l_count).param_value := l_asg_rate_rec.currency_code;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_VALUE';
  	l_trans_tbl(l_count).param_value := l_asg_rate_rec.value;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_GRADE_RULE_ID';
  	l_trans_tbl(l_count).param_value := l_asg_rate_rec.grade_rule_id;
 	l_trans_tbl(l_count).param_data_type := 'NUMBER';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
    l_trans_tbl(l_count).param_value :=
      l_asg_rate_rec.object_version_number;
 	l_trans_tbl(l_count).param_data_type := 'NUMBER';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_EFFECTIVE_START_DATE';
    l_trans_tbl(l_count).param_value :=
      to_char(l_asg_rate_rec.effective_start_date,hr_transaction_ss.g_date_format);
 	l_trans_tbl(l_count).param_data_type := 'DATE';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_EFFECTIVE_END_DATE';
    l_trans_tbl(l_count).param_value :=
      to_char(l_asg_rate_rec.effective_end_date,hr_transaction_ss.g_date_format);
 	l_trans_tbl(l_count).param_data_type := 'DATE';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
    begin
      l_trans_tbl(l_count).param_value :=
        wf_engine.GetActivityAttrText(p_item_type,p_item_key,
          p_activity_id, 'HR_REVIEW_REGION_ITEM', False);
    exception
    when others then
      l_trans_tbl(l_count).param_value := 'HrAssignmentRate';
    end;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
    l_trans_tbl(l_count).param_value := p_activity_id;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_ASG_RATE_REC_STATUS';
    l_trans_tbl(l_count).param_value := l_record_status;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';


    hr_transaction_ss.save_transaction_step
      (p_item_type           => p_item_type
      ,p_item_key            => p_item_key
      ,p_actid               => p_activity_id
      ,p_login_person_id     => l_login_person_id
      ,p_transaction_step_id => l_transaction_step_id
      ,p_api_name            => g_package||'.PROCESS_API'
      ,p_transaction_data    => l_trans_tbl
      );
    p_transaction_step_id := l_transaction_step_id;
  end if;
  <<end_of_process>>
  p_return_status := l_return_status;
Exception
When others then
  p_return_status := 'E';
  p_transaction_step_id := null;
End process_save;

PROCEDURE po_process_save
  (p_mode                  in     VARCHAR2 default '#'
  ,p_flow_mode             in     VARCHAR2 default NULL
  ,p_item_type             in     VARCHAR2 default hr_api.g_varchar2
  ,p_item_key              in     VARCHAR2 default hr_api.g_varchar2
  ,p_activity_id           in     VARCHAR2 default hr_api.g_varchar2
  ,p_effective_date_option in     VARCHAR2 default hr_api.g_varchar2
  ,p_po_line_id            in     NUMBER
  ,p_return_status            out nocopy VARCHAR2
  ,p_transaction_step_id      out nocopy NUMBER
  ) is

l_login_person_id     NUMBER := NULL;
l_effective_date      DATE;
l_transaction_id      NUMBER := NULL;
l_transaction_step_id NUMBER := NULL;
l_return_status       VARCHAR2(5) := 'S';
l_transaction_ovn     NUMBER := NULL;
l_result              VARCHAR2(100);
l_count               NUMBER;
l_asg_rate_rec        HR_ASG_RATE_TYPE;
l_record_status       VARCHAR2(15) := g_no_change;
l_rec_old_end_date    DATE := null;
l_validate            BOOLEAN := true;


Begin
  l_login_person_id := fnd_global.employee_id;
  l_transaction_id :=
    hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);

  if l_transaction_id is NULL
  then
    hr_transaction_ss.start_transaction
      (itemtype                => p_item_type
      ,itemkey                 => p_item_key
      ,actid                   => p_activity_id
      ,funmode                 => 'RUN'
      ,p_effective_date_option => p_effective_date_option
      ,p_login_person_id       => l_login_person_id
      ,result                  => l_result
      );
    l_transaction_id :=
      hr_transaction_ss.get_transaction_id(p_item_type ,p_item_key);
  end if;



  begin
    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      savepoint newhire_point;
      hr_new_user_reg_ss.process_selected_transaction
        (p_item_type => p_item_type
        ,p_item_key => p_item_key);
      if (( hr_process_person_ss.g_assignment_id is not null) and
         (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID))
      then
       -- Set the Assignment Id to the one just created, don't use the
       -- transaction table.
       l_asg_rate_rec.assignment_id := hr_process_person_ss.g_assignment_id;
      end if;
    end if;

    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      rollback to newhire_point;
    end if;

  exception
  when others then
    -- Rollback dummy person in case of NewHire flow
    if p_flow_mode is not null and
       p_flow_mode = hr_process_assignment_ss.g_new_hire_registration
    then
      rollback to newhire_point;
    end if;
  end;

  --Not saving to tx table if l_return_message <> 'S' and l_return_message
  --is set in the validate_record call
      hr_transaction_api.create_transaction_step
	    (p_validate              => false
        ,p_creator_person_id     => l_login_person_id
        ,p_transaction_id        => l_transaction_id
        ,p_api_name              => g_package||'.PROCESS_API'
        ,p_item_type             => p_item_type
        ,p_item_key              => p_item_key
	    ,p_activity_id           => p_activity_id
	    ,p_transaction_step_id   => l_transaction_step_id
        ,p_object_version_number => l_transaction_ovn
        );
    -- populating transaction table
    -- to be changed
    -- may not need assignment_id, po_header_id in the values

    l_count := 1;
    l_trans_tbl(l_count).param_name := 'P_PO_LINE_ID';
    l_trans_tbl(l_count).param_value := p_po_line_id;
 	l_trans_tbl(l_count).param_data_type := 'NUMBER';


    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_REVIEW_PROC_CALL';
    l_trans_tbl(l_count).param_value := 'POAsgnRatesRN';
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
/*
    begin
      l_trans_tbl(l_count).param_value :=
        wf_engine.GetActivityAttrText(p_item_type,p_item_key,
          p_activity_id, 'HR_REVIEW_REGION_ITEM', False);
    exception
    when others then
      l_trans_tbl(l_count).param_value := 'HrPOAssignmentRate';
    end;
    l_trans_tbl(l_count).param_data_type := 'VARCHAR2';
*/
    l_count := l_count+1;
    l_trans_tbl(l_count).param_name := 'P_REVIEW_ACTID';
    l_trans_tbl(l_count).param_value := p_activity_id;
 	l_trans_tbl(l_count).param_data_type := 'VARCHAR2';

    hr_transaction_ss.save_transaction_step
      (p_item_type           => p_item_type
      ,p_item_key            => p_item_key
      ,p_actid               => p_activity_id
      ,p_login_person_id     => l_login_person_id
      ,p_transaction_step_id => l_transaction_step_id
      ,p_api_name            => g_package||'.PROCESS_API'
      ,p_transaction_data    => l_trans_tbl
      );
    p_transaction_step_id := l_transaction_step_id;
  <<end_of_process>>
  p_return_status := l_return_status;
Exception
When others then
  p_return_status := 'E';
  p_transaction_step_id := null;
End po_process_save;



PROCEDURE get_transaction_rownum
  (p_item_type      in     VARCHAR2
  ,p_item_key       in     VARCHAR2
  ,p_assignment_id  in     VARCHAR2
  ,p_business_gp_id in     VARCHAR2
  ,p_row_num           out nocopy VARCHAR2
  ) is

  l_row_num  NUMBER := 0;
Begin
  populate_transaction_details
    (p_item_type      => p_item_type
    ,p_item_key       => p_item_key
    ,p_assignment_id  => p_assignment_id
    ,p_business_gp_id => p_business_gp_id
    );
  p_row_num := to_char(g_asg_rate_table.count);
Exception
When others then
  p_row_num := null;
End;

PROCEDURE populate_transaction_details
  (p_item_type      in     VARCHAR2
  ,p_item_key       in     VARCHAR2
  ,p_assignment_id  in     VARCHAR2
  ,p_business_gp_id in     VARCHAR2
  ) is
  cursor csr_asg_rate_tx is
      SELECT oo.*,
             rownum row_index
      FROM (
      SELECT a.varchar2_value rate_name,
             b.number_value rate_id,
             c.varchar2_value rate_basis_name,
             d.varchar2_value currency_name,
             e.varchar2_value value,
             f.date_value effective_start_date,
             decode(trunc(g.date_value), trunc(hr_api.g_eot), null, g.date_value) effective_end_date,
             h.number_value object_version_number,
             i.number_value grade_rule_id,
             j.varchar2_value currency_code,
             to_char(s.transaction_step_id) transaction_step_id
      FROM hr_api_transaction_steps s,
           hr_api_transaction_values a, hr_api_transaction_values b,
           hr_api_transaction_values c, hr_api_transaction_values d,
           hr_api_transaction_values e, hr_api_transaction_values f,
           hr_api_transaction_values g, hr_api_transaction_values h,
           hr_api_transaction_values i, hr_api_transaction_values j
      WHERE s.item_type = p_item_type
      AND s.item_key = p_item_key
      AND s.api_name = g_package||'.PROCESS_API'
      AND a.transaction_step_id = s.transaction_step_id
      AND a.name = 'P_RATE_NAME'
      AND b.transaction_step_id = s.transaction_step_id
      AND b.name = 'P_RATE_ID'
      AND c.transaction_step_id = s.transaction_step_id
      AND c.name = 'P_RATE_BASIS_NAME'
      AND d.transaction_step_id = s.transaction_step_id
      AND d.name = 'P_CURRENCY_NAME'
      AND e.transaction_step_id = s.transaction_step_id
      AND e.name = 'P_VALUE'
      AND f.transaction_step_id = s.transaction_step_id
      AND f.name = 'P_EFFECTIVE_START_DATE'
      AND g.transaction_step_id = s.transaction_step_id
      AND g.name = 'P_EFFECTIVE_END_DATE'
      AND h.transaction_step_id = s.transaction_step_id
      AND h.name = 'P_OBJECT_VERSION_NUMBER'
      AND i.transaction_step_id = s.transaction_step_id
      AND i.name = 'P_GRADE_RULE_ID'
      AND j.transaction_step_id = s.transaction_step_id
      AND j.name = 'P_CURRENCY_CODE'

      UNION

      SELECT o.* from (
      SELECT pgr.rate_name,
             pgr.rate_id,
             pgr.rate_basis_name,
             pgr.currency_name,
             pgr.value,
             pgr.effective_start_date,
             decode(trunc(pgr.effective_end_date), trunc(hr_api.g_eot), null, pgr.effective_end_date) effective_end_date,
             pgr.object_version_number,
             pgr.grade_rule_id,
             pgr.currency_code,
             NULL transaction_step_id
      FROM   PAY_GRADE_RULES_V pgr
      WHERE  pgr.rate_type = 'A'
      AND    pgr.assignment_id = to_number(p_assignment_id)
      AND    pgr.business_group_id = to_number(p_business_gp_id)
      AND    pgr.grade_rule_id NOT IN (SELECT nvl(a.number_value, -1)
                                   FROM hr_api_transaction_steps s,
                                        hr_api_transaction_values a
                                   WHERE s.item_type = p_item_type
                                   AND s.item_key = p_item_key
                                   AND s.api_name = g_package||'.PROCESS_API'
                                   AND a.transaction_step_id = s.transaction_step_id
                                   AND a.name = 'P_GRADE_RULE_ID')
      ORDER BY pgr.rate_name ) o
      ) oo
      ORDER BY grade_rule_id desc;
  i NUMBER := 1;
begin
  g_asg_rate_table := HR_ASG_RATE_TABLE();
  for c1 in csr_asg_rate_tx
  loop
    g_asg_rate_table.extend;
    g_asg_rate_table(i) := HR_ASG_RATE_TYPE(null, null, null, null, null,
      null, null, null, null, null, null, null, null, null);
    g_asg_rate_table(i).business_group_id := p_business_gp_id;
    g_asg_rate_table(i).rate_name := c1.rate_name;
    g_asg_rate_table(i).rate_id := c1.rate_id;
    g_asg_rate_table(i).rate_basis_name := c1.rate_basis_name;
    g_asg_rate_table(i).currency_name := c1.currency_name;
    g_asg_rate_table(i).assignment_id := p_assignment_id;
    g_asg_rate_table(i).currency_code := c1.currency_code;
    g_asg_rate_table(i).value := c1.value;
    g_asg_rate_table(i).grade_rule_id := c1.grade_rule_id;
    g_asg_rate_table(i).transaction_step_id := c1.transaction_step_id;
    g_asg_rate_table(i).object_version_number := c1.object_version_number;
    g_asg_rate_table(i).effective_start_date := c1.effective_start_date;
    g_asg_rate_table(i).effective_end_date := c1.effective_end_date;
    g_asg_rate_table(i).row_index := c1.row_index;
    i := i + 1;
  end loop;

end populate_transaction_details;

PROCEDURE get_transaction_details
  (p_asg_rate_table in out nocopy HR_ASG_RATE_TABLE
  ) is
  l_asg_rate_table HR_ASG_RATE_TABLE := null;
begin
  l_asg_rate_table := p_asg_rate_table;
  p_asg_rate_table := g_asg_rate_table;
  g_asg_rate_table.delete;
exception
when others then
  p_asg_rate_table := l_asg_rate_table;
end get_transaction_details;

/**
 *
 */
PROCEDURE validate_record
  (p_validate       in     boolean Default true
  ,p_asg_rate_rec   in     HR_ASG_RATE_TYPE
  ,p_record_status  in     VARCHAR2
  ,p_effective_date in     date
  ,p_return_status     out nocopy VARCHAR2
  ) is

cursor csr_asg_rate_date(l_grade_rule_id IN NUMBER) is
  select effective_start_date,
         effective_end_date
  from   pay_grade_rules_v
  where grade_rule_id = l_grade_rule_id;


l_rec_start_date date := null;
l_rec_end_date date := null;
l_rec_update_mode VARCHAR2(15) := 'UPDATE';
l_object_version_number NUMBER;
l_effective_start_date DATE;
l_effective_end_date DATE;
l_grade_rule_id NUMBER;
l_validate BOOLEAN := true;
l_return_status VARCHAR2(5) := 'E';
l_validate_exception  exception;
l_temp boolean;
Begin
  l_object_version_number := p_asg_rate_rec.object_version_number;
  l_grade_rule_id := p_asg_rate_rec.grade_rule_id;
  if (p_record_status = g_update_delete or
      p_record_status = g_insert_delete or
      p_record_status = g_delete_only)
  then
    hr_multi_message.enable_message_list;
    if trunc(p_asg_rate_rec.effective_start_date) > trunc(nvl(p_asg_rate_rec.effective_end_date, hr_api.g_eot))
    then
      hr_utility.set_message(800, 'HR_ASG_RATE_INV_END_DATE');
      l_temp := hr_multi_message.exception_add
        (p_associated_column1 => 'PAY_GRADE_RULES_F.EFFECTIVE_END_DATE');
    end if;
    hr_multi_message.end_validation_set;
  end if;

  if l_grade_rule_id is not null
  then
    open csr_asg_rate_date(l_grade_rule_id);
    fetch csr_asg_rate_date into l_rec_start_date, l_rec_end_date;
    close csr_asg_rate_date;
  end if;
  l_validate := p_validate;

  if (p_record_status = g_update_delete or
      p_record_status = g_insert_delete)
  then
    l_validate := false;
    savepoint record_enddate_enabled;
  end if;

  if (p_record_status = g_insert_only or
      p_record_status = g_insert_delete)
  then
    create_assignment_rate_value
      (p_validate              => l_validate
      ,p_effective_date        => p_asg_rate_rec.effective_start_date
      ,p_business_group_id     => p_asg_rate_rec.business_group_id
      ,p_rate_id               => p_asg_rate_rec.rate_id
      ,p_assignment_id         => p_asg_rate_rec.assignment_id
      ,p_rate_type             => 'A'
      ,p_currency_code         => p_asg_rate_rec.currency_code
      ,p_value                 => p_asg_rate_rec.value
      ,p_grade_rule_id         => l_grade_rule_id
      ,p_object_version_number => l_object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
      ,p_return_status         => l_return_status
      );
    if l_return_status = 'E'
    then
      raise l_validate_exception;
    end if;
  elsif (p_record_status = g_update_delete or
         p_record_status = g_update_only)
  then
    if (l_rec_start_date is not null and
      trunc(l_rec_start_date)
        = trunc(p_asg_rate_rec.effective_start_date))
    then
      l_rec_update_mode := 'CORRECTION';
    end if;
    update_assignment_rate_value
      (p_validate              => l_validate
      ,p_grade_rule_id         => l_grade_rule_id
      ,p_effective_date        => p_asg_rate_rec.effective_start_date
      ,p_datetrack_mode        => l_rec_update_mode
      ,p_currency_code         => p_asg_rate_rec.currency_code
      ,p_value                 => p_asg_rate_rec.value
      ,p_object_version_number => l_object_version_number
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date
      ,p_return_status         => l_return_status
      );
    if l_return_status = 'E'
    then
      raise l_validate_exception;
    end if;
  end if;

    if (p_record_status = g_update_delete or
      p_record_status = g_insert_delete or
      p_record_status = g_delete_only)
    then
      begin
      savepoint record_delete_point;
      if trunc(l_rec_end_date) <> trunc(hr_api.g_eot)
      then
        delete_rate_value
          (p_validate              => l_validate
          ,p_grade_rule_id         => l_grade_rule_id
          ,p_datetrack_mode        => 'FUTURE_CHANGE'
          ,p_effective_date        => p_asg_rate_rec.effective_start_date
          ,p_object_version_number => l_object_version_number
          ,p_effective_start_date  => l_effective_start_date
          ,p_effective_end_date    => l_effective_end_date
          ,p_return_status         => l_return_status
          );
        if l_return_status = 'E'
        then
          raise l_validate_exception;
        end if;
      end if;
      if p_asg_rate_rec.effective_end_date is not null
      then
        delete_rate_value
          (p_validate              => l_validate
          ,p_grade_rule_id         => l_grade_rule_id
          ,p_datetrack_mode        => 'DELETE'
          ,p_effective_date        => p_asg_rate_rec.effective_end_date
          ,p_object_version_number => l_object_version_number
          ,p_effective_start_date  => l_effective_start_date
          ,p_effective_end_date    => l_effective_end_date
          ,p_return_status         => l_return_status
          );
      end if;
      if l_return_status  = 'E'
      then
        raise l_validate_exception;
      end if;
      if p_validate = true
      then
        rollback to record_delete_point;
      end if;
      exception
        when others then
          rollback to record_delete_point;
          raise;
      end;
    end if;

  if (p_record_status = g_update_delete or
      p_record_status = g_insert_delete)
  then
    if p_validate = true
    then
      rollback to record_enddate_enabled;
    end if;
  end if;

  p_return_status := l_return_status;
exception
when hr_multi_message.error_message_exist then
  p_return_status := hr_multi_message.get_return_status_disable;
when others then
  if (p_record_status = g_update_delete or
      p_record_status = g_insert_delete)
  then
    rollback to record_enddate_enabled;
  end if;
  p_return_status := 'E';
end validate_record;

PROCEDURE delete_transaction_step
  (p_transaction_step_id   in VARCHAR2
  ) is
begin
  delete from hr_api_transaction_values
    where transaction_step_id = p_transaction_step_id;
  delete from hr_api_transaction_steps
    where transaction_step_id = p_transaction_step_id;
end delete_transaction_step;

FUNCTION is_date_change_required
  (p_new_date    in DATE
  ,p_old_date    in DATE
  ) return boolean is
l_date_change_status boolean;
begin
  if p_new_date is null
  then
    if trunc(p_old_date) = trunc(hr_api.g_eot)
    then
      l_date_change_status := false;
    else
      l_date_change_status := true; -- in this case defaulting to hr_api.g_eot
    end if;
  else
    if trunc(p_new_date) = trunc(hr_api.g_eot)
    then
       if trunc(p_old_date) = trunc(hr_api.g_eot)
       then
         l_date_change_status := false;
       else
         l_date_change_status := true;
       end if;
    else
      if trunc(p_old_date) = trunc(p_new_date)
      then
        l_date_change_status := false;
      else
        l_date_change_status := true;
      end if;
    end if;
  end if;
  return l_date_change_status;
end is_date_change_required;

end hr_rate_values_swi;

/
