--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_ALLOCATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_ALLOCATIONS_SWI" As
/* $Header: pqvalswi.pkb 120.0 2005/05/29 02:17:45 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_vehicle_allocations_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_vehicle_allocation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_vehicle_allocation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_business_group_id            in     number
  ,p_vehicle_repository_id        in     number    default null
  ,p_across_assignments           in     varchar2  default null
  ,p_usage_type                   in     varchar2  default null
  ,p_capital_contribution         in     number    default null
  ,p_private_contribution         in     number    default null
  ,p_default_vehicle              in     varchar2  default null
  ,p_fuel_card                    in     varchar2  default null
  ,p_fuel_card_number             in     varchar2  default null
  ,p_calculation_method           in     varchar2  default null
  ,p_rates_table_id               in     number    default null
  ,p_element_type_id              in     number    default null
  ,p_private_use_flag		  in     varchar2 default null
  ,p_insurance_number		  in     varchar2 default null
  ,p_insurance_expiry_date		  in     date	    default null
  ,p_val_attribute_category       in     varchar2  default null
  ,p_val_attribute1               in     varchar2  default null
  ,p_val_attribute2               in     varchar2  default null
  ,p_val_attribute3               in     varchar2  default null
  ,p_val_attribute4               in     varchar2  default null
  ,p_val_attribute5               in     varchar2  default null
  ,p_val_attribute6               in     varchar2  default null
  ,p_val_attribute7               in     varchar2  default null
  ,p_val_attribute8               in     varchar2  default null
  ,p_val_attribute9               in     varchar2  default null
  ,p_val_attribute10              in     varchar2  default null
  ,p_val_attribute11              in     varchar2  default null
  ,p_val_attribute12              in     varchar2  default null
  ,p_val_attribute13              in     varchar2  default null
  ,p_val_attribute14              in     varchar2  default null
  ,p_val_attribute15              in     varchar2  default null
  ,p_val_attribute16              in     varchar2  default null
  ,p_val_attribute17              in     varchar2  default null
  ,p_val_attribute18              in     varchar2  default null
  ,p_val_attribute19              in     varchar2  default null
  ,p_val_attribute20              in     varchar2  default null
  ,p_val_information_category     in     varchar2  default null
  ,p_val_information1             in     varchar2  default null
  ,p_val_information2             in     varchar2  default null
  ,p_val_information3             in     varchar2  default null
  ,p_val_information4             in     varchar2  default null
  ,p_val_information5             in     varchar2  default null
  ,p_val_information6             in     varchar2  default null
  ,p_val_information7             in     varchar2  default null
  ,p_val_information8             in     varchar2  default null
  ,p_val_information9             in     varchar2  default null
  ,p_val_information10            in     varchar2  default null
  ,p_val_information11            in     varchar2  default null
  ,p_val_information12            in     varchar2  default null
  ,p_val_information13            in     varchar2  default null
  ,p_val_information14            in     varchar2  default null
  ,p_val_information15            in     varchar2  default null
  ,p_val_information16            in     varchar2  default null
  ,p_val_information17            in     varchar2  default null
  ,p_val_information18            in     varchar2  default null
  ,p_val_information19            in     varchar2  default null
  ,p_val_information20            in     varchar2  default null
  ,p_fuel_benefit                 in     varchar2  default null
  ,p_sliding_rates_info		  in     varchar2 default null
  ,p_vehicle_allocation_id        in     number
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
  l_vehicle_allocation_id        number;
  l_proc    varchar2(72) := g_package ||'create_vehicle_allocation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_vehicle_allocation_swi;
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
  pqp_val_ins.set_base_key_value
    (p_vehicle_allocation_id => p_vehicle_allocation_id
    );
  --
  -- Call API
  --
  pqp_vehicle_allocations_api.create_vehicle_allocation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_capital_contribution         => p_capital_contribution
    ,p_private_contribution         => p_private_contribution
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_calculation_method           => p_calculation_method
    ,p_rates_table_id               => p_rates_table_id
    ,p_element_type_id              => p_element_type_id
    ,p_private_use_flag		    => p_private_use_flag
    ,p_insurance_number		    => p_insurance_number
    ,p_insurance_expiry_date	    => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information_category     => p_val_information_category
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_sliding_rates_info	    => p_sliding_rates_info
    ,p_vehicle_allocation_id        => l_vehicle_allocation_id
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
    rollback to create_vehicle_allocation_swi;
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
    rollback to create_vehicle_allocation_swi;
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
end create_vehicle_allocation;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_vehicle_allocation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vehicle_allocation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_vehicle_allocation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vehicle_allocation_swi;
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
  pqp_vehicle_allocations_api.delete_vehicle_allocation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_vehicle_allocation_id        => p_vehicle_allocation_id
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
    rollback to delete_vehicle_allocation_swi;
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
    rollback to delete_vehicle_allocation_swi;
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
    raise;
end delete_vehicle_allocation;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_vehicle_allocation >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vehicle_allocation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_vehicle_repository_id        in     number    default hr_api.g_number
  ,p_across_assignments           in     varchar2  default hr_api.g_varchar2
  ,p_usage_type                   in     varchar2  default hr_api.g_varchar2
  ,p_capital_contribution         in     number    default hr_api.g_number
  ,p_private_contribution         in     number    default hr_api.g_number
  ,p_default_vehicle              in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card                    in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card_number             in     varchar2  default hr_api.g_varchar2
  ,p_calculation_method           in     varchar2  default hr_api.g_varchar2
  ,p_rates_table_id               in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_private_use_flag		  in     varchar2 default hr_api.g_varchar2
  ,p_insurance_number		  in     varchar2 default hr_api.g_varchar2
  ,p_insurance_expiry_date		  in     date	    default hr_api.g_date
  ,p_val_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_val_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_val_information1             in     varchar2  default hr_api.g_varchar2
  ,p_val_information2             in     varchar2  default hr_api.g_varchar2
  ,p_val_information3             in     varchar2  default hr_api.g_varchar2
  ,p_val_information4             in     varchar2  default hr_api.g_varchar2
  ,p_val_information5             in     varchar2  default hr_api.g_varchar2
  ,p_val_information6             in     varchar2  default hr_api.g_varchar2
  ,p_val_information7             in     varchar2  default hr_api.g_varchar2
  ,p_val_information8             in     varchar2  default hr_api.g_varchar2
  ,p_val_information9             in     varchar2  default hr_api.g_varchar2
  ,p_val_information10            in     varchar2  default hr_api.g_varchar2
  ,p_val_information11            in     varchar2  default hr_api.g_varchar2
  ,p_val_information12            in     varchar2  default hr_api.g_varchar2
  ,p_val_information13            in     varchar2  default hr_api.g_varchar2
  ,p_val_information14            in     varchar2  default hr_api.g_varchar2
  ,p_val_information15            in     varchar2  default hr_api.g_varchar2
  ,p_val_information16            in     varchar2  default hr_api.g_varchar2
  ,p_val_information17            in     varchar2  default hr_api.g_varchar2
  ,p_val_information18            in     varchar2  default hr_api.g_varchar2
  ,p_val_information19            in     varchar2  default hr_api.g_varchar2
  ,p_val_information20            in     varchar2  default hr_api.g_varchar2
  ,p_fuel_benefit                 in     varchar2  default hr_api.g_varchar2
  ,p_sliding_rates_info		  in     varchar2 default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_vehicle_allocation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vehicle_allocation_swi;
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
  pqp_vehicle_allocations_api.update_vehicle_allocation
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_vehicle_allocation_id        => p_vehicle_allocation_id
    ,p_object_version_number        => p_object_version_number
    ,p_assignment_id                => p_assignment_id
    ,p_business_group_id            => p_business_group_id
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_across_assignments           => p_across_assignments
    ,p_usage_type                   => p_usage_type
    ,p_capital_contribution         => p_capital_contribution
    ,p_private_contribution         => p_private_contribution
    ,p_default_vehicle              => p_default_vehicle
    ,p_fuel_card                    => p_fuel_card
    ,p_fuel_card_number             => p_fuel_card_number
    ,p_calculation_method           => p_calculation_method
    ,p_rates_table_id               => p_rates_table_id
    ,p_element_type_id              => p_element_type_id
    ,p_private_use_flag		    => p_private_use_flag
    ,p_insurance_number		    => p_insurance_number
    ,p_insurance_expiry_date	    => p_insurance_expiry_date
    ,p_val_attribute_category       => p_val_attribute_category
    ,p_val_attribute1               => p_val_attribute1
    ,p_val_attribute2               => p_val_attribute2
    ,p_val_attribute3               => p_val_attribute3
    ,p_val_attribute4               => p_val_attribute4
    ,p_val_attribute5               => p_val_attribute5
    ,p_val_attribute6               => p_val_attribute6
    ,p_val_attribute7               => p_val_attribute7
    ,p_val_attribute8               => p_val_attribute8
    ,p_val_attribute9               => p_val_attribute9
    ,p_val_attribute10              => p_val_attribute10
    ,p_val_attribute11              => p_val_attribute11
    ,p_val_attribute12              => p_val_attribute12
    ,p_val_attribute13              => p_val_attribute13
    ,p_val_attribute14              => p_val_attribute14
    ,p_val_attribute15              => p_val_attribute15
    ,p_val_attribute16              => p_val_attribute16
    ,p_val_attribute17              => p_val_attribute17
    ,p_val_attribute18              => p_val_attribute18
    ,p_val_attribute19              => p_val_attribute19
    ,p_val_attribute20              => p_val_attribute20
    ,p_val_information_category     => p_val_information_category
    ,p_val_information1             => p_val_information1
    ,p_val_information2             => p_val_information2
    ,p_val_information3             => p_val_information3
    ,p_val_information4             => p_val_information4
    ,p_val_information5             => p_val_information5
    ,p_val_information6             => p_val_information6
    ,p_val_information7             => p_val_information7
    ,p_val_information8             => p_val_information8
    ,p_val_information9             => p_val_information9
    ,p_val_information10            => p_val_information10
    ,p_val_information11            => p_val_information11
    ,p_val_information12            => p_val_information12
    ,p_val_information13            => p_val_information13
    ,p_val_information14            => p_val_information14
    ,p_val_information15            => p_val_information15
    ,p_val_information16            => p_val_information16
    ,p_val_information17            => p_val_information17
    ,p_val_information18            => p_val_information18
    ,p_val_information19            => p_val_information19
    ,p_val_information20            => p_val_information20
    ,p_fuel_benefit                 => p_fuel_benefit
    ,p_sliding_rates_info           =>p_sliding_rates_info
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
    rollback to update_vehicle_allocation_swi;
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
    rollback to update_vehicle_allocation_swi;
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
end update_vehicle_allocation;
end pqp_vehicle_allocations_swi;

/
