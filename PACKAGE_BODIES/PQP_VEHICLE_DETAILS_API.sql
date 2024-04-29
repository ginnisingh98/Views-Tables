--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_DETAILS_API" as
/* $Header: pqpvdapi.pkb 115.5 2003/01/22 00:56:38 tmehra ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEHICLE_DETAILS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_VEHICLE_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vehicle_details
 ( p_effective_date                 in date   default NULL
  ,p_vehicle_type                   in varchar2
  ,p_registration_number            in varchar2
  ,p_make                           in varchar2
  ,p_model                          in varchar2
  ,p_date_first_registered          in date
  ,p_engine_capacity_in_cc          in number
  ,p_fuel_type                      in varchar2
  ,p_fuel_card                      in varchar2
  ,p_currency_code                  in varchar2
  ,p_list_price                     in number
  ,p_business_group_id              in number
  ,p_accessory_value_at_startdate   in number     default NULL
  ,p_accessory_value_added_later    in number     default NULL
--  ,p_capital_contributions          in number
--  ,p_private_use_contributions      in number
  ,p_market_value_classic_car       in number     default NULL
  ,p_co2_emissions                  in number     default NULL
  ,p_vehicle_provider               in varchar2   default NULL
  ,p_vehicle_ownership              in varchar2   default NULL
  ,p_vehicle_identification_numbe   in varchar2   default NULL
  ,p_vhd_attribute_category         in varchar2
  ,p_vhd_attribute1                 in varchar2
  ,p_vhd_attribute2                 in varchar2
  ,p_vhd_attribute3                 in varchar2
  ,p_vhd_attribute4                 in varchar2
  ,p_vhd_attribute5                 in varchar2
  ,p_vhd_attribute6                 in varchar2
  ,p_vhd_attribute7                 in varchar2
  ,p_vhd_attribute8                 in varchar2
  ,p_vhd_attribute9                 in varchar2
  ,p_vhd_attribute10                in varchar2
  ,p_vhd_attribute11                in varchar2
  ,p_vhd_attribute12                in varchar2
  ,p_vhd_attribute13                in varchar2
  ,p_vhd_attribute14                in varchar2
  ,p_vhd_attribute15                in varchar2
  ,p_vhd_attribute16                in varchar2
  ,p_vhd_attribute17                in varchar2
  ,p_vhd_attribute18                in varchar2
  ,p_vhd_attribute19                in varchar2
  ,p_vhd_attribute20                in varchar2
  ,p_vhd_information_category       in varchar2
  ,p_vhd_information1               in varchar2
  ,p_vhd_information2               in varchar2
  ,p_vhd_information3               in varchar2
  ,p_vhd_information4               in varchar2
  ,p_vhd_information5               in varchar2
  ,p_vhd_information6               in varchar2
  ,p_vhd_information7               in varchar2
  ,p_vhd_information8               in varchar2
  ,p_vhd_information9               in varchar2
  ,p_vhd_information10              in varchar2
  ,p_vhd_information11              in varchar2
  ,p_vhd_information12              in varchar2
  ,p_vhd_information13              in varchar2
  ,p_vhd_information14              in varchar2
  ,p_vhd_information15              in varchar2
  ,p_vhd_information16              in varchar2
  ,p_vhd_information17              in varchar2
  ,p_vhd_information18              in varchar2
  ,p_vhd_information19              in varchar2
  ,p_vhd_information20              in varchar2
  ,p_vehicle_details_id             out nocopy number
  ,p_object_version_number          out nocopy number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_vehicle_details>';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_vehicle_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic

 pqp_pvd_ins.ins
  (p_effective_date                 => p_effective_date
  ,p_vehicle_type                   => p_vehicle_type
  ,p_registration_number            => p_registration_number
  ,p_make                           => p_make
  ,p_model                          => p_model
  ,p_date_first_registered          => p_date_first_registered
  ,p_engine_capacity_in_cc          => p_engine_capacity_in_cc
  ,p_fuel_type                      => p_fuel_type
  ,p_fuel_card                      => p_fuel_card
  ,p_currency_code                  => p_currency_code
  ,p_list_price                     => p_list_price
  ,p_business_group_id              => p_business_group_id
  ,p_accessory_value_at_startdate   => p_accessory_value_at_startdate
  ,p_accessory_value_added_later    => p_accessory_value_added_later
--  ,p_capital_contributions          => p_capital_contributions
--  ,p_private_use_contributions      => p_private_use_contributions
  ,p_market_value_classic_car       => p_market_value_classic_car
  ,p_co2_emissions                  => p_co2_emissions
  ,p_vehicle_provider               => p_vehicle_provider
  ,p_vehicle_ownership              => p_vehicle_ownership
  ,p_vehicle_identification_numbe   => p_vehicle_identification_numbe
  ,p_vhd_attribute_category         => p_vhd_attribute_category
  ,p_vhd_attribute1                 => p_vhd_attribute1
  ,p_vhd_attribute2                 => p_vhd_attribute2
  ,p_vhd_attribute3                 => p_vhd_attribute3
  ,p_vhd_attribute4                 => p_vhd_attribute4
  ,p_vhd_attribute5                 => p_vhd_attribute5
  ,p_vhd_attribute6                 => p_vhd_attribute6
  ,p_vhd_attribute7                 => p_vhd_attribute7
  ,p_vhd_attribute8                 => p_vhd_attribute8
  ,p_vhd_attribute9                 => p_vhd_attribute9
  ,p_vhd_attribute10                => p_vhd_attribute10
  ,p_vhd_attribute11                => p_vhd_attribute11
  ,p_vhd_attribute12                => p_vhd_attribute12
  ,p_vhd_attribute13                => p_vhd_attribute13
  ,p_vhd_attribute14                => p_vhd_attribute14
  ,p_vhd_attribute15                => p_vhd_attribute15
  ,p_vhd_attribute16                => p_vhd_attribute16
  ,p_vhd_attribute17                => p_vhd_attribute17
  ,p_vhd_attribute18                => p_vhd_attribute18
  ,p_vhd_attribute19                => p_vhd_attribute19
  ,p_vhd_attribute20                => p_vhd_attribute20
  ,p_vhd_information_category       => p_vhd_information_category
  ,p_vhd_information1               => p_vhd_information1
  ,p_vhd_information2               => p_vhd_information2
  ,p_vhd_information3               => p_vhd_information3
  ,p_vhd_information4               => p_vhd_information4
  ,p_vhd_information5               => p_vhd_information5
  ,p_vhd_information6               => p_vhd_information6
  ,p_vhd_information7               => p_vhd_information7
  ,p_vhd_information8               => p_vhd_information8
  ,p_vhd_information9               => p_vhd_information9
  ,p_vhd_information10              => p_vhd_information10
  ,p_vhd_information11              => p_vhd_information11
  ,p_vhd_information12              => p_vhd_information12
  ,p_vhd_information13              => p_vhd_information13
  ,p_vhd_information14              => p_vhd_information14
  ,p_vhd_information15              => p_vhd_information15
  ,p_vhd_information16              => p_vhd_information16
  ,p_vhd_information17              => p_vhd_information17
  ,p_vhd_information18              => p_vhd_information18
  ,p_vhd_information19              => p_vhd_information19
  ,p_vhd_information20              => p_vhd_information20
  ,p_vehicle_details_id             => p_vehicle_details_id
  ,p_object_version_number          => p_object_version_number
  );

  -- Call After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --if p_validate then
   -- raise hr_api.validate_enabled;
  --end if;
  --
  -- Set all output arguments
  --
  --p_vehicle_details_id     := NULL;
  --p_object_version_number  := NULL;
  --p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_vehicle_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --p_id                     := null;
    --p_object_version_number  := null;
    --p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_vehicle_details;
    p_vehicle_details_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_vehicle_details;

-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_VEHICLE_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vehicle_details
  (p_effective_date               in     date     default NULL
  ,p_vehicle_details_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_vehicle_type                 in     varchar2  default hr_api.g_varchar2
  ,p_registration_number          in     varchar2  default hr_api.g_varchar2
  ,p_make                         in     varchar2  default hr_api.g_varchar2
  ,p_model                        in     varchar2  default hr_api.g_varchar2
  ,p_date_first_registered        in     date      default hr_api.g_date
  ,p_engine_capacity_in_cc        in     number    default hr_api.g_number
  ,p_fuel_type                    in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card                    in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_list_price                   in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_accessory_value_at_startdate in     number    default hr_api.g_number
  ,p_accessory_value_added_later  in     number    default hr_api.g_number
--  ,p_capital_contributions        in     number    default hr_api.g_number
--  ,p_private_use_contributions    in     number    default hr_api.g_number
  ,p_market_value_classic_car     in     number    default hr_api.g_number
  ,p_co2_emissions                in     number    default hr_api.g_number
  ,p_vehicle_provider             in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_ownership            in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_identification_numbe in     varchar2 default hr_api.g_varchar2
  ,p_vhd_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information1             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information2             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information3             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information4             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information5             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information6             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information7             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information8             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information9             in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information10            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information11            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information12            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information13            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information14            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information15            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information16            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information17            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information18            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information19            in     varchar2  default hr_api.g_varchar2
  ,p_vhd_information20            in     varchar2  default hr_api.g_varchar2
 ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number pqp_vehicle_details.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_vehicle_details>';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_vehicle_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic

l_object_version_number := p_object_version_number;

pqp_pvd_upd.upd
  (p_effective_date               => p_effective_date
  ,p_vehicle_details_id           => p_vehicle_details_id
  ,p_object_version_number        => p_object_version_number
  ,p_vehicle_type                 => p_vehicle_type
  ,p_registration_number          => p_registration_number
  ,p_make                         => p_make
  ,p_model                        => p_model
  ,p_date_first_registered        => p_date_first_registered
  ,p_engine_capacity_in_cc        => p_engine_capacity_in_cc
  ,p_fuel_type                    => p_fuel_type
  ,p_fuel_card                    => p_fuel_card
  ,p_currency_code                => p_currency_code
  ,p_list_price                   => p_list_price
  ,p_business_group_id            => p_business_group_id
  ,p_accessory_value_at_startdate => p_accessory_value_at_startdate
  ,p_accessory_value_added_later  => p_accessory_value_added_later
--  ,p_capital_contributions        => p_capital_contributions
--  ,p_private_use_contributions    => p_private_use_contributions
  ,p_market_value_classic_car     => p_market_value_classic_car
  ,p_co2_emissions                => p_co2_emissions
  ,p_vehicle_provider             => p_vehicle_provider
  ,p_vehicle_ownership            => p_vehicle_ownership
  ,p_vehicle_identification_numbe => p_vehicle_identification_numbe
  ,p_vhd_attribute_category       => p_vhd_attribute_category
  ,p_vhd_attribute1               => p_vhd_attribute1
  ,p_vhd_attribute2               => p_vhd_attribute2
  ,p_vhd_attribute3               => p_vhd_attribute3
  ,p_vhd_attribute4               => p_vhd_attribute4
  ,p_vhd_attribute5               => p_vhd_attribute5
  ,p_vhd_attribute6               => p_vhd_attribute6
  ,p_vhd_attribute7               => p_vhd_attribute7
  ,p_vhd_attribute8               => p_vhd_attribute8
  ,p_vhd_attribute9               => p_vhd_attribute9
  ,p_vhd_attribute10              => p_vhd_attribute10
  ,p_vhd_attribute11              => p_vhd_attribute11
  ,p_vhd_attribute12              => p_vhd_attribute12
  ,p_vhd_attribute13              => p_vhd_attribute13
  ,p_vhd_attribute14              => p_vhd_attribute14
  ,p_vhd_attribute15              => p_vhd_attribute15
  ,p_vhd_attribute16              => p_vhd_attribute16
  ,p_vhd_attribute17              => p_vhd_attribute17
  ,p_vhd_attribute18              => p_vhd_attribute18
  ,p_vhd_attribute19              => p_vhd_attribute19
  ,p_vhd_attribute20              => p_vhd_attribute20
  ,p_vhd_information_category     => p_vhd_information_category
  ,p_vhd_information1             => p_vhd_information1
  ,p_vhd_information2             => p_vhd_information2
  ,p_vhd_information3             => p_vhd_information3
  ,p_vhd_information4             => p_vhd_information4
  ,p_vhd_information5             => p_vhd_information5
  ,p_vhd_information6             => p_vhd_information6
  ,p_vhd_information7             => p_vhd_information7
  ,p_vhd_information8             => p_vhd_information8
  ,p_vhd_information9             => p_vhd_information9
  ,p_vhd_information10            => p_vhd_information10
  ,p_vhd_information11            => p_vhd_information11
  ,p_vhd_information12            => p_vhd_information12
  ,p_vhd_information13            => p_vhd_information13
  ,p_vhd_information14            => p_vhd_information14
  ,p_vhd_information15            => p_vhd_information15
  ,p_vhd_information16            => p_vhd_information16
  ,p_vhd_information17            => p_vhd_information17
  ,p_vhd_information18            => p_vhd_information18
  ,p_vhd_information19            => p_vhd_information19
  ,p_vhd_information20            => p_vhd_information20
  );


  -- Call After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --if p_validate then
  --  raise hr_api.validate_enabled;
  --end if;
  --
  -- Set all output arguments
  --
  --p_object_version_number  := NULL;
  --p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_vehicle_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_vehicle_details;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_vehicle_details;

-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_VEHICLE_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_vehicle_details
(
  p_vehicle_details_id             in number
  ,p_object_version_number          in number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number pqp_vehicle_details.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'delete_vehicle_details>';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vehicle_details;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic

 pqp_pvd_del.del
  (p_vehicle_details_id             => p_vehicle_details_id
  ,p_object_version_number          => p_object_version_number
  );

  -- Call After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --if p_validate then
  --  raise hr_api.validate_enabled;
  --end if;
  --
  -- Set all output arguments
  --
  --p_object_version_number  := NULL;
  --p_some_warning           := <local_var_set_in_process_logic>;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_vehicle_details;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
   -- p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_vehicle_details;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_vehicle_details;
--
end PQP_VEHICLE_DETAILS_API;

/
