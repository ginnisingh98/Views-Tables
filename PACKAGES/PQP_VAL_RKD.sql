--------------------------------------------------------
--  DDL for Package PQP_VAL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VAL_RKD" AUTHID CURRENT_USER as
/* $Header: pqvalrhi.pkh 120.0.12010000.1 2008/07/28 11:25:43 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_vehicle_allocation_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_assignment_id_o              in number
  ,p_business_group_id_o          in number
  ,p_across_assignments_o         in varchar2
  ,p_vehicle_repository_id_o      in number
  ,p_usage_type_o                 in varchar2
  ,p_capital_contribution_o       in number
  ,p_private_contribution_o       in number
  ,p_default_vehicle_o            in varchar2
  ,p_fuel_card_o                  in varchar2
  ,p_fuel_card_number_o           in varchar2
  ,p_calculation_method_o         in varchar2
  ,p_rates_table_id_o             in number
  ,p_element_type_id_o            in number
  ,p_private_use_flag_o		  in varchar2
  ,p_insurance_number_o		  in varchar2
  ,p_insurance_expiry_date_o      in date
  ,p_val_attribute_category_o     in varchar2
  ,p_val_attribute1_o             in varchar2
  ,p_val_attribute2_o             in varchar2
  ,p_val_attribute3_o             in varchar2
  ,p_val_attribute4_o             in varchar2
  ,p_val_attribute5_o             in varchar2
  ,p_val_attribute6_o             in varchar2
  ,p_val_attribute7_o             in varchar2
  ,p_val_attribute8_o             in varchar2
  ,p_val_attribute9_o             in varchar2
  ,p_val_attribute10_o            in varchar2
  ,p_val_attribute11_o            in varchar2
  ,p_val_attribute12_o            in varchar2
  ,p_val_attribute13_o            in varchar2
  ,p_val_attribute14_o            in varchar2
  ,p_val_attribute15_o            in varchar2
  ,p_val_attribute16_o            in varchar2
  ,p_val_attribute17_o            in varchar2
  ,p_val_attribute18_o            in varchar2
  ,p_val_attribute19_o            in varchar2
  ,p_val_attribute20_o            in varchar2
  ,p_val_information_category_o   in varchar2
  ,p_val_information1_o           in varchar2
  ,p_val_information2_o           in varchar2
  ,p_val_information3_o           in varchar2
  ,p_val_information4_o           in varchar2
  ,p_val_information5_o           in varchar2
  ,p_val_information6_o           in varchar2
  ,p_val_information7_o           in varchar2
  ,p_val_information8_o           in varchar2
  ,p_val_information9_o           in varchar2
  ,p_val_information10_o          in varchar2
  ,p_val_information11_o          in varchar2
  ,p_val_information12_o          in varchar2
  ,p_val_information13_o          in varchar2
  ,p_val_information14_o          in varchar2
  ,p_val_information15_o          in varchar2
  ,p_val_information16_o          in varchar2
  ,p_val_information17_o          in varchar2
  ,p_val_information18_o          in varchar2
  ,p_val_information19_o          in varchar2
  ,p_val_information20_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_fuel_benefit_o               in varchar2
  ,p_sliding_rates_info_o         in varchar2
  );
--
end pqp_val_rkd;

/
