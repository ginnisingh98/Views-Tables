--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_REPOSITORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_REPOSITORY_SWI" As
/* $Header: pqvreswi.pkb 120.0 2005/05/29 02:18:49 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqp_vehicle_repository_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_vehicle
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_registration_number          in     varchar2
  ,p_vehicle_type                 in     varchar2
  ,p_vehicle_id_number            in     varchar2
  ,p_business_group_id            in     number
  ,p_make                         in     varchar2
  ,p_engine_capacity_in_cc        in     number
  ,p_fuel_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_vehicle_status               in     varchar2
  ,p_vehicle_inactivity_reason    in     varchar2
  ,p_model                        in     varchar2
  ,p_initial_registration         in     date
  ,p_last_registration_renew_date in     date
  ,p_list_price                   in     number
  ,p_accessory_value_at_startdate in     number
  ,p_accessory_value_added_later  in     number
  ,p_market_value_classic_car     in     number
  ,p_fiscal_ratings               in     number
  ,p_fiscal_ratings_uom           in     varchar2
  ,p_vehicle_provider             in     varchar2
  ,p_vehicle_ownership            in     varchar2
  ,p_shared_vehicle               in     varchar2
  ,p_asset_number                 in     varchar2
  ,p_lease_contract_number        in     varchar2
  ,p_lease_contract_expiry_date   in     date
  ,p_taxation_method              in     varchar2
  ,p_fleet_info                   in     varchar2
  ,p_fleet_transfer_date          in     date
  ,p_color                        in     varchar2
  ,p_seating_capacity             in     number
  ,p_weight                       in     number
  ,p_weight_uom                   in     varchar2
  ,p_model_year                   in     number
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_comments                     in     varchar2
  ,p_vre_attribute_category       in     varchar2
  ,p_vre_attribute1               in     varchar2
  ,p_vre_attribute2               in     varchar2
  ,p_vre_attribute3               in     varchar2
  ,p_vre_attribute4               in     varchar2
  ,p_vre_attribute5               in     varchar2
  ,p_vre_attribute6               in     varchar2
  ,p_vre_attribute7               in     varchar2
  ,p_vre_attribute8               in     varchar2
  ,p_vre_attribute9               in     varchar2
  ,p_vre_attribute10              in     varchar2
  ,p_vre_attribute11              in     varchar2
  ,p_vre_attribute12              in     varchar2
  ,p_vre_attribute13              in     varchar2
  ,p_vre_attribute14              in     varchar2
  ,p_vre_attribute15              in     varchar2
  ,p_vre_attribute16              in     varchar2
  ,p_vre_attribute17              in     varchar2
  ,p_vre_attribute18              in     varchar2
  ,p_vre_attribute19              in     varchar2
  ,p_vre_attribute20              in     varchar2
  ,p_vre_information_category     in     varchar2
  ,p_vre_information1             in     varchar2
  ,p_vre_information2             in     varchar2
  ,p_vre_information3             in     varchar2
  ,p_vre_information4             in     varchar2
  ,p_vre_information5             in     varchar2
  ,p_vre_information6             in     varchar2
  ,p_vre_information7             in     varchar2
  ,p_vre_information8             in     varchar2
  ,p_vre_information9             in     varchar2
  ,p_vre_information10            in     varchar2
  ,p_vre_information11            in     varchar2
  ,p_vre_information12            in     varchar2
  ,p_vre_information13            in     varchar2
  ,p_vre_information14            in     varchar2
  ,p_vre_information15            in     varchar2
  ,p_vre_information16            in     varchar2
  ,p_vre_information17            in     varchar2
  ,p_vre_information18            in     varchar2
  ,p_vre_information19            in     varchar2
  ,p_vre_information20            in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  ---
 CURSOR c_fiscal_uom IS
   SELECT hrl.lookup_code
     FROM hr_lookups hrl
    WHERE lookup_type = 'PQP_FISCAL_RATINGS_UOM'
      AND enabled_flag    = 'Y';



---

  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_vehicle_repository_id        number;
  l_proc    varchar2(72) := g_package ||'create_vehicle';
  l_lookup_code         hr_lookups.lookup_code%TYPE;
  l_leg_code            pqp_configuration_values.legislation_code%TYPE;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  Begin

   --Getting the legislationId for business groupId
   l_leg_code :=
                  pqp_vre_bus.get_legislation_code(p_business_group_id);
   --setting the lg context
   hr_api.set_legislation_context(l_leg_code);
   OPEN c_fiscal_uom;
   FETCH c_fiscal_uom INTO  l_lookup_code;
   CLOSE c_fiscal_uom;
 EXCEPTION
 WHEN no_data_found THEN
  l_lookup_code := NULL;
 End ;
  -- Issue a savepoint
  --
  savepoint create_vehicle_swi;
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
  pqp_vre_ins.set_base_key_value
    (p_vehicle_repository_id => p_vehicle_repository_id
    );
  --
  -- Call API
  --
  pqp_vehicle_repository_api.create_vehicle
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_registration_number          => p_registration_number
    ,p_vehicle_type                 => p_vehicle_type
    ,p_vehicle_id_number            => p_vehicle_id_number
    ,p_business_group_id            => p_business_group_id
    ,p_make                         => p_make
    ,p_engine_capacity_in_cc        => p_engine_capacity_in_cc
    ,p_fuel_type                    => p_fuel_type
    ,p_currency_code                => p_currency_code
    ,p_vehicle_status               => p_vehicle_status
    ,p_vehicle_inactivity_reason    => p_vehicle_inactivity_reason
    ,p_model                        => p_model
    ,p_initial_registration         => p_initial_registration
    ,p_last_registration_renew_date => p_last_registration_renew_date
    ,p_list_price                   => p_list_price
    ,p_accessory_value_at_startdate => p_accessory_value_at_startdate
    ,p_accessory_value_added_later  => p_accessory_value_added_later
    ,p_market_value_classic_car     => p_market_value_classic_car
    ,p_fiscal_ratings               => p_fiscal_ratings
    ,p_fiscal_ratings_uom           => l_lookup_code --p_fiscal_ratings_uom
    ,p_vehicle_provider             => p_vehicle_provider
    ,p_vehicle_ownership            => p_vehicle_ownership
    ,p_shared_vehicle               => p_shared_vehicle
    ,p_asset_number                 => p_asset_number
    ,p_lease_contract_number        => p_lease_contract_number
    ,p_lease_contract_expiry_date   => p_lease_contract_expiry_date
    ,p_taxation_method              => p_taxation_method
    ,p_fleet_info                   => p_fleet_info
    ,p_fleet_transfer_date          => p_fleet_transfer_date
    ,p_color                        => p_color
    ,p_seating_capacity             => p_seating_capacity
    ,p_weight                       => p_weight
    ,p_weight_uom                   => p_weight_uom
    ,p_model_year                   => p_model_year
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_comments                     => p_comments
    ,p_vre_attribute_category       => p_vre_attribute_category
    ,p_vre_attribute1               => p_vre_attribute1
    ,p_vre_attribute2               => p_vre_attribute2
    ,p_vre_attribute3               => p_vre_attribute3
    ,p_vre_attribute4               => p_vre_attribute4
    ,p_vre_attribute5               => p_vre_attribute5
    ,p_vre_attribute6               => p_vre_attribute6
    ,p_vre_attribute7               => p_vre_attribute7
    ,p_vre_attribute8               => p_vre_attribute8
    ,p_vre_attribute9               => p_vre_attribute9
    ,p_vre_attribute10              => p_vre_attribute10
    ,p_vre_attribute11              => p_vre_attribute11
    ,p_vre_attribute12              => p_vre_attribute12
    ,p_vre_attribute13              => p_vre_attribute13
    ,p_vre_attribute14              => p_vre_attribute14
    ,p_vre_attribute15              => p_vre_attribute15
    ,p_vre_attribute16              => p_vre_attribute16
    ,p_vre_attribute17              => p_vre_attribute17
    ,p_vre_attribute18              => p_vre_attribute18
    ,p_vre_attribute19              => p_vre_attribute19
    ,p_vre_attribute20              => p_vre_attribute20
    ,p_vre_information_category     => p_vre_information_category
    ,p_vre_information1             => p_vre_information1
    ,p_vre_information2             => p_vre_information2
    ,p_vre_information3             => p_vre_information3
    ,p_vre_information4             => p_vre_information4
    ,p_vre_information5             => p_vre_information5
    ,p_vre_information6             => p_vre_information6
    ,p_vre_information7             => p_vre_information7
    ,p_vre_information8             => p_vre_information8
    ,p_vre_information9             => p_vre_information9
    ,p_vre_information10            => p_vre_information10
    ,p_vre_information11            => p_vre_information11
    ,p_vre_information12            => p_vre_information12
    ,p_vre_information13            => p_vre_information13
    ,p_vre_information14            => p_vre_information14
    ,p_vre_information15            => p_vre_information15
    ,p_vre_information16            => p_vre_information16
    ,p_vre_information17            => p_vre_information17
    ,p_vre_information18            => p_vre_information18
    ,p_vre_information19            => p_vre_information19
    ,p_vre_information20            => p_vre_information20
    ,p_vehicle_repository_id        => l_vehicle_repository_id
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
    rollback to create_vehicle_swi;
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
    rollback to create_vehicle_swi;
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
    raise;
end create_vehicle;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vehicle
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_vehicle';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vehicle_swi;
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
  pqp_vehicle_repository_api.delete_vehicle
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_vehicle_repository_id        => p_vehicle_repository_id
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
    rollback to delete_vehicle_swi;
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
    rollback to delete_vehicle_swi;
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
end delete_vehicle;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_vehicle >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vehicle
  (p_validate                     in     number
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_registration_number          in     varchar2
  ,p_vehicle_type                 in     varchar2
  ,p_vehicle_id_number            in     varchar2
  ,p_business_group_id            in     number
  ,p_make                         in     varchar2
  ,p_engine_capacity_in_cc        in     number
  ,p_fuel_type                    in     varchar2
  ,p_currency_code                in     varchar2
  ,p_vehicle_status               in     varchar2
  ,p_vehicle_inactivity_reason    in     varchar2
  ,p_model                        in     varchar2
  ,p_initial_registration         in     date
  ,p_last_registration_renew_date in     date
  ,p_list_price                   in     number
  ,p_accessory_value_at_startdate in     number
  ,p_accessory_value_added_later  in     number
  ,p_market_value_classic_car     in     number
  ,p_fiscal_ratings               in     number
  ,p_fiscal_ratings_uom           in     varchar2
  ,p_vehicle_provider             in     varchar2
  ,p_vehicle_ownership            in     varchar2
  ,p_shared_vehicle               in     varchar2
  ,p_asset_number                 in     varchar2
  ,p_lease_contract_number        in     varchar2
  ,p_lease_contract_expiry_date   in     date
  ,p_taxation_method              in     varchar2
  ,p_fleet_info                   in     varchar2
  ,p_fleet_transfer_date          in     date
  ,p_color                        in     varchar2
  ,p_seating_capacity             in     number
  ,p_weight                       in     number
  ,p_weight_uom                   in     varchar2
  ,p_model_year                   in     number
  ,p_insurance_number             in     varchar2
  ,p_insurance_expiry_date        in     date
  ,p_comments                     in     varchar2
  ,p_vre_attribute_category       in     varchar2
  ,p_vre_attribute1               in     varchar2
  ,p_vre_attribute2               in     varchar2
  ,p_vre_attribute3               in     varchar2
  ,p_vre_attribute4               in     varchar2
  ,p_vre_attribute5               in     varchar2
  ,p_vre_attribute6               in     varchar2
  ,p_vre_attribute7               in     varchar2
  ,p_vre_attribute8               in     varchar2
  ,p_vre_attribute9               in     varchar2
  ,p_vre_attribute10              in     varchar2
  ,p_vre_attribute11              in     varchar2
  ,p_vre_attribute12              in     varchar2
  ,p_vre_attribute13              in     varchar2
  ,p_vre_attribute14              in     varchar2
  ,p_vre_attribute15              in     varchar2
  ,p_vre_attribute16              in     varchar2
  ,p_vre_attribute17              in     varchar2
  ,p_vre_attribute18              in     varchar2
  ,p_vre_attribute19              in     varchar2
  ,p_vre_attribute20              in     varchar2
  ,p_vre_information_category     in     varchar2
  ,p_vre_information1             in     varchar2
  ,p_vre_information2             in     varchar2
  ,p_vre_information3             in     varchar2
  ,p_vre_information4             in     varchar2
  ,p_vre_information5             in     varchar2
  ,p_vre_information6             in     varchar2
  ,p_vre_information7             in     varchar2
  ,p_vre_information8             in     varchar2
  ,p_vre_information9             in     varchar2
  ,p_vre_information10            in     varchar2
  ,p_vre_information11            in     varchar2
  ,p_vre_information12            in     varchar2
  ,p_vre_information13            in     varchar2
  ,p_vre_information14            in     varchar2
  ,p_vre_information15            in     varchar2
  ,p_vre_information16            in     varchar2
  ,p_vre_information17            in     varchar2
  ,p_vre_information18            in     varchar2
  ,p_vre_information19            in     varchar2
  ,p_vre_information20            in     varchar2
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
  l_proc    varchar2(72) := g_package ||'update_vehicle';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vehicle_swi;
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
  pqp_vehicle_repository_api.update_vehicle
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_vehicle_repository_id        => p_vehicle_repository_id
    ,p_object_version_number        => p_object_version_number
    ,p_registration_number          => p_registration_number
    ,p_vehicle_type                 => p_vehicle_type
    ,p_vehicle_id_number            => p_vehicle_id_number
    ,p_business_group_id            => p_business_group_id
    ,p_make                         => p_make
    ,p_engine_capacity_in_cc        => p_engine_capacity_in_cc
    ,p_fuel_type                    => p_fuel_type
    ,p_currency_code                => p_currency_code
    ,p_vehicle_status               => p_vehicle_status
    ,p_vehicle_inactivity_reason    => p_vehicle_inactivity_reason
    ,p_model                        => p_model
    ,p_initial_registration         => p_initial_registration
    ,p_last_registration_renew_date => p_last_registration_renew_date
    ,p_list_price                   => p_list_price
    ,p_accessory_value_at_startdate => p_accessory_value_at_startdate
    ,p_accessory_value_added_later  => p_accessory_value_added_later
    ,p_market_value_classic_car     => p_market_value_classic_car
    ,p_fiscal_ratings               => p_fiscal_ratings
    ,p_fiscal_ratings_uom           => p_fiscal_ratings_uom
    ,p_vehicle_provider             => p_vehicle_provider
    ,p_vehicle_ownership            => p_vehicle_ownership
    ,p_shared_vehicle               => p_shared_vehicle
    ,p_asset_number                 => p_asset_number
    ,p_lease_contract_number        => p_lease_contract_number
    ,p_lease_contract_expiry_date   => p_lease_contract_expiry_date
    ,p_taxation_method              => p_taxation_method
    ,p_fleet_info                   => p_fleet_info
    ,p_fleet_transfer_date          => p_fleet_transfer_date
    ,p_color                        => p_color
    ,p_seating_capacity             => p_seating_capacity
    ,p_weight                       => p_weight
    ,p_weight_uom                   => p_weight_uom
    ,p_model_year                   => p_model_year
    ,p_insurance_number             => p_insurance_number
    ,p_insurance_expiry_date        => p_insurance_expiry_date
    ,p_comments                     => p_comments
    ,p_vre_attribute_category       => p_vre_attribute_category
    ,p_vre_attribute1               => p_vre_attribute1
    ,p_vre_attribute2               => p_vre_attribute2
    ,p_vre_attribute3               => p_vre_attribute3
    ,p_vre_attribute4               => p_vre_attribute4
    ,p_vre_attribute5               => p_vre_attribute5
    ,p_vre_attribute6               => p_vre_attribute6
    ,p_vre_attribute7               => p_vre_attribute7
    ,p_vre_attribute8               => p_vre_attribute8
    ,p_vre_attribute9               => p_vre_attribute9
    ,p_vre_attribute10              => p_vre_attribute10
    ,p_vre_attribute11              => p_vre_attribute11
    ,p_vre_attribute12              => p_vre_attribute12
    ,p_vre_attribute13              => p_vre_attribute13
    ,p_vre_attribute14              => p_vre_attribute14
    ,p_vre_attribute15              => p_vre_attribute15
    ,p_vre_attribute16              => p_vre_attribute16
    ,p_vre_attribute17              => p_vre_attribute17
    ,p_vre_attribute18              => p_vre_attribute18
    ,p_vre_attribute19              => p_vre_attribute19
    ,p_vre_attribute20              => p_vre_attribute20
    ,p_vre_information_category     => p_vre_information_category
    ,p_vre_information1             => p_vre_information1
    ,p_vre_information2             => p_vre_information2
    ,p_vre_information3             => p_vre_information3
    ,p_vre_information4             => p_vre_information4
    ,p_vre_information5             => p_vre_information5
    ,p_vre_information6             => p_vre_information6
    ,p_vre_information7             => p_vre_information7
    ,p_vre_information8             => p_vre_information8
    ,p_vre_information9             => p_vre_information9
    ,p_vre_information10            => p_vre_information10
    ,p_vre_information11            => p_vre_information11
    ,p_vre_information12            => p_vre_information12
    ,p_vre_information13            => p_vre_information13
    ,p_vre_information14            => p_vre_information14
    ,p_vre_information15            => p_vre_information15
    ,p_vre_information16            => p_vre_information16
    ,p_vre_information17            => p_vre_information17
    ,p_vre_information18            => p_vre_information18
    ,p_vre_information19            => p_vre_information19
    ,p_vre_information20            => p_vre_information20
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
    rollback to update_vehicle_swi;
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
    rollback to update_vehicle_swi;
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
end update_vehicle;
end pqp_vehicle_repository_swi;

/
