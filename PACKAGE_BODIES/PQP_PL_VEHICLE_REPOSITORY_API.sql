--------------------------------------------------------
--  DDL for Package Body PQP_PL_VEHICLE_REPOSITORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PL_VEHICLE_REPOSITORY_API" as
/* $Header: pqvrepli.pkb 120.0 2005/10/16 22:52:12 ssekhar noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_vehicle >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pl_vehicle
  ( p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_vehicle_registration_number    in     varchar2
  ,p_vehicle_type                   in     varchar2
  ,p_vehicle_body_number            in     varchar2 default null
  ,p_business_group_id              in     number
  ,p_make                           in     varchar2
  ,p_engine_capacity_in_cc          in     number
  ,p_fuel_type                      in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_vehicle_status                 in     varchar2
  ,p_vehicle_inactivity_reason      in     varchar2
  ,p_model                          in     varchar2 default null
  ,p_initial_registration           in     date default null
  ,p_last_registration_renew_date   in     date default null
  ,p_list_price                     in     number default null
  ,p_accessory_value_at_startdate   in     number default null
  ,p_accessory_value_added_later    in     number default null
  ,p_market_value_classic_car       in     number default null
  ,p_fiscal_ratings                 in     number default null
  ,p_fiscal_ratings_uom             in     varchar2 default null
  ,p_vehicle_provider               in     varchar2 default null
  ,p_vehicle_ownership              in     varchar2 default null
  ,p_shared_vehicle                 in     varchar2 default null
  ,p_asset_number                   in     varchar2 default null
  ,p_lease_contract_number          in     varchar2 default null
  ,p_lease_contract_expiry_date     in     date default null
  ,p_taxation_method                in     varchar2 default null
  ,p_fleet_info                     in     varchar2 default null
  ,p_fleet_transfer_date            in     date     default null
  ,p_color                          in     varchar2 default null
  ,p_seating_capacity               in     number default null
  ,p_weight                         in     number default null
  ,p_weight_uom                     in     varchar2 default null
  ,p_year_of_manufacture            in     number default null
  ,p_insurance_number               in     varchar2 default null
  ,p_insurance_expiry_date          in     date default null
  ,p_comments                       in     varchar2 default null
  ,p_vre_attribute_category         in     varchar2 default null
  ,p_vre_attribute1                 in     varchar2 default null
  ,p_vre_attribute2                 in     varchar2 default null
  ,p_vre_attribute3                 in     varchar2 default null
  ,p_vre_attribute4                 in     varchar2 default null
  ,p_vre_attribute5                 in     varchar2 default null
  ,p_vre_attribute6                 in     varchar2 default null
  ,p_vre_attribute7                 in     varchar2 default null
  ,p_vre_attribute8                 in     varchar2 default null
  ,p_vre_attribute9                 in     varchar2 default null
  ,p_vre_attribute10                in     varchar2 default null
  ,p_vre_attribute11                in     varchar2 default null
  ,p_vre_attribute12                in     varchar2 default null
  ,p_vre_attribute13                in     varchar2 default null
  ,p_vre_attribute14                in     varchar2 default null
  ,p_vre_attribute15                in     varchar2 default null
  ,p_vre_attribute16                in     varchar2 default null
  ,p_vre_attribute17                in     varchar2 default null
  ,p_vre_attribute18                in     varchar2 default null
  ,p_vre_attribute19                in     varchar2 default null
  ,p_vre_attribute20                in     varchar2 default null
  ,p_vre_information_category       in     varchar2 default null
  ,p_vehicle_card_id_number         in     varchar2 default null
  ,p_owner                          in     varchar2 default null
  ,p_engine_number                  in     varchar2 default null
  ,p_date_of_first_inspection       in     varchar2 default null
  ,p_date_of_next_inspection        in     varchar2 default null
  ,p_other_technical_information    in     varchar2 default null
  ,p_vehicle_repository_id          out    NOCOPY number
  ,p_object_version_number          out    NOCOPY number
  ,p_effective_start_date           out    NOCOPY date
  ,p_effective_end_date             out    NOCOPY date
   ) is
   --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
     g_package :='pqp_pl_vehicle_repository_api.';
     l_proc    := g_package||'create_pl_vehicle';

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;


  hr_utility.set_location(l_proc, 6);


  --
  -- Call the Vehicle business process
  --
  pqp_vehicle_repository_api.create_vehicle
  (p_validate                       => p_validate
  ,p_effective_date                 => p_effective_date
  ,p_registration_number            => p_vehicle_registration_number
  ,p_vehicle_type                   => p_vehicle_type
  ,p_vehicle_id_number              => p_vehicle_body_number
  ,p_business_group_id              => p_business_group_id
  ,p_make                           => p_make
  ,p_engine_capacity_in_cc          => p_engine_capacity_in_cc
  ,p_fuel_type                      => p_fuel_type
  ,p_currency_code                  => p_currency_code
  ,p_vehicle_status                 => p_vehicle_status
  ,p_vehicle_inactivity_reason      => p_vehicle_inactivity_reason
  ,p_model                          => p_model
  ,p_initial_registration           => p_initial_registration
  ,p_last_registration_renew_date   => p_last_registration_renew_date
  ,p_list_price                     => p_list_price
  ,p_accessory_value_at_startdate   => p_accessory_value_at_startdate
  ,p_accessory_value_added_later    => p_accessory_value_added_later
  ,p_market_value_classic_car       => p_market_value_classic_car
  ,p_fiscal_ratings                 => p_fiscal_ratings
  ,p_fiscal_ratings_uom             => p_fiscal_ratings_uom
  ,p_vehicle_provider               => p_vehicle_provider
  ,p_vehicle_ownership              => p_vehicle_ownership
  ,p_shared_vehicle                 => p_shared_vehicle
  ,p_asset_number                   => p_asset_number
  ,p_lease_contract_number          => p_lease_contract_number
  ,p_lease_contract_expiry_date     => p_lease_contract_expiry_date
  ,p_taxation_method                => p_taxation_method
  ,p_fleet_info                     => p_fleet_info
  ,p_fleet_transfer_date            => p_fleet_transfer_date
  ,p_color                          => p_color
  ,p_seating_capacity               => p_seating_capacity
  ,p_weight                         => p_weight
  ,p_weight_uom                     => p_weight_uom
  ,p_model_year                     => p_year_of_manufacture
  ,p_insurance_number               => p_insurance_number
  ,p_insurance_expiry_date          => p_insurance_expiry_date
  ,p_comments                       => p_comments
  ,p_vre_attribute_category         => p_vre_attribute_category
  ,p_vre_attribute1                 => p_vre_attribute1
  ,p_vre_attribute2                 => p_vre_attribute2
  ,p_vre_attribute3                 => p_vre_attribute3
  ,p_vre_attribute4                 => p_vre_attribute4
  ,p_vre_attribute5                 => p_vre_attribute5
  ,p_vre_attribute6                 => p_vre_attribute6
  ,p_vre_attribute7                 => p_vre_attribute7
  ,p_vre_attribute8                 => p_vre_attribute8
  ,p_vre_attribute9                 => p_vre_attribute9
  ,p_vre_attribute10                => p_vre_attribute10
  ,p_vre_attribute11                => p_vre_attribute11
  ,p_vre_attribute12                => p_vre_attribute12
  ,p_vre_attribute13                => p_vre_attribute13
  ,p_vre_attribute14                => p_vre_attribute14
  ,p_vre_attribute15                => p_vre_attribute15
  ,p_vre_attribute16                => p_vre_attribute16
  ,p_vre_attribute17                => p_vre_attribute17
  ,p_vre_attribute18                => p_vre_attribute18
  ,p_vre_attribute19                => p_vre_attribute19
  ,p_vre_attribute20                => p_vre_attribute20
  ,p_vre_information_category       => p_vre_information_category
  ,p_vre_information1               => p_vehicle_card_id_number
  ,p_vre_information2               => p_owner
  ,p_vre_information3               => p_engine_number
  ,p_vre_information4               => p_date_of_first_inspection
  ,p_vre_information5               => p_date_of_next_inspection
  ,p_vre_information6               => p_other_technical_information
  ,p_vre_information7               => null
  ,p_vre_information8               => null
  ,p_vre_information9               => null
  ,p_vre_information10              => null
  ,p_vre_information11              => null
  ,p_vre_information12              => null
  ,p_vre_information13              => null
  ,p_vre_information14              => null
  ,p_vre_information15              => null
  ,p_vre_information16              => null
  ,p_vre_information17              => null
  ,p_vre_information18              => null
  ,p_vre_information19              => null
  ,p_vre_information20              => null
  ,p_vehicle_repository_id          => p_vehicle_repository_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
 );
  --
--
end create_pl_vehicle;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pl_vehicle >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_pl_vehicle
  (p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_repository_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_vehicle_registration_number  in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_type                 in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_body_number          in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_make                         in     varchar2  default hr_api.g_varchar2
  ,p_engine_capacity_in_cc        in     number    default hr_api.g_number
  ,p_fuel_type                    in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_status               in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_inactivity_reason    in     varchar2  default hr_api.g_varchar2
  ,p_model                        in     varchar2  default hr_api.g_varchar2
  ,p_initial_registration         in     date      default hr_api.g_date
  ,p_last_registration_renew_date in     date      default hr_api.g_date
  ,p_list_price                   in     number    default hr_api.g_number
  ,p_accessory_value_at_startdate in     number    default hr_api.g_number
  ,p_accessory_value_added_later  in     number    default hr_api.g_number
  ,p_market_value_classic_car     in     number    default hr_api.g_number
  ,p_fiscal_ratings               in     number    default hr_api.g_number
  ,p_fiscal_ratings_uom           in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_provider             in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_ownership            in     varchar2  default hr_api.g_varchar2
  ,p_shared_vehicle               in     varchar2  default hr_api.g_varchar2
  ,p_asset_number                 in     varchar2  default hr_api.g_varchar2
  ,p_lease_contract_number        in     varchar2  default hr_api.g_varchar2
  ,p_lease_contract_expiry_date   in     date      default hr_api.g_date
  ,p_taxation_method              in     varchar2  default hr_api.g_varchar2
  ,p_fleet_info                   in     varchar2  default hr_api.g_varchar2
  ,p_fleet_transfer_date          in     date      default hr_api.g_date
  ,p_color                        in     varchar2  default hr_api.g_varchar2
  ,p_seating_capacity             in     number    default hr_api.g_number
  ,p_weight                       in     number    default hr_api.g_number
  ,p_weight_uom                   in     varchar2  default hr_api.g_varchar2
  ,p_year_of_manufacture          in     number    default hr_api.g_number
  ,p_insurance_number             in     varchar2  default hr_api.g_varchar2
  ,p_insurance_expiry_date        in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_vre_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_vre_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_vehicle_card_id_number       in     varchar2  default hr_api.g_varchar2
  ,p_owner                        in     varchar2  default hr_api.g_varchar2
  ,p_engine_number                in     varchar2  default hr_api.g_varchar2
  ,p_date_of_first_inspection     in     varchar2  default hr_api.g_varchar2
  ,p_date_of_next_inspection      in     varchar2  default hr_api.g_varchar2
  ,p_other_technical_information  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    NOCOPY date
  ,p_effective_end_date           out    NOCOPY date
  ) is

   l_proc                 varchar2(72);
   l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
     g_package :='pqp_pl_vehicle_repository_api.';
     l_proc    := g_package||'update_pl_vehicle';

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg into l_legislation_code;

  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;


  hr_utility.set_location(l_proc, 6);
  -- Call  for  Update Vehicle business process
    pqp_vehicle_repository_api.update_vehicle
  		  (p_validate                       => p_validate
                  ,p_effective_date                 => p_effective_date
		  ,p_datetrack_mode                 => p_datetrack_mode
		  ,p_vehicle_repository_id          => p_vehicle_repository_id
		  ,p_object_version_number          => p_object_version_number
		  ,p_registration_number            => p_vehicle_registration_number
		  ,p_vehicle_type                   => p_vehicle_type
		  ,p_vehicle_id_number              => p_vehicle_body_number
		  ,p_business_group_id              => p_business_group_id
		  ,p_make                           => p_make
		  ,p_engine_capacity_in_cc          => p_engine_capacity_in_cc
		  ,p_fuel_type                      => p_fuel_type
		  ,p_currency_code                  => p_currency_code
		  ,p_vehicle_status                 => p_vehicle_status
		  ,p_vehicle_inactivity_reason      => p_vehicle_inactivity_reason
		  ,p_model                          => p_model
		  ,p_initial_registration           => p_initial_registration
		  ,p_last_registration_renew_date   => p_last_registration_renew_date
		  ,p_list_price                     => p_list_price
		  ,p_accessory_value_at_startdate   => p_accessory_value_at_startdate
		  ,p_accessory_value_added_later    => p_accessory_value_added_later
		  ,p_market_value_classic_car       => p_market_value_classic_car
		  ,p_fiscal_ratings                 => p_fiscal_ratings
		  ,p_fiscal_ratings_uom             => p_fiscal_ratings_uom
		  ,p_vehicle_provider               => p_vehicle_provider
                  ,p_vehicle_ownership              => p_vehicle_ownership
                  ,p_shared_vehicle                 => p_shared_vehicle
                  ,p_asset_number                   => p_asset_number
                  ,p_lease_contract_number          => p_lease_contract_number
                  ,p_lease_contract_expiry_date     => p_lease_contract_expiry_date
                  ,p_taxation_method                => p_taxation_method
                  ,p_fleet_info                     => p_fleet_info
                  ,p_fleet_transfer_date            => p_fleet_transfer_date
                  ,p_color                          => p_color
                  ,p_seating_capacity               => p_seating_capacity
                  ,p_weight                         => p_weight
                  ,p_weight_uom                     => p_weight_uom
                  ,p_model_year                     => p_year_of_manufacture
                  ,p_insurance_number               => p_insurance_number
                  ,p_insurance_expiry_date          => p_insurance_expiry_date
                  ,p_comments                       => p_comments
                  ,p_vre_attribute_category         => p_vre_attribute_category
                  ,p_vre_attribute1                => p_vre_attribute1
                  ,p_vre_attribute2                 => p_vre_attribute2
                  ,p_vre_attribute3                 => p_vre_attribute3
                  ,p_vre_attribute4                 => p_vre_attribute4
                  ,p_vre_attribute5                 => p_vre_attribute5
                  ,p_vre_attribute6                 => p_vre_attribute6
                  ,p_vre_attribute7                 => p_vre_attribute7
                  ,p_vre_attribute8                 => p_vre_attribute8
                  ,p_vre_attribute9                 => p_vre_attribute9
                  ,p_vre_attribute10                => p_vre_attribute10
                  ,p_vre_attribute11                => p_vre_attribute11
                  ,p_vre_attribute12                => p_vre_attribute12
                  ,p_vre_attribute13                => p_vre_attribute13
                  ,p_vre_attribute14                => p_vre_attribute14
                  ,p_vre_attribute15                => p_vre_attribute15
                  ,p_vre_attribute16                => p_vre_attribute16
                  ,p_vre_attribute17                => p_vre_attribute17
                  ,p_vre_attribute18                => p_vre_attribute18
                  ,p_vre_attribute19                => p_vre_attribute19
                  ,p_vre_attribute20                => p_vre_attribute20
                  ,p_vre_information_category       => p_vre_information_category
                  ,p_vre_information1               => p_vehicle_card_id_number
  		  ,p_vre_information2               => p_owner
  		  ,p_vre_information3               => p_engine_number
  		  ,p_vre_information4               => p_date_of_first_inspection
		  ,p_vre_information5               => p_date_of_next_inspection
		  ,p_vre_information6               => p_other_technical_information
		  ,p_vre_information7               => null
                  ,p_vre_information8               => null
                  ,p_vre_information9               => null
                  ,p_vre_information10              => null
                  ,p_vre_information11              => null
                  ,p_vre_information12              => null
                  ,p_vre_information13              => null
                  ,p_vre_information14              => null
                  ,p_vre_information15              => null
                  ,p_vre_information16              => null
                  ,p_vre_information17              => null
                  ,p_vre_information18              => null
                  ,p_vre_information19              => null
                  ,p_vre_information20              => null
                  ,p_effective_start_date           => p_effective_start_date
                  ,p_effective_end_date             => p_effective_end_date
                 );

End Update_pl_vehicle;
end pqp_pl_vehicle_repository_api;

/
