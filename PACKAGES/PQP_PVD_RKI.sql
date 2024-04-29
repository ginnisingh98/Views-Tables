--------------------------------------------------------
--  DDL for Package PQP_PVD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PVD_RKI" AUTHID CURRENT_USER as
/* $Header: pqpvdrhi.pkh 120.0 2005/05/29 02:09:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_vehicle_details_id           in number
  ,p_vehicle_type                 in varchar2
  ,p_business_group_id            in number
  ,p_registration_number          in varchar2
  ,p_make                         in varchar2
  ,p_model                        in varchar2
  ,p_date_first_registered        in date
  ,p_engine_capacity_in_cc        in number
  ,p_fuel_type                    in varchar2
  ,p_fuel_card                    in varchar2
  ,p_currency_code                in varchar2
  ,p_list_price                   in number
  ,p_accessory_value_at_startdate in number
  ,p_accessory_value_added_later  in number
--  ,p_capital_contributions        in number
--  ,p_private_use_contributions    in number
  ,p_market_value_classic_car     in number
  ,p_co2_emissions                in number
  ,p_vehicle_provider             in varchar2
  ,p_object_version_number        in number
  ,p_vehicle_identification_numbe in varchar2
  ,p_vehicle_ownership            in varchar2
  ,p_vhd_attribute_category       in varchar2
  ,p_vhd_attribute1               in varchar2
  ,p_vhd_attribute2               in varchar2
  ,p_vhd_attribute3               in varchar2
  ,p_vhd_attribute4               in varchar2
  ,p_vhd_attribute5               in varchar2
  ,p_vhd_attribute6               in varchar2
  ,p_vhd_attribute7               in varchar2
  ,p_vhd_attribute8               in varchar2
  ,p_vhd_attribute9               in varchar2
  ,p_vhd_attribute10              in varchar2
  ,p_vhd_attribute11              in varchar2
  ,p_vhd_attribute12              in varchar2
  ,p_vhd_attribute13              in varchar2
  ,p_vhd_attribute14              in varchar2
  ,p_vhd_attribute15              in varchar2
  ,p_vhd_attribute16              in varchar2
  ,p_vhd_attribute17              in varchar2
  ,p_vhd_attribute18              in varchar2
  ,p_vhd_attribute19              in varchar2
  ,p_vhd_attribute20              in varchar2
  ,p_vhd_information_category     in varchar2
  ,p_vhd_information1             in varchar2
  ,p_vhd_information2             in varchar2
  ,p_vhd_information3             in varchar2
  ,p_vhd_information4             in varchar2
  ,p_vhd_information5             in varchar2
  ,p_vhd_information6             in varchar2
  ,p_vhd_information7             in varchar2
  ,p_vhd_information8             in varchar2
  ,p_vhd_information9             in varchar2
  ,p_vhd_information10            in varchar2
  ,p_vhd_information11            in varchar2
  ,p_vhd_information12            in varchar2
  ,p_vhd_information13            in varchar2
  ,p_vhd_information14            in varchar2
  ,p_vhd_information15            in varchar2
  ,p_vhd_information16            in varchar2
  ,p_vhd_information17            in varchar2
  ,p_vhd_information18            in varchar2
  ,p_vhd_information19            in varchar2
  ,p_vhd_information20            in varchar2
  );
end pqp_pvd_rki;

 

/
