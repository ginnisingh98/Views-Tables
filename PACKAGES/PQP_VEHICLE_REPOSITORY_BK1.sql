--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_REPOSITORY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_REPOSITORY_BK1" AUTHID CURRENT_USER as
/* $Header: pqvreapi.pkh 120.1 2005/10/02 02:28:58 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_vehicle_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vehicle_b
  (p_effective_date                 in     date
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
  );



--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_vehicle_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vehicle_a
  (p_effective_date                 in     date
  ,p_registration_number            in     varchar2
  ,p_vehicle_type                   in     varchar2
  ,p_vehicle_id_number              in     varchar2
  ,p_business_group_id              in     number
  ,p_make                           in     varchar2
  ,p_engine_capacity_in_cc          in     number
  ,p_fuel_type                      in     varchar2
  ,p_currency_code                  in     varchar2
  ,p_vehicle_status                 in     varchar2
  ,p_vehicle_inactivity_reason        in     varchar2
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
  ,p_vehicle_repository_id          in     number
  ,p_object_version_number          in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  );
--
end PQP_VEHICLE_REPOSITORY_BK1;

 

/
