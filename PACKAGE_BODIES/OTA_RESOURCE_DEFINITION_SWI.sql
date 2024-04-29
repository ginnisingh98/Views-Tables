--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_DEFINITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_DEFINITION_SWI" As
/* $Header: ottsrswi.pkb 120.0 2005/05/29 07:56 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_resource_definition_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_resource_definition
  (p_supplied_resource_id         in     number
  ,p_vendor_id                    in     number
  ,p_business_group_id            in     number
  ,p_resource_definition_id       in     number
  ,p_consumable_flag              in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_resource_type                in     varchar2  default null
  ,p_start_date                   in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_cost                         in     number
  ,p_cost_unit                    in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_internal_address_line        in     varchar2  default null
  ,p_lead_time                    in     number
  ,p_name                         in     varchar2  default null
  ,p_supplier_reference           in     varchar2  default null
  ,p_tsr_information_category     in     varchar2  default null
  ,p_tsr_information1             in     varchar2  default null
  ,p_tsr_information2             in     varchar2  default null
  ,p_tsr_information3             in     varchar2  default null
  ,p_tsr_information4             in     varchar2  default null
  ,p_tsr_information5             in     varchar2  default null
  ,p_tsr_information6             in     varchar2  default null
  ,p_tsr_information7             in     varchar2  default null
  ,p_tsr_information8             in     varchar2  default null
  ,p_tsr_information9             in     varchar2  default null
  ,p_tsr_information10            in     varchar2  default null
  ,p_tsr_information11            in     varchar2  default null
  ,p_tsr_information12            in     varchar2  default null
  ,p_tsr_information13            in     varchar2  default null
  ,p_tsr_information14            in     varchar2  default null
  ,p_tsr_information15            in     varchar2  default null
  ,p_tsr_information16            in     varchar2  default null
  ,p_tsr_information17            in     varchar2  default null
  ,p_tsr_information18            in     varchar2  default null
  ,p_tsr_information19            in     varchar2  default null
  ,p_tsr_information20            in     varchar2  default null
  ,p_training_center_id           in     number
  ,p_location_id                  in     number
  ,p_trainer_id                   in     number
  ,p_special_instruction          in     varchar2  default null
  ,p_validate                     in     number
  ,p_effective_date               in     date
  ,p_data_source                  in     varchar2  default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_resource_definition';
  l_supplied_resource_id number;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_resource_definition_swi;
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
  ota_tsr_ins.set_base_key_value(p_supplied_resource_id => p_supplied_resource_id  );
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  ota_resource_definition_api.create_resource_definition
    (p_supplied_resource_id        => l_supplied_resource_id
     ,p_vendor_id                    => p_vendor_id
    ,p_business_group_id            => p_business_group_id
    ,p_resource_definition_id       => p_resource_definition_id
    ,p_consumable_flag              => p_consumable_flag
    ,p_object_version_number        => p_object_version_number
    ,p_resource_type                => p_resource_type
    ,p_start_date                   => p_start_date
    ,p_comments                     => p_comments
    ,p_cost                         => p_cost
    ,p_cost_unit                    => p_cost_unit
    ,p_currency_code                => p_currency_code
    ,p_end_date                     => p_end_date
    ,p_internal_address_line        => p_internal_address_line
    ,p_lead_time                    => p_lead_time
    ,p_name                         => p_name
    ,p_supplier_reference           => p_supplier_reference
    ,p_tsr_information_category     => p_tsr_information_category
    ,p_tsr_information1             => p_tsr_information1
    ,p_tsr_information2             => p_tsr_information2
    ,p_tsr_information3             => p_tsr_information3
    ,p_tsr_information4             => p_tsr_information4
    ,p_tsr_information5             => p_tsr_information5
    ,p_tsr_information6             => p_tsr_information6
    ,p_tsr_information7             => p_tsr_information7
    ,p_tsr_information8             => p_tsr_information8
    ,p_tsr_information9             => p_tsr_information9
    ,p_tsr_information10            => p_tsr_information10
    ,p_tsr_information11            => p_tsr_information11
    ,p_tsr_information12            => p_tsr_information12
    ,p_tsr_information13            => p_tsr_information13
    ,p_tsr_information14            => p_tsr_information14
    ,p_tsr_information15            => p_tsr_information15
    ,p_tsr_information16            => p_tsr_information16
    ,p_tsr_information17            => p_tsr_information17
    ,p_tsr_information18            => p_tsr_information18
    ,p_tsr_information19            => p_tsr_information19
    ,p_tsr_information20            => p_tsr_information20
    ,p_training_center_id           => p_training_center_id
    ,p_location_id                  => p_location_id
    ,p_trainer_id                   => p_trainer_id
    ,p_special_instruction          => p_special_instruction
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_data_source                  => p_data_source
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
    rollback to create_resource_definition_swi;
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
    rollback to create_resource_definition_swi;
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
end create_resource_definition;
-- ----------------------------------------------------------------------------
-- |----------------------< update_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_resource_definition
  (p_supplied_resource_id         in     number
  ,p_vendor_id                    in     number
  ,p_business_group_id            in     number
  ,p_resource_definition_id       in     number
  ,p_consumable_flag              in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_resource_type                in     varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_comments                     in     varchar2
  ,p_cost                         in     number
  ,p_cost_unit                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_internal_address_line        in     varchar2
  ,p_lead_time                    in     number
  ,p_name                         in     varchar2
  ,p_supplier_reference           in     varchar2
  ,p_tsr_information_category     in     varchar2
  ,p_tsr_information1             in     varchar2
  ,p_tsr_information2             in     varchar2
  ,p_tsr_information3             in     varchar2
  ,p_tsr_information4             in     varchar2
  ,p_tsr_information5             in     varchar2
  ,p_tsr_information6             in     varchar2
  ,p_tsr_information7             in     varchar2
  ,p_tsr_information8             in     varchar2
  ,p_tsr_information9             in     varchar2
  ,p_tsr_information10            in     varchar2
  ,p_tsr_information11            in     varchar2
  ,p_tsr_information12            in     varchar2
  ,p_tsr_information13            in     varchar2
  ,p_tsr_information14            in     varchar2
  ,p_tsr_information15            in     varchar2
  ,p_tsr_information16            in     varchar2
  ,p_tsr_information17            in     varchar2
  ,p_tsr_information18            in     varchar2
  ,p_tsr_information19            in     varchar2
  ,p_tsr_information20            in     varchar2
  ,p_training_center_id           in     number
  ,p_location_id                  in     number
  ,p_trainer_id                   in     number
  ,p_special_instruction          in     varchar2
  ,p_validate                     in     number
  ,p_effective_date               in     date
  ,p_data_source                  in     varchar2
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
  l_proc    varchar2(72) := g_package ||'update_resource_definition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_resource_definition_swi;
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
  ota_resource_definition_api.update_resource_definition
    (p_supplied_resource_id         => p_supplied_resource_id
    ,p_vendor_id                    => p_vendor_id
    ,p_business_group_id            => p_business_group_id
    ,p_resource_definition_id       => p_resource_definition_id
    ,p_consumable_flag              => p_consumable_flag
    ,p_object_version_number        => p_object_version_number
    ,p_resource_type                => p_resource_type
    ,p_start_date                   => p_start_date
    ,p_comments                     => p_comments
    ,p_cost                         => p_cost
    ,p_cost_unit                    => p_cost_unit
    ,p_currency_code                => p_currency_code
    ,p_end_date                     => p_end_date
    ,p_internal_address_line        => p_internal_address_line
    ,p_lead_time                    => p_lead_time
    ,p_name                         => p_name
    ,p_supplier_reference           => p_supplier_reference
    ,p_tsr_information_category     => p_tsr_information_category
    ,p_tsr_information1             => p_tsr_information1
    ,p_tsr_information2             => p_tsr_information2
    ,p_tsr_information3             => p_tsr_information3
    ,p_tsr_information4             => p_tsr_information4
    ,p_tsr_information5             => p_tsr_information5
    ,p_tsr_information6             => p_tsr_information6
    ,p_tsr_information7             => p_tsr_information7
    ,p_tsr_information8             => p_tsr_information8
    ,p_tsr_information9             => p_tsr_information9
    ,p_tsr_information10            => p_tsr_information10
    ,p_tsr_information11            => p_tsr_information11
    ,p_tsr_information12            => p_tsr_information12
    ,p_tsr_information13            => p_tsr_information13
    ,p_tsr_information14            => p_tsr_information14
    ,p_tsr_information15            => p_tsr_information15
    ,p_tsr_information16            => p_tsr_information16
    ,p_tsr_information17            => p_tsr_information17
    ,p_tsr_information18            => p_tsr_information18
    ,p_tsr_information19            => p_tsr_information19
    ,p_tsr_information20            => p_tsr_information20
    ,p_training_center_id           => p_training_center_id
    ,p_location_id                  => p_location_id
    ,p_trainer_id                   => p_trainer_id
    ,p_special_instruction          => p_special_instruction
    ,p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_data_source                  => p_data_source
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
    rollback to update_resource_definition_swi;
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
    rollback to update_resource_definition_swi;
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
end update_resource_definition;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_resource_definition >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_resource_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_supplied_resource_id         in     number
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
  l_proc    varchar2(72) := g_package ||'delete_resource_definition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_resource_definition_swi;
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
  ota_resource_definition_api.delete_resource_definition
    (p_validate                     => l_validate
    ,p_supplied_resource_id         => p_supplied_resource_id
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
    rollback to delete_resource_definition_swi;
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
    rollback to delete_resource_definition_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_resource_definition;
end ota_resource_definition_swi;

/
