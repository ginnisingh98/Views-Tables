--------------------------------------------------------
--  DDL for Package Body OTA_ACTIVITY_VERSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACTIVITY_VERSION_SWI" As
/* $Header: ottavswi.pkb 120.1.12010000.2 2009/08/11 12:53:00 smahanka ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_activity_version_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_activity_version
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_activity_id                  in     number
  ,p_superseded_by_act_version_id in     number    default null
  ,p_developer_organization_id    in     number
  ,p_controlling_person_id        in     number    default null
  ,p_version_name                 in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_intended_audience            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_maximum_attendees            in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_objectives                   in     varchar2  default null
  ,p_start_date                   in     date      default null
  ,p_success_criteria             in     varchar2  default null
  ,p_user_status                  in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_expenses_allowed             in     varchar2  default null
  ,p_professional_credit_type     in     varchar2  default null
  ,p_professional_credits         in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_tav_information_category     in     varchar2  default null
  ,p_tav_information1             in     varchar2  default null
  ,p_tav_information2             in     varchar2  default null
  ,p_tav_information3             in     varchar2  default null
  ,p_tav_information4             in     varchar2  default null
  ,p_tav_information5             in     varchar2  default null
  ,p_tav_information6             in     varchar2  default null
  ,p_tav_information7             in     varchar2  default null
  ,p_tav_information8             in     varchar2  default null
  ,p_tav_information9             in     varchar2  default null
  ,p_tav_information10            in     varchar2  default null
  ,p_tav_information11            in     varchar2  default null
  ,p_tav_information12            in     varchar2  default null
  ,p_tav_information13            in     varchar2  default null
  ,p_tav_information14            in     varchar2  default null
  ,p_tav_information15            in     varchar2  default null
  ,p_tav_information16            in     varchar2  default null
  ,p_tav_information17            in     varchar2  default null
  ,p_tav_information18            in     varchar2  default null
  ,p_tav_information19            in     varchar2  default null
  ,p_tav_information20            in     varchar2  default null
  ,p_inventory_item_id            in     number    default null
  ,p_organization_id              in     number    default null
  ,p_rco_id                       in     number    default null
  ,p_version_code                 in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_activity_version_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_competency_update_level        in     varchar2  default null
  ,p_eres_enabled        in     varchar2  default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_activity_version_id          number;
  l_proc    varchar2(72) := g_package ||'create_activity_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_activity_version_swi;
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
  ota_tav_ins.set_base_key_value
    (p_activity_version_id => p_activity_version_id
    );
  --
  -- Call API
  --
  ota_activity_version_api.create_activity_version
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_activity_id                  => p_activity_id
    ,p_superseded_by_act_version_id => p_superseded_by_act_version_id
    ,p_developer_organization_id    => p_developer_organization_id
    ,p_controlling_person_id        => p_controlling_person_id
    ,p_version_name                 => p_version_name
    ,p_comments                     => p_comments
    ,p_description                  => p_description
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_end_date                     => p_end_date
    ,p_intended_audience            => p_intended_audience
    ,p_language_id                  => p_language_id
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_objectives                   => p_objectives
    ,p_start_date                   => p_start_date
    ,p_success_criteria             => p_success_criteria
    ,p_user_status                  => p_user_status
    ,p_vendor_id                    => p_vendor_id
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_expenses_allowed             => p_expenses_allowed
    ,p_professional_credit_type     => p_professional_credit_type
    ,p_professional_credits         => p_professional_credits
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_tav_information_category     => p_tav_information_category
    ,p_tav_information1             => p_tav_information1
    ,p_tav_information2             => p_tav_information2
    ,p_tav_information3             => p_tav_information3
    ,p_tav_information4             => p_tav_information4
    ,p_tav_information5             => p_tav_information5
    ,p_tav_information6             => p_tav_information6
    ,p_tav_information7             => p_tav_information7
    ,p_tav_information8             => p_tav_information8
    ,p_tav_information9             => p_tav_information9
    ,p_tav_information10            => p_tav_information10
    ,p_tav_information11            => p_tav_information11
    ,p_tav_information12            => p_tav_information12
    ,p_tav_information13            => p_tav_information13
    ,p_tav_information14            => p_tav_information14
    ,p_tav_information15            => p_tav_information15
    ,p_tav_information16            => p_tav_information16
    ,p_tav_information17            => p_tav_information17
    ,p_tav_information18            => p_tav_information18
    ,p_tav_information19            => p_tav_information19
    ,p_tav_information20            => p_tav_information20
    ,p_inventory_item_id            => p_inventory_item_id
    ,p_organization_id              => p_organization_id
    ,p_rco_id                       => p_rco_id
    ,p_version_code                 => p_version_code
    ,p_keywords                     => p_keywords
    ,p_business_group_id            => p_business_group_id
    ,p_activity_version_id          => l_activity_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_data_source                  => p_data_source
    ,p_competency_update_level      => p_competency_update_level
    ,p_eres_enabled                 => p_eres_enabled
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
    rollback to create_activity_version_swi;
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
    rollback to create_activity_version_swi;
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
end create_activity_version;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_activity_version
  (p_activity_version_id          in     number
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_activity_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_activity_version_swi;
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
  ota_activity_version_api.delete_activity_version
    (p_activity_version_id          => p_activity_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to delete_activity_version_swi;
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
    rollback to delete_activity_version_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_activity_version;
-- ----------------------------------------------------------------------------
-- |------------------------< update_activity_version >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_activity_version
  (p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_id                  in     number    default hr_api.g_number
  ,p_superseded_by_act_version_id in     number    default hr_api.g_number
  ,p_developer_organization_id    in     number    default hr_api.g_number
  ,p_controlling_person_id        in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_version_name                 in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_intended_audience            in     varchar2  default hr_api.g_varchar2
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_objectives                   in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
  ,p_user_status                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_expenses_allowed             in     varchar2  default hr_api.g_varchar2
  ,p_professional_credit_type     in     varchar2  default hr_api.g_varchar2
  ,p_professional_credits         in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_tav_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tav_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tav_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tav_information20            in     varchar2  default hr_api.g_varchar2
  ,p_inventory_item_id            in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_rco_id                       in     number    default hr_api.g_number
  ,p_version_code                 in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
  ,p_eres_enabled        	    in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_activity_version';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_activity_version_swi;
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
  ota_activity_version_api.update_activity_version
    (p_effective_date               => p_effective_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_id                  => p_activity_id
    ,p_superseded_by_act_version_id => p_superseded_by_act_version_id
    ,p_developer_organization_id    => p_developer_organization_id
    ,p_controlling_person_id        => p_controlling_person_id
    ,p_object_version_number        => p_object_version_number
    ,p_version_name                 => p_version_name
    ,p_comments                     => p_comments
    ,p_description                  => p_description
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_end_date                     => p_end_date
    ,p_intended_audience            => p_intended_audience
    ,p_language_id                  => p_language_id
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_objectives                   => p_objectives
    ,p_start_date                   => p_start_date
    ,p_success_criteria             => p_success_criteria
    ,p_user_status                  => p_user_status
    ,p_vendor_id                    => p_vendor_id
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_expenses_allowed             => p_expenses_allowed
    ,p_professional_credit_type     => p_professional_credit_type
    ,p_professional_credits         => p_professional_credits
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_tav_information_category     => p_tav_information_category
    ,p_tav_information1             => p_tav_information1
    ,p_tav_information2             => p_tav_information2
    ,p_tav_information3             => p_tav_information3
    ,p_tav_information4             => p_tav_information4
    ,p_tav_information5             => p_tav_information5
    ,p_tav_information6             => p_tav_information6
    ,p_tav_information7             => p_tav_information7
    ,p_tav_information8             => p_tav_information8
    ,p_tav_information9             => p_tav_information9
    ,p_tav_information10            => p_tav_information10
    ,p_tav_information11            => p_tav_information11
    ,p_tav_information12            => p_tav_information12
    ,p_tav_information13            => p_tav_information13
    ,p_tav_information14            => p_tav_information14
    ,p_tav_information15            => p_tav_information15
    ,p_tav_information16            => p_tav_information16
    ,p_tav_information17            => p_tav_information17
    ,p_tav_information18            => p_tav_information18
    ,p_tav_information19            => p_tav_information19
    ,p_tav_information20            => p_tav_information20
    ,p_inventory_item_id            => p_inventory_item_id
    ,p_organization_id              => p_organization_id
    ,p_rco_id                       => p_rco_id
    ,p_version_code                 => p_version_code
    ,p_keywords                     => p_keywords
    ,p_business_group_id            => p_business_group_id
    ,p_validate                     => l_validate
    ,p_data_source                  => p_data_source
    ,p_competency_update_level      => p_competency_update_level
    ,p_eres_enabled                 => p_eres_enabled
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
    rollback to update_activity_version_swi;
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
    rollback to update_activity_version_swi;
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
end update_activity_version;
-- ----------------------------------------------------------------------------
-- |------------------------< validate_delete_act_ver >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_delete_act_ver
  (p_activity_version_id          in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'validate_delete_act_ver';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint validate_delete_act_ver_swi;
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
  ota_tav_bus.check_if_tpm_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_evt_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_tbd_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_ple_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_tav_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_tsp_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_off_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_lpm_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_comp_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_noth_exists( p_activity_version_id );
  --
  ota_tav_bus.check_if_crt_exists( p_activity_version_id );

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
    rollback to validate_delete_act_ver_swi;
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
    rollback to validate_delete_act_ver_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end validate_delete_act_ver;
end ota_activity_version_swi;

/
