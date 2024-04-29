--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_REPOSITORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_REPOSITORY_API" as
/* $Header: pqvreapi.pkb 120.0 2005/05/29 02:18:02 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEHICLE_REPOSITORY_API.';
l_currency_code  pqp_vehicle_repository_f.currency_code%TYPE;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vehicle
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_registration_number            in     varchar2
  ,p_vehicle_type                   in     varchar2
  ,p_vehicle_id_number              in     varchar2
  ,p_business_group_id              in     number
  ,p_make                           in     varchar2
  ,p_engine_capacity_in_cc          in     number
  ,p_fuel_type                      in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_vehicle_status                 in     varchar2
  ,p_vehicle_inactivity_reason      in     varchar2
  ,p_model                          in     varchar2
  ,p_initial_registration           in     date
  ,p_last_registration_renew_date   in     date
  ,p_list_price                     in     number
  ,p_accessory_value_at_startdate   in     number
  ,p_accessory_value_added_later    in     number
  ,p_market_value_classic_car       in     number
  ,p_fiscal_ratings                 in     number
  ,p_fiscal_ratings_uom             in     varchar2
  ,p_vehicle_provider               in     varchar2
  ,p_vehicle_ownership              in     varchar2
  ,p_shared_vehicle                 in     varchar2
  ,p_asset_number                   in     varchar2
  ,p_lease_contract_number          in     varchar2
  ,p_lease_contract_expiry_date     in     date
  ,p_taxation_method                in     varchar2
  ,p_fleet_info                     in     varchar2
  ,p_fleet_transfer_date            in     date
  ,p_color                          in     varchar2
  ,p_seating_capacity               in     number
  ,p_weight                         in     number
  ,p_weight_uom                     in     varchar2
  ,p_model_year                     in     number
  ,p_insurance_number               in     varchar2
  ,p_insurance_expiry_date          in     date
  ,p_comments                       in     varchar2
  ,p_vre_attribute_category         in     varchar2
  ,p_vre_attribute1                 in     varchar2
  ,p_vre_attribute2                 in     varchar2
  ,p_vre_attribute3                 in     varchar2
  ,p_vre_attribute4                 in     varchar2
  ,p_vre_attribute5                 in     varchar2
  ,p_vre_attribute6                 in     varchar2
  ,p_vre_attribute7                 in     varchar2
  ,p_vre_attribute8                 in     varchar2
  ,p_vre_attribute9                 in     varchar2
  ,p_vre_attribute10                in     varchar2
  ,p_vre_attribute11                in     varchar2
  ,p_vre_attribute12                in     varchar2
  ,p_vre_attribute13                in     varchar2
  ,p_vre_attribute14                in     varchar2
  ,p_vre_attribute15                in     varchar2
  ,p_vre_attribute16                in     varchar2
  ,p_vre_attribute17                in     varchar2
  ,p_vre_attribute18                in     varchar2
  ,p_vre_attribute19                in     varchar2
  ,p_vre_attribute20                in     varchar2
  ,p_vre_information_category       in     varchar2
  ,p_vre_information1               in     varchar2
  ,p_vre_information2               in     varchar2
  ,p_vre_information3               in     varchar2
  ,p_vre_information4               in     varchar2
  ,p_vre_information5               in     varchar2
  ,p_vre_information6               in     varchar2
  ,p_vre_information7               in     varchar2
  ,p_vre_information8               in     varchar2
  ,p_vre_information9               in     varchar2
  ,p_vre_information10              in     varchar2
  ,p_vre_information11              in     varchar2
  ,p_vre_information12              in     varchar2
  ,p_vre_information13              in     varchar2
  ,p_vre_information14              in     varchar2
  ,p_vre_information15              in     varchar2
  ,p_vre_information16              in     varchar2
  ,p_vre_information17              in     varchar2
  ,p_vre_information18              in     varchar2
  ,p_vre_information19              in     varchar2
  ,p_vre_information20              in     varchar2
  ,p_vehicle_repository_id          out    NOCOPY number
  ,p_object_version_number          out    NOCOPY number
  ,p_effective_start_date           out    NOCOPY date
  ,p_effective_end_date             out    NOCOPY date
 )
 is
  --
  -- Declare cursors and local variables
  --

   l_proc    varchar2(72) := g_package||'create_vehicle';
   l_message varchar2(2500) ;
   l_effective_date  date;

begin

  --used to get the currency code
  l_currency_code :=hr_general.DEFAULT_CURRENCY_CODE(p_business_group_id);

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --Truncate the incomming date parameter
  l_effective_date:=TRUNC(p_effective_date);
  --
  -- Issue a savepoint
  --
  savepoint create_vehicle;
  hr_utility.set_location(l_proc, 20);
  --
  -- Call Before Process User Hook
  --
  begin
    pqp_vehicle_repository_bk1.create_vehicle_b
  (p_effective_date                =>l_effective_date
  ,p_registration_number           =>p_registration_number
  ,p_vehicle_type                  =>p_vehicle_type
  ,p_vehicle_id_number             =>p_vehicle_id_number
  ,p_business_group_id             =>p_business_group_id
  ,p_make                          =>p_make
  ,p_engine_capacity_in_cc         =>p_engine_capacity_in_cc
  ,p_fuel_type                     =>p_fuel_type
  ,p_currency_code                 =>l_currency_code
  ,p_vehicle_status                =>p_vehicle_status
  ,p_vehicle_inactivity_reason     =>p_vehicle_inactivity_reason
  ,p_model                         =>p_model
  ,p_initial_registration          =>p_initial_registration
  ,p_last_registration_renew_date  =>p_last_registration_renew_date
  ,p_list_price                    =>p_list_price
  ,p_accessory_value_at_startdate  =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later   =>p_accessory_value_added_later
  ,p_market_value_classic_car      =>p_market_value_classic_car
  ,p_fiscal_ratings                =>p_fiscal_ratings
  ,p_fiscal_ratings_uom            =>p_fiscal_ratings_uom
  ,p_vehicle_provider              =>p_vehicle_provider
  ,p_vehicle_ownership             =>p_vehicle_ownership
  ,p_shared_vehicle                =>p_shared_vehicle
  ,p_asset_number                  =>p_asset_number
  ,p_lease_contract_number         =>p_lease_contract_number
  ,p_lease_contract_expiry_date    =>p_lease_contract_expiry_date
  ,p_taxation_method               =>p_taxation_method
  ,p_fleet_info                    =>p_fleet_info
  ,p_fleet_transfer_date           =>p_fleet_transfer_date
  ,p_color                         =>p_color
  ,p_seating_capacity              =>p_seating_capacity
  ,p_weight                        =>p_weight
  ,p_weight_uom                    =>p_weight_uom
  ,p_model_year                    =>p_model_year
  ,p_insurance_number              =>p_insurance_number
  ,p_insurance_expiry_date         =>p_insurance_expiry_date
  ,p_comments                      =>p_comments
  ,p_vre_attribute_category        =>p_vre_attribute_category
  ,p_vre_attribute1                =>p_vre_attribute1
  ,p_vre_attribute2                =>p_vre_attribute2
  ,p_vre_attribute3                =>p_vre_attribute3
  ,p_vre_attribute4                =>p_vre_attribute4
  ,p_vre_attribute5                =>p_vre_attribute5
  ,p_vre_attribute6                =>p_vre_attribute6
  ,p_vre_attribute7                =>p_vre_attribute7
  ,p_vre_attribute8                =>p_vre_attribute8
  ,p_vre_attribute9                =>p_vre_attribute9
  ,p_vre_attribute10               =>p_vre_attribute10
  ,p_vre_attribute11               =>p_vre_attribute11
  ,p_vre_attribute12               =>p_vre_attribute12
  ,p_vre_attribute13               =>p_vre_attribute13
  ,p_vre_attribute14               =>p_vre_attribute14
  ,p_vre_attribute15               =>p_vre_attribute15
  ,p_vre_attribute16               =>p_vre_attribute16
  ,p_vre_attribute17               =>p_vre_attribute17
  ,p_vre_attribute18               =>p_vre_attribute18
  ,p_vre_attribute19               =>p_vre_attribute19
  ,p_vre_attribute20               =>p_vre_attribute20
  ,p_vre_information_category      =>p_vre_information_category
  ,p_vre_information1              =>p_vre_information1
  ,p_vre_information2              =>p_vre_information2
  ,p_vre_information3              =>p_vre_information3
  ,p_vre_information4              =>p_vre_information4
  ,p_vre_information5              =>p_vre_information5
  ,p_vre_information6              =>p_vre_information6
  ,p_vre_information7              =>p_vre_information7
  ,p_vre_information8              =>p_vre_information8
  ,p_vre_information9              =>p_vre_information9
  ,p_vre_information10             =>p_vre_information10
  ,p_vre_information11             =>p_vre_information11
  ,p_vre_information12             =>p_vre_information12
  ,p_vre_information13             =>p_vre_information13
  ,p_vre_information14             =>p_vre_information14
  ,p_vre_information15             =>p_vre_information15
  ,p_vre_information16             =>p_vre_information16
  ,p_vre_information17             =>p_vre_information17
  ,p_vre_information18             =>p_vre_information18
  ,p_vre_information19             =>p_vre_information19
  ,p_vre_information20             =>p_vre_information20
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
pqp_vre_ins.ins
  (p_effective_date                =>l_effective_date
  ,p_registration_number           =>p_registration_number
  ,p_vehicle_type                  =>p_vehicle_type
  ,p_vehicle_id_number             =>p_vehicle_id_number
  ,p_business_group_id             =>p_business_group_id
  ,p_make                          =>p_make
  ,p_engine_capacity_in_cc         =>p_engine_capacity_in_cc
  ,p_fuel_type                     =>p_fuel_type
  ,p_currency_code                 =>l_currency_code
  ,p_vehicle_status                =>p_vehicle_status
  ,p_vehicle_inactivity_reason     =>p_vehicle_inactivity_reason
  ,p_model                         =>p_model
  ,p_initial_registration          =>p_initial_registration
  ,p_last_registration_renew_date  =>p_last_registration_renew_date
  ,p_list_price                    =>p_list_price
  ,p_accessory_value_at_startdate  =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later   =>p_accessory_value_added_later
  ,p_market_value_classic_car      =>p_market_value_classic_car
  ,p_fiscal_ratings                =>p_fiscal_ratings
  ,p_fiscal_ratings_uom            =>p_fiscal_ratings_uom
  ,p_vehicle_provider              =>p_vehicle_provider
  ,p_vehicle_ownership             =>p_vehicle_ownership
  ,p_shared_vehicle                =>p_shared_vehicle
  ,p_asset_number                  =>p_asset_number
  ,p_lease_contract_number         =>p_lease_contract_number
  ,p_lease_contract_expiry_date    =>p_lease_contract_expiry_date
  ,p_taxation_method               =>p_taxation_method
  ,p_fleet_info                    =>p_fleet_info
  ,p_fleet_transfer_date           =>p_fleet_transfer_date
  ,p_color                         =>p_color
  ,p_seating_capacity              =>p_seating_capacity
  ,p_weight                        =>p_weight
  ,p_weight_uom                    =>p_weight_uom
  ,p_model_year                    =>p_model_year
  ,p_insurance_number              =>p_insurance_number
  ,p_insurance_expiry_date         =>p_insurance_expiry_date
  ,p_comments                      =>p_comments
  ,p_vre_attribute_category        =>p_vre_attribute_category
  ,p_vre_attribute1                =>p_vre_attribute1
  ,p_vre_attribute2                =>p_vre_attribute2
  ,p_vre_attribute3                =>p_vre_attribute3
  ,p_vre_attribute4                =>p_vre_attribute4
  ,p_vre_attribute5                =>p_vre_attribute5
  ,p_vre_attribute6                =>p_vre_attribute6
  ,p_vre_attribute7                =>p_vre_attribute7
  ,p_vre_attribute8                =>p_vre_attribute8
  ,p_vre_attribute9                =>p_vre_attribute9
  ,p_vre_attribute10               =>p_vre_attribute10
  ,p_vre_attribute11               =>p_vre_attribute11
  ,p_vre_attribute12               =>p_vre_attribute12
  ,p_vre_attribute13               =>p_vre_attribute13
  ,p_vre_attribute14               =>p_vre_attribute14
  ,p_vre_attribute15               =>p_vre_attribute15
  ,p_vre_attribute16               =>p_vre_attribute16
  ,p_vre_attribute17               =>p_vre_attribute17
  ,p_vre_attribute18               =>p_vre_attribute18
  ,p_vre_attribute19               =>p_vre_attribute19
  ,p_vre_attribute20               =>p_vre_attribute20
  ,p_vre_information_category      =>p_vre_information_category
  ,p_vre_information1              =>p_vre_information1
  ,p_vre_information2              =>p_vre_information2
  ,p_vre_information3              =>p_vre_information3
  ,p_vre_information4              =>p_vre_information4
  ,p_vre_information5              =>p_vre_information5
  ,p_vre_information6              =>p_vre_information6
  ,p_vre_information7              =>p_vre_information7
  ,p_vre_information8              =>p_vre_information8
  ,p_vre_information9              =>p_vre_information9
  ,p_vre_information10             =>p_vre_information10
  ,p_vre_information11             =>p_vre_information11
  ,p_vre_information12             =>p_vre_information12
  ,p_vre_information13             =>p_vre_information13
  ,p_vre_information14             =>p_vre_information14
  ,p_vre_information15             =>p_vre_information15
  ,p_vre_information16             =>p_vre_information16
  ,p_vre_information17             =>p_vre_information17
  ,p_vre_information18             =>p_vre_information18
  ,p_vre_information19             =>p_vre_information19
  ,p_vre_information20             =>p_vre_information20
  ,p_vehicle_repository_id         =>p_vehicle_repository_id
  ,p_object_version_number         =>p_object_version_number
  ,p_effective_start_date          =>p_effective_start_date
  ,p_effective_end_date            =>p_effective_end_date

  ) ;


  --
  -- Call After Process User Hook
  --
  begin
  pqp_vehicle_repository_bk1.create_vehicle_a
  (   p_effective_date             =>l_effective_date
  ,p_registration_number           =>p_registration_number
  ,p_vehicle_type                  =>p_vehicle_type
  ,p_vehicle_id_number             =>p_vehicle_id_number
  ,p_business_group_id             =>p_business_group_id
  ,p_make                          =>p_make
  ,p_engine_capacity_in_cc         =>p_engine_capacity_in_cc
  ,p_fuel_type                     =>p_fuel_type
  ,p_currency_code                 =>l_currency_code
  ,p_vehicle_status                =>p_vehicle_status
  ,p_vehicle_inactivity_reason     =>p_vehicle_inactivity_reason
  ,p_model                         =>p_model
  ,p_initial_registration          =>p_initial_registration
  ,p_last_registration_renew_date  =>p_last_registration_renew_date
  ,p_list_price                    =>p_list_price
  ,p_accessory_value_at_startdate  =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later   =>p_accessory_value_added_later
  ,p_market_value_classic_car      =>p_market_value_classic_car
  ,p_fiscal_ratings                =>p_fiscal_ratings
  ,p_fiscal_ratings_uom            =>p_fiscal_ratings_uom
  ,p_vehicle_provider              =>p_vehicle_provider
  ,p_vehicle_ownership             =>p_vehicle_ownership
  ,p_shared_vehicle                =>p_shared_vehicle
  ,p_asset_number                  =>p_asset_number
  ,p_lease_contract_number         =>p_lease_contract_number
  ,p_lease_contract_expiry_date    =>p_lease_contract_expiry_date
  ,p_taxation_method               =>p_taxation_method
  ,p_fleet_info                    =>p_fleet_info
  ,p_fleet_transfer_date           =>p_fleet_transfer_date
  ,p_color                         =>p_color
  ,p_seating_capacity              =>p_seating_capacity
  ,p_weight                        =>p_weight
  ,p_weight_uom                    =>p_weight_uom
  ,p_model_year                    =>p_model_year
  ,p_insurance_number              =>p_insurance_number
  ,p_insurance_expiry_date         =>p_insurance_expiry_date
  ,p_comments                      =>p_comments
  ,p_vre_attribute_category        =>p_vre_attribute_category
  ,p_vre_attribute1                =>p_vre_attribute1
  ,p_vre_attribute2                =>p_vre_attribute2
  ,p_vre_attribute3                =>p_vre_attribute3
  ,p_vre_attribute4                =>p_vre_attribute4
  ,p_vre_attribute5                =>p_vre_attribute5
  ,p_vre_attribute6                =>p_vre_attribute6
  ,p_vre_attribute7                =>p_vre_attribute7
  ,p_vre_attribute8                =>p_vre_attribute8
  ,p_vre_attribute9                =>p_vre_attribute9
  ,p_vre_attribute10               =>p_vre_attribute10
  ,p_vre_attribute11               =>p_vre_attribute11
  ,p_vre_attribute12               =>p_vre_attribute12
  ,p_vre_attribute13               =>p_vre_attribute13
  ,p_vre_attribute14               =>p_vre_attribute14
  ,p_vre_attribute15               =>p_vre_attribute15
  ,p_vre_attribute16               =>p_vre_attribute16
  ,p_vre_attribute17               =>p_vre_attribute17
  ,p_vre_attribute18               =>p_vre_attribute18
  ,p_vre_attribute19               =>p_vre_attribute19
  ,p_vre_attribute20               =>p_vre_attribute20
  ,p_vre_information_category      =>p_vre_information_category
  ,p_vre_information1              =>p_vre_information1
  ,p_vre_information2              =>p_vre_information2
  ,p_vre_information3              =>p_vre_information3
  ,p_vre_information4              =>p_vre_information4
  ,p_vre_information5              =>p_vre_information5
  ,p_vre_information6              =>p_vre_information6
  ,p_vre_information7              =>p_vre_information7
  ,p_vre_information8              =>p_vre_information8
  ,p_vre_information9              =>p_vre_information9
  ,p_vre_information10             =>p_vre_information10
  ,p_vre_information11             =>p_vre_information11
  ,p_vre_information12             =>p_vre_information12
  ,p_vre_information13             =>p_vre_information13
  ,p_vre_information14             =>p_vre_information14
  ,p_vre_information15             =>p_vre_information15
  ,p_vre_information16             =>p_vre_information16
  ,p_vre_information17             =>p_vre_information17
  ,p_vre_information18             =>p_vre_information18
  ,p_vre_information19             =>p_vre_information19
  ,p_vre_information20             =>p_vre_information20
  ,p_vehicle_repository_id         =>p_vehicle_repository_id
  ,p_object_version_number         =>p_object_version_number
  ,p_effective_start_date          =>p_effective_start_date
  ,p_effective_end_date            =>p_effective_end_date
  );


  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_vehicle_repository_id        := p_vehicle_repository_id;
  p_object_version_number        := p_object_version_number ;
  p_effective_start_date         := p_effective_start_date ;
  p_effective_end_date           := p_effective_end_date ;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

 exception
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_vehicle;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vehicle_repository_id        := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_vehicle;
    p_vehicle_repository_id        := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_vehicle ;


-- ----------------------------------------------------------------------------
-- --------------------------< update_vehicle >------------------------
-- ----------------------------------------------------------------------------
--


procedure update_vehicle
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out NOCOPY number
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
 ,p_vre_information_category      in     varchar2
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
  ,p_effective_start_date         out    NOCOPY date
  ,p_effective_end_date           out    NOCOPY date
  )

IS
  l_proc    varchar2(72) := g_package||'update_vehicle';
  l_message varchar2(2500) ;
  l_effective_date date;
BEGIN

  --used to get the currency code
  l_currency_code :=hr_general.DEFAULT_CURRENCY_CODE(p_business_group_id);

  --
  -- Issue a savepoint
  --
  --truncate date parameter
  l_effective_date :=TRUNC(p_effective_date) ;
  savepoint update_vehicle;

  hr_utility.set_location(l_proc, 20);

  --
  -- Call Before Process User Hook
  --
  begin
  PQP_VEHICLE_REPOSITORY_BK2.update_vehicle_b
  ( p_effective_date                 =>l_effective_date
  ,p_datetrack_mode                  =>p_datetrack_mode
  ,p_vehicle_repository_id           =>p_vehicle_repository_id
  ,p_object_version_number           =>p_object_version_number
  ,p_registration_number             =>p_registration_number
  ,p_vehicle_type                    =>p_vehicle_type
  ,p_vehicle_id_number               =>p_vehicle_id_number
  ,p_business_group_id               =>p_business_group_id
  ,p_make                            =>p_make
  ,p_engine_capacity_in_cc           =>p_engine_capacity_in_cc
  ,p_fuel_type                       =>p_fuel_type
  ,p_currency_code                   =>l_currency_code
  ,p_vehicle_status                  =>p_vehicle_status
  ,p_vehicle_inactivity_reason       =>p_vehicle_inactivity_reason
  ,p_model                           =>p_model
  ,p_initial_registration            =>p_initial_registration
  ,p_last_registration_renew_date    =>p_last_registration_renew_date
  ,p_list_price                       =>p_list_price
  ,p_accessory_value_at_startdate    =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later     =>p_accessory_value_added_later
  ,p_market_value_classic_car        =>p_market_value_classic_car
  ,p_fiscal_ratings                  =>p_fiscal_ratings
  ,p_fiscal_ratings_uom              =>p_fiscal_ratings_uom
  ,p_vehicle_provider                =>p_vehicle_provider
  ,p_vehicle_ownership               =>p_vehicle_ownership
  ,p_shared_vehicle                  =>p_shared_vehicle
  ,p_asset_number                    =>p_asset_number
  ,p_lease_contract_number           =>p_lease_contract_number
  ,p_lease_contract_expiry_date      =>p_lease_contract_expiry_date
  ,p_taxation_method                 =>p_taxation_method
  ,p_fleet_info                      =>p_fleet_info
  ,p_fleet_transfer_date             =>p_fleet_transfer_date
  ,p_color                           =>p_color
  ,p_seating_capacity                =>p_seating_capacity
  ,p_weight                          =>p_weight
  ,p_weight_uom                      =>p_weight_uom
  ,p_model_year                      =>p_model_year
  ,p_insurance_number                =>p_insurance_number
  ,p_insurance_expiry_date           =>p_insurance_expiry_date
  ,p_comments                        =>p_comments
  ,p_vre_attribute_category          =>p_vre_attribute_category
  ,p_vre_attribute1                  =>p_vre_attribute1
  ,p_vre_attribute2                  =>p_vre_attribute2
  ,p_vre_attribute3                  =>p_vre_attribute3
  ,p_vre_attribute4                  =>p_vre_attribute4
  ,p_vre_attribute5                  =>p_vre_attribute5
  ,p_vre_attribute6                  =>p_vre_attribute6
  ,p_vre_attribute7                  =>p_vre_attribute7
  ,p_vre_attribute8                  =>p_vre_attribute8
  ,p_vre_attribute9                  =>p_vre_attribute9
  ,p_vre_attribute10                 =>p_vre_attribute10
  ,p_vre_attribute11                 =>p_vre_attribute11
  ,p_vre_attribute12                 =>p_vre_attribute12
  ,p_vre_attribute13                 =>p_vre_attribute13
  ,p_vre_attribute14                 =>p_vre_attribute14
  ,p_vre_attribute15                 =>p_vre_attribute15
  ,p_vre_attribute16                 =>p_vre_attribute16
  ,p_vre_attribute17                 =>p_vre_attribute17
  ,p_vre_attribute18                 =>p_vre_attribute18
  ,p_vre_attribute19                 =>p_vre_attribute19
  ,p_vre_attribute20                 =>p_vre_attribute20
  ,p_vre_information_category        =>p_vre_information_category
  ,p_vre_information1                =>p_vre_information1
  ,p_vre_information2                =>p_vre_information2
  ,p_vre_information3                =>p_vre_information3
  ,p_vre_information4                =>p_vre_information4
  ,p_vre_information5                =>p_vre_information5
  ,p_vre_information6                =>p_vre_information6
  ,p_vre_information7                =>p_vre_information7
  ,p_vre_information8                =>p_vre_information8
  ,p_vre_information9                =>p_vre_information9
  ,p_vre_information10               =>p_vre_information10
  ,p_vre_information11               =>p_vre_information11
  ,p_vre_information12               =>p_vre_information12
  ,p_vre_information13               =>p_vre_information13
  ,p_vre_information14               =>p_vre_information14
  ,p_vre_information15               =>p_vre_information15
  ,p_vre_information16               =>p_vre_information16
  ,p_vre_information17               =>p_vre_information17
  ,p_vre_information18               =>p_vre_information18
  ,p_vre_information19               =>p_vre_information19
  ,p_vre_information20               =>p_vre_information20
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'BP'
        );
  end;


pqp_vre_upd.upd
  (p_effective_date                    =>l_effective_date
  ,p_datetrack_mode                    =>p_datetrack_mode
  ,p_vehicle_repository_id             =>p_vehicle_repository_id
  ,p_object_version_number             =>p_object_version_number
  ,p_registration_number               =>p_registration_number
  ,p_vehicle_type                      =>p_vehicle_type
  ,p_vehicle_id_number                 =>p_vehicle_id_number
  ,p_business_group_id                 =>p_business_group_id
  ,p_make                              =>p_make
  ,p_engine_capacity_in_cc             =>p_engine_capacity_in_cc
  ,p_fuel_type                         =>p_fuel_type
  ,p_currency_code                     =>l_currency_code
  ,p_vehicle_status                    =>p_vehicle_status
  ,p_vehicle_inactivity_reason         =>p_vehicle_inactivity_reason
  ,p_model                             =>p_model
  ,p_initial_registration              =>p_initial_registration
  ,p_last_registration_renew_date      =>p_last_registration_renew_date
  ,p_list_price                        =>p_list_price
  ,p_accessory_value_at_startdate      =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later       =>p_accessory_value_added_later
  ,p_market_value_classic_car          =>p_market_value_classic_car
  ,p_fiscal_ratings                    =>p_fiscal_ratings
  ,p_fiscal_ratings_uom                =>p_fiscal_ratings_uom
  ,p_vehicle_provider                  =>p_vehicle_provider
  ,p_vehicle_ownership                 =>p_vehicle_ownership
  ,p_shared_vehicle                    =>p_shared_vehicle
  ,p_asset_number                      =>p_asset_number
  ,p_lease_contract_number             =>p_lease_contract_number
  ,p_lease_contract_expiry_date        =>p_lease_contract_expiry_date
  ,p_taxation_method                   =>p_taxation_method
  ,p_fleet_info                        =>p_fleet_info
  ,p_fleet_transfer_date               =>p_fleet_transfer_date
  ,p_color                             =>p_color
  ,p_seating_capacity                  =>p_seating_capacity
  ,p_weight                            =>p_weight
  ,p_weight_uom                        =>p_weight_uom
  ,p_model_year                        =>p_model_year
  ,p_insurance_number                  =>p_insurance_number
  ,p_insurance_expiry_date             =>p_insurance_expiry_date
  ,p_comments                           =>p_comments
  ,p_vre_attribute_category            =>p_vre_attribute_category
  ,p_vre_attribute1                    =>p_vre_attribute1
  ,p_vre_attribute2                    =>p_vre_attribute2
  ,p_vre_attribute3                    =>p_vre_attribute3
  ,p_vre_attribute4                    =>p_vre_attribute4
  ,p_vre_attribute5                    =>p_vre_attribute5
  ,p_vre_attribute6                    =>p_vre_attribute6
  ,p_vre_attribute7                    =>p_vre_attribute7
  ,p_vre_attribute8                    =>p_vre_attribute8
  ,p_vre_attribute9                    =>p_vre_attribute9
  ,p_vre_attribute10                   =>p_vre_attribute10
  ,p_vre_attribute11                   =>p_vre_attribute11
  ,p_vre_attribute12                   =>p_vre_attribute12
  ,p_vre_attribute13                   =>p_vre_attribute13
  ,p_vre_attribute14                   =>p_vre_attribute14
  ,p_vre_attribute15                   =>p_vre_attribute15
  ,p_vre_attribute16                   =>p_vre_attribute16
  ,p_vre_attribute17                   =>p_vre_attribute17
  ,p_vre_attribute18                   =>p_vre_attribute18
  ,p_vre_attribute19                   =>p_vre_attribute19
  ,p_vre_attribute20                   =>p_vre_attribute20
  ,p_vre_information_category          =>p_vre_information_category
  ,p_vre_information1                  =>p_vre_information1
  ,p_vre_information2                  =>p_vre_information2
  ,p_vre_information3                  =>p_vre_information3
  ,p_vre_information4                  =>p_vre_information4
  ,p_vre_information5                  =>p_vre_information5
  ,p_vre_information6                  =>p_vre_information6
  ,p_vre_information7                  =>p_vre_information7
  ,p_vre_information8                  =>p_vre_information8
  ,p_vre_information9                  =>p_vre_information9
  ,p_vre_information10                 =>p_vre_information10
  ,p_vre_information11                 =>p_vre_information11
  ,p_vre_information12                 =>p_vre_information12
  ,p_vre_information13                 =>p_vre_information13
  ,p_vre_information14                 =>p_vre_information14
  ,p_vre_information15                 =>p_vre_information15
  ,p_vre_information16                 =>p_vre_information16
  ,p_vre_information17                 =>p_vre_information17
  ,p_vre_information18                 =>p_vre_information18
  ,p_vre_information19                 =>p_vre_information19
  ,p_vre_information20                 =>p_vre_information20
  ,p_effective_start_date              =>p_effective_start_date
  ,p_effective_end_date                =>p_effective_end_date
  ) ;

  -- Call after Process User Hook
  --
  begin
  PQP_VEHICLE_REPOSITORY_BK2.update_vehicle_a
  ( p_effective_date                  =>l_effective_date
  ,p_datetrack_mode                  =>p_datetrack_mode
  ,p_vehicle_repository_id           =>p_vehicle_repository_id
  ,p_object_version_number           =>p_object_version_number
  ,p_registration_number             =>p_registration_number
  ,p_vehicle_type                    =>p_vehicle_type
  ,p_vehicle_id_number               =>p_vehicle_id_number
  ,p_business_group_id               =>p_business_group_id
  ,p_make                            =>p_make
  ,p_engine_capacity_in_cc           =>p_engine_capacity_in_cc
  ,p_fuel_type                       =>p_fuel_type
  ,p_currency_code                   =>l_currency_code
  ,p_vehicle_status                  =>p_vehicle_status
  ,p_vehicle_inactivity_reason       =>p_vehicle_inactivity_reason
  ,p_model                           =>p_model
  ,p_initial_registration            =>p_initial_registration
  ,p_last_registration_renew_date    =>p_last_registration_renew_date
  ,p_list_price                       =>p_list_price
  ,p_accessory_value_at_startdate    =>p_accessory_value_at_startdate
  ,p_accessory_value_added_later     =>p_accessory_value_added_later
  ,p_market_value_classic_car        =>p_market_value_classic_car
  ,p_fiscal_ratings                  =>p_fiscal_ratings
  ,p_fiscal_ratings_uom              =>p_fiscal_ratings_uom
  ,p_vehicle_provider                =>p_vehicle_provider
  ,p_vehicle_ownership               =>p_vehicle_ownership
  ,p_shared_vehicle                  =>p_shared_vehicle
  ,p_asset_number                    =>p_asset_number
  ,p_lease_contract_number           =>p_lease_contract_number
  ,p_lease_contract_expiry_date      =>p_lease_contract_expiry_date
  ,p_taxation_method                 =>p_taxation_method
  ,p_fleet_info                      =>p_fleet_info
  ,p_fleet_transfer_date             =>p_fleet_transfer_date
  ,p_color                           =>p_color
  ,p_seating_capacity                =>p_seating_capacity
  ,p_weight                          =>p_weight
  ,p_weight_uom                      =>p_weight_uom
  ,p_model_year                      =>p_model_year
  ,p_insurance_number                =>p_insurance_number
  ,p_insurance_expiry_date           =>p_insurance_expiry_date
  ,p_comments                        =>p_comments
  ,p_vre_attribute_category          =>p_vre_attribute_category
  ,p_vre_attribute1                  =>p_vre_attribute1
  ,p_vre_attribute2                  =>p_vre_attribute2
  ,p_vre_attribute3                  =>p_vre_attribute3
  ,p_vre_attribute4                  =>p_vre_attribute4
  ,p_vre_attribute5                  =>p_vre_attribute5
  ,p_vre_attribute6                  =>p_vre_attribute6
  ,p_vre_attribute7                  =>p_vre_attribute7
  ,p_vre_attribute8                  =>p_vre_attribute8
  ,p_vre_attribute9                  =>p_vre_attribute9
  ,p_vre_attribute10                 =>p_vre_attribute10
  ,p_vre_attribute11                 =>p_vre_attribute11
  ,p_vre_attribute12                 =>p_vre_attribute12
  ,p_vre_attribute13                 =>p_vre_attribute13
  ,p_vre_attribute14                 =>p_vre_attribute14
  ,p_vre_attribute15                 =>p_vre_attribute15
  ,p_vre_attribute16                 =>p_vre_attribute16
  ,p_vre_attribute17                 =>p_vre_attribute17
  ,p_vre_attribute18                 =>p_vre_attribute18
  ,p_vre_attribute19                 =>p_vre_attribute19
  ,p_vre_attribute20                 =>p_vre_attribute20
  ,p_vre_information_category        =>p_vre_information_category
  ,p_vre_information1                =>p_vre_information1
  ,p_vre_information2                =>p_vre_information2
  ,p_vre_information3                =>p_vre_information3
  ,p_vre_information4                =>p_vre_information4
  ,p_vre_information5                =>p_vre_information5
  ,p_vre_information6                =>p_vre_information6
  ,p_vre_information7                =>p_vre_information7
  ,p_vre_information8                =>p_vre_information8
  ,p_vre_information9                =>p_vre_information9
  ,p_vre_information10               =>p_vre_information10
  ,p_vre_information11               =>p_vre_information11
  ,p_vre_information12               =>p_vre_information12
  ,p_vre_information13               =>p_vre_information13
  ,p_vre_information14               =>p_vre_information14
  ,p_vre_information15               =>p_vre_information15
  ,p_vre_information16               =>p_vre_information16
  ,p_vre_information17               =>p_vre_information17
  ,p_vre_information18               =>p_vre_information18
  ,p_vre_information19               =>p_vre_information19
  ,p_vre_information20               =>p_vre_information20
  ,p_effective_start_date            =>p_effective_start_date
  ,p_effective_end_date              =>p_effective_end_date
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date         := p_effective_start_date;
  p_effective_end_date           := p_effective_end_date ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_vehicle;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_vehicle;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

END  update_vehicle;



-- ----------------------------------------------------------------------------
-- |--------------------------< delete_vehicle >------------------------
--|
-- ----------------------------------------------------------------------------
--
Procedure delete_vehicle
  (p_validate                         in     boolean
  ,p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_vehicle_repository_id            in     number
  ,p_object_version_number            in out NOCOPY number
  ,p_effective_start_date             out    NOCOPY date
  ,p_effective_end_date               out    NOCOPY date
  )
IS

  l_proc    varchar2(72) := g_package||'delete_vehicle';
  l_effective_date   date;

BEGIN
  l_effective_date:=TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vehicle;
  --
  hr_utility.set_location(l_proc, 20);

  PQP_VEHICLE_REPOSITORY_BK3.delete_vehicle_b
  (p_validate                 =>p_validate
  ,p_effective_date           =>l_effective_date
  ,p_datetrack_mode           =>p_datetrack_mode
  ,p_vehicle_repository_id    =>p_vehicle_repository_id
  ,p_object_version_number    =>p_object_version_number
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'BP'
        );
  end;

pqp_vre_del.del
  (p_effective_date                  =>l_effective_date
  ,p_datetrack_mode                  =>p_datetrack_mode
  ,p_vehicle_repository_id           =>p_vehicle_repository_id
  ,p_object_version_number           =>p_object_version_number
  ,p_effective_start_date            =>p_effective_start_date
  ,p_effective_end_date              =>p_effective_end_date
  );
  --
  -- Call Before Process User Hook
  --

  begin
  PQP_VEHICLE_REPOSITORY_BK3.delete_vehicle_a
  (p_validate                 =>p_validate
  ,p_effective_date           =>l_effective_date
  ,p_datetrack_mode           =>p_datetrack_mode
  ,p_vehicle_repository_id    =>p_vehicle_repository_id
  ,p_object_version_number    =>p_object_version_number
  ,p_effective_start_date     =>p_effective_start_date
  ,p_effective_end_date        =>p_effective_end_date
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_REPOSITORY_API'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  p_object_version_number        := p_object_version_number ;
  p_effective_start_date         := p_effective_start_date ;
  p_effective_end_date           := p_effective_end_date ;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_vehicle;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_vehicle;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
END delete_vehicle;


end PQP_VEHICLE_REPOSITORY_API;

/
