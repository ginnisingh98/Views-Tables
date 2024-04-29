--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: pqpvdapi.pkh 115.6 2003/03/13 19:17:09 sshetty ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_VEHICLE_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to create vehicle details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                             Reqd Type     Description
--  p_vehicle_details_id             yes  number
--  p_vehicle_type                   yes  varchar2
--  p_business_group_id              no   number
--  p_registration_number            yes  varchar2
--  p_make                           yes  varchar2
--  p_model                          yes  varchar2
--  p_date_first_registered          yes  date
--  p_engine_capacity_in_cc          yes number
--  p_fuel_type                      yes varchar2
--  p_fuel_card                      yes varchar2
--  p_currency_code                  yes varchar2
--  p_list_price                     yes number
--  p_business_group_id              no  number
--  p_accessory_value_at_startdate   no number
--  p_accessory_value_added_later    no number
--  p_capital_contributions          no number
--  p_private_use_contributions      no number
--  p_market_value_classic_car       no number
--  p_co2_emissions                  no number
--  p_vehicle_provider               no  varchar2
--  p_vehicle_ownership              no  varchar2
--  p_vehicle_identification_numbe   no  varchar2
--  p_object_version_number          yes number
--  p_vhd_attribute_category         no varchar2
--  p_vhd_attribute1                 no varchar2
--  p_vhd_attribute2                 no varchar2
--  p_vhd_attribute3                 no varchar2
--  p_vhd_attribute4                 no varchar2
--  p_vhd_attribute5                 no varchar2
--  p_vhd_attribute6                 no varchar2
--  p_vhd_attribute7                 no varchar2
--  p_vhd_attribute8                 no varchar2
--  p_vhd_attribute9                 no varchar2
--  p_vhd_attribute10                no varchar2
--  p_vhd_attribute11                no varchar2
--  p_vhd_attribute12                no varchar2
--  p_vhd_attribute13                no varchar2
--  p_vhd_attribute14                no varchar2
--  p_vhd_attribute15                no varchar2
--  p_vhd_attribute16                no varchar2
--  p_vhd_attribute17                no varchar2
--  p_vhd_attribute18                no varchar2
--  p_vhd_attribute19                no varchar2
--  p_vhd_attribute20                no varchar2
--  p_vhd_information_category       no varchar2
--  p_vhd_information1               no varchar2
--  p_vhd_information2               no varchar2
--  p_vhd_information3               no varchar2
--  p_vhd_information4               no varchar2
--  p_vhd_information5               no varchar2
--  p_vhd_information6               no varchar2
--  p_vhd_information7               no varchar2
--  p_vhd_information8               no varchar2
--  p_vhd_information9               no varchar2
--  p_vhd_information10              no varchar2
--  p_vhd_information11              no varchar2
--  p_vhd_information12              no varchar2
--  p_vhd_information13              no varchar2
--  p_vhd_information14              no varchar2
--  p_vhd_information15              no varchar2
--  p_vhd_information16              no varchar2
--  p_vhd_information17              no varchar2
--  p_vhd_information18              no varchar2
--  p_vhd_information19              no varchar2
--  p_vhd_information20              no varchar2

--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
procedure create_vehicle_details
(  p_effective_date                 in date   default NULL
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
  ,p_accessory_value_at_startdate   in number   default NULL
  ,p_accessory_value_added_later    in number   default NULL
--  ,p_capital_contributions        in number
--  ,p_private_use_contributions    in number
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
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_VEHICLE_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to update vehicle details.
--
-- Prerequisites:
--
--
-- In Parameters:

--  Name                         Reqd Type     Description
--p_effective_date               yes     date
--p_vehicle_details_id           yes     number
--p_object_version_number        yes     number
--p_vehicle_type                 no     varchar2
--p_registration_number          no     varchar2
--p_make                         no     varchar2
--p_model                        no     varchar2
--p_date_first_registered        no     date
--p_engine_capacity_in_cc        no     number
--p_fuel_type                    no     varchar2
--p_fuel_card                    no     varchar2
--p_currency_code                no     varchar2
--p_list_price                   no     number
--p_business_group_id            no     number
--p_accessory_value_at_startdate no     number
--p_accessory_value_added_later  no     number
--p_capital_contributions        no     number
--p_private_use_contributions    no     number
--p_market_value_classic_car     no     number
--p_co2_emissions                no     number
--p_vehicle_provider             no     varchar2
--p_vehicle_ownership            no     varchar2
--p_vehicle_identification_numbe  no     varchar2
--  p_vhd_attribute_category         no varchar2
--  p_vhd_attribute1                 no varchar2
--  p_vhd_attribute2                 no varchar2
--  p_vhd_attribute3                 no varchar2
--  p_vhd_attribute4                 no varchar2
--  p_vhd_attribute5                 no varchar2
--  p_vhd_attribute6                 no varchar2
--  p_vhd_attribute7                 no varchar2
--  p_vhd_attribute8                 no varchar2
--  p_vhd_attribute9                 no varchar2
--  p_vhd_attribute10                no varchar2
--  p_vhd_attribute11                no varchar2
--  p_vhd_attribute12                no varchar2
--  p_vhd_attribute13                no varchar2
--  p_vhd_attribute14                no varchar2
--  p_vhd_attribute15                no varchar2
--  p_vhd_attribute16                no varchar2
--  p_vhd_attribute17                no varchar2
--  p_vhd_attribute18                no varchar2
--  p_vhd_attribute19                no varchar2
--  p_vhd_attribute20                no varchar2
--  p_vhd_information_category       no varchar2
--  p_vhd_information1               no varchar2
--  p_vhd_information2               no varchar2
--  p_vhd_information3               no varchar2
--  p_vhd_information4               no varchar2
--  p_vhd_information5               no varchar2
--  p_vhd_information6               no varchar2
--  p_vhd_information7               no varchar2
--  p_vhd_information8               no varchar2
--  p_vhd_information9               no varchar2
--  p_vhd_information10              no varchar2
--  p_vhd_information11              no varchar2
--  p_vhd_information12              no varchar2
--  p_vhd_information13              no varchar2
--  p_vhd_information14              no varchar2
--  p_vhd_information15              no varchar2
--  p_vhd_information16              no varchar2
--  p_vhd_information17              no varchar2
--  p_vhd_information18              no varchar2
--  p_vhd_information19              no varchar2
--  p_vhd_information20              no varchar2
--p_vehicle_details_id           yes  number
--  p_object_version_number      yes number
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
procedure update_vehicle_details
  (p_effective_date               in     date   default NULL
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
  ,p_vehicle_identification_numbe in     varchar2  default hr_api.g_varchar2
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
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_VEHICLE_DETAILS >-----------------------|
-- ----------------------------------------------------------------------------
-- Description:
-- Business process to delete vehicle details.
--
-- Prerequisites:
--
--
-- In Parameters:
--p_vehicle_details_id                   in     number
--p_object_version_number                in     number

-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
procedure delete_vehicle_details
( p_vehicle_details_id                   in     number
 ,p_object_version_number                in     number
 );

end PQP_VEHICLE_DETAILS_API;

 

/
