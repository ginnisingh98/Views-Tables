--------------------------------------------------------
--  DDL for Package Body OTA_OFFERING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFFERING_SWI" As
/* $Header: otoffswi.pkb 120.0.12000000.2 2007/02/06 15:23:37 vkkolla noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_offering_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_offering >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_activity_version_id          in     number    default null
  ,p_end_date                     in     date      default null
  ,p_owner_id                     in     number    default null
  ,p_delivery_mode_id             in     number    default null
  ,p_language_id                  in     number    default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_learning_object_id           in     number    default null
  ,p_player_toolbar_flag          in     varchar2  default null
  ,p_player_toolbar_bitset        in     number    default null
  ,p_player_new_window_flag       in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_price               in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_offering_id                  in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                   in     varchar2  default null
  ,p_vendor_id                     in     number  default null
  ,p_description                  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null -- 2733966 enh natural_languages

  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_offering_id                  number;
  l_proc    varchar2(72) := g_package ||'create_offering';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_offering_swi;
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
  ota_off_ins.set_base_key_value(p_offering_id => p_offering_id  );
  --
  -- Call API
  --
  ota_offering_api.create_offering
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => p_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
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
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_offering_id                  => l_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code  -- 2733966
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
    rollback to create_offering_swi;
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
    rollback to create_offering_swi;
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
end create_offering;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_offering >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offering_id                  in     number
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
  l_proc    varchar2(72) := g_package ||'delete_offering';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_offering_swi;
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
  ota_offering_api.delete_offering
    (p_validate                     => l_validate
    ,p_offering_id                  => p_offering_id
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
    rollback to delete_offering_swi;
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
    rollback to delete_offering_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_offering;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_offering >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_offering_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_delivery_mode_id             in     number    default hr_api.g_number
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_learning_object_id           in     number    default hr_api.g_number
  ,p_player_toolbar_flag          in     varchar2  default hr_api.g_varchar2
  ,p_player_toolbar_bitset        in     number    default hr_api.g_number
  ,p_player_new_window_flag       in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_standard_price               in     number    default hr_api.g_number
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
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number  default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_competency_update_level      in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2 -- 2733966

  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_offering';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_offering_swi;
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
  ota_offering_api.update_offering
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_offering_id                  => p_offering_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => p_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => p_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
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
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code   -- 2733966
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
    rollback to update_offering_swi;
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
    rollback to update_offering_swi;
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
end update_offering;
end ota_offering_swi;

/
