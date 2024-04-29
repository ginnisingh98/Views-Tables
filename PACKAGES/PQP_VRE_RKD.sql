--------------------------------------------------------
--  DDL for Package PQP_VRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VRE_RKD" AUTHID CURRENT_USER as
/* $Header: pqvrerhi.pkh 120.0.12010000.1 2008/07/28 11:26:09 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               IN DATE
  ,p_datetrack_mode               IN VARCHAR2
  ,p_validation_start_date        IN DATE
  ,p_validation_end_date          IN DATE
  ,p_vehicle_repository_id        IN NUMBER
  ,p_effective_start_date         IN DATE
  ,p_effective_end_date           IN DATE
  ,p_effective_start_date_o       IN DATE
  ,p_effective_end_date_o         IN DATE
  ,p_registration_number_o        IN VARCHAR2
  ,p_vehicle_type_o               IN VARCHAR2
  ,p_vehicle_id_number_o          IN VARCHAR2
  ,p_business_group_id_o          IN NUMBER
  ,p_make_o                       IN VARCHAR2
  ,p_model_o                      IN VARCHAR2
  ,p_initial_registration_o       IN DATE
  ,p_last_registration_renew_da_o IN DATE
  ,p_engine_capacity_in_cc_o      IN NUMBER
  ,p_fuel_type_o                  IN VARCHAR2
  ,p_currency_code_o              IN VARCHAR2
  ,p_list_price_o                 IN NUMBER
  ,p_accessory_value_at_startda_o IN NUMBER
  ,p_accessory_value_added_late_o IN NUMBER
  ,p_market_value_classic_car_o   IN NUMBER
  ,p_fiscal_ratings_o             IN NUMBER
  ,p_fiscal_ratings_uom_o         IN VARCHAR2
  ,p_vehicle_provider_o           IN VARCHAR2
  ,p_vehicle_ownership_o          IN VARCHAR2
  ,p_shared_vehicle_o             IN VARCHAR2
  ,p_vehicle_status_o             IN VARCHAR2
  ,p_vehicle_inactivity_reason_o  IN VARCHAR2
  ,p_asset_number_o               IN VARCHAR2
  ,p_lease_contract_number_o      IN VARCHAR2
  ,p_lease_contract_expiry_date_o IN DATE
  ,p_taxation_method_o            IN VARCHAR2
  ,p_fleet_info_o                 IN VARCHAR2
  ,p_fleet_transfer_date_o        IN DATE
  ,p_object_version_number_o      IN NUMBER
  ,p_color_o                      IN VARCHAR2
  ,p_seating_capacity_o           IN NUMBER
  ,p_weight_o                     IN NUMBER
  ,p_weight_uom_o                 IN VARCHAR2
  ,p_model_year_o                 IN NUMBER
  ,p_insurance_number_o           IN VARCHAR2
  ,p_insurance_expiry_date_o      IN DATE
  ,p_comments_o                   IN VARCHAR2
  ,p_vre_attribute_category_o     IN VARCHAR2
  ,p_vre_attribute1_o             IN VARCHAR2
  ,p_vre_attribute2_o             IN VARCHAR2
  ,p_vre_attribute3_o             IN VARCHAR2
  ,p_vre_attribute4_o             IN VARCHAR2
  ,p_vre_attribute5_o             IN VARCHAR2
  ,p_vre_attribute6_o             IN VARCHAR2
  ,p_vre_attribute7_o             IN VARCHAR2
  ,p_vre_attribute8_o             IN VARCHAR2
  ,p_vre_attribute9_o             IN VARCHAR2
  ,p_vre_attribute10_o            IN VARCHAR2
  ,p_vre_attribute11_o            IN VARCHAR2
  ,p_vre_attribute12_o            IN VARCHAR2
  ,p_vre_attribute13_o            IN VARCHAR2
  ,p_vre_attribute14_o            IN VARCHAR2
  ,p_vre_attribute15_o            IN VARCHAR2
  ,p_vre_attribute16_o            IN VARCHAR2
  ,p_vre_attribute17_o            IN VARCHAR2
  ,p_vre_attribute18_o            IN VARCHAR2
  ,p_vre_attribute19_o            IN VARCHAR2
  ,p_vre_attribute20_o            IN VARCHAR2
  ,p_vre_information_category_o   IN VARCHAR2
  ,p_vre_information1_o           IN VARCHAR2
  ,p_vre_information2_o           IN VARCHAR2
  ,p_vre_information3_o           IN VARCHAR2
  ,p_vre_information4_o           IN VARCHAR2
  ,p_vre_information5_o           IN VARCHAR2
  ,p_vre_information6_o           IN VARCHAR2
  ,p_vre_information7_o           IN VARCHAR2
  ,p_vre_information8_o           IN VARCHAR2
  ,p_vre_information9_o           IN VARCHAR2
  ,p_vre_information10_o          IN VARCHAR2
  ,p_vre_information11_o          IN VARCHAR2
  ,p_vre_information12_o          IN VARCHAR2
  ,p_vre_information13_o          IN VARCHAR2
  ,p_vre_information14_o          IN VARCHAR2
  ,p_vre_information15_o          IN VARCHAR2
  ,p_vre_information16_o          IN VARCHAR2
  ,p_vre_information17_o          IN VARCHAR2
  ,p_vre_information18_o          IN VARCHAR2
  ,p_vre_information19_o          IN VARCHAR2
  ,p_vre_information20_o          IN VARCHAR2
  );
--
end pqp_vre_rkd;

/
