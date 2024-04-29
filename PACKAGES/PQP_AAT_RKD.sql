--------------------------------------------------------
--  DDL for Package PQP_AAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAT_RKD" AUTHID CURRENT_USER as
/* $Header: pqaatrhi.pkh 120.2.12010000.2 2009/07/01 10:54:32 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< after_delete >------------------------------|
-- ---------------------------------------------------------------------------+
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_assignment_attribute_id      in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_assignment_id_o              in number
  ,p_contract_type_o              in varchar2
  ,p_work_pattern_o               in varchar2
  ,p_start_day_o                  in varchar2
  ,p_object_version_number_o      in number
  ,p_primary_company_car_o        in number
  ,p_primary_car_fuel_benefit_o   in varchar2
  ,p_primary_class_1a_o           in varchar2
  ,p_primary_capital_contributi_o in number
  ,p_primary_private_contributi_o in number
  ,p_secondary_company_car_o      in number
  ,p_secondary_car_fuel_benefit_o in varchar2
  ,p_secondary_class_1a_o         in varchar2
  ,p_secondary_capital_contribu_o in number
  ,p_secondary_private_contribu_o in number
  ,p_company_car_calc_method_o    in varchar2
  ,p_company_car_rates_table_id_o in number
  ,p_company_car_secondary_tabl_o in number
  ,p_private_car_o                in number
  ,p_private_car_calc_method_o    in varchar2
  ,p_private_car_rates_table_id_o in number
  ,p_private_car_essential_tabl_o in number
  ,p_tp_is_teacher_o              in varchar2
  ,p_tp_headteacher_grp_code_o    in number  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade_o       in varchar2
  ,p_tp_safeguarded_grade_id_o    in number
  ,p_tp_safeguarded_rate_type_o   in varchar2
  ,p_tp_safeguarded_rate_id_o     in number
  ,p_tp_spinal_point_id_o         in number
  ,p_tp_elected_pension_o         in varchar2
  ,p_tp_fast_track_o              in varchar2
  ,p_aat_attribute_category_o     in varchar2
  ,p_aat_attribute1_o             in varchar2
  ,p_aat_attribute2_o             in varchar2
  ,p_aat_attribute3_o             in varchar2
  ,p_aat_attribute4_o             in varchar2
  ,p_aat_attribute5_o             in varchar2
  ,p_aat_attribute6_o             in varchar2
  ,p_aat_attribute7_o             in varchar2
  ,p_aat_attribute8_o             in varchar2
  ,p_aat_attribute9_o             in varchar2
  ,p_aat_attribute10_o            in varchar2
  ,p_aat_attribute11_o            in varchar2
  ,p_aat_attribute12_o            in varchar2
  ,p_aat_attribute13_o            in varchar2
  ,p_aat_attribute14_o            in varchar2
  ,p_aat_attribute15_o            in varchar2
  ,p_aat_attribute16_o            in varchar2
  ,p_aat_attribute17_o            in varchar2
  ,p_aat_attribute18_o            in varchar2
  ,p_aat_attribute19_o            in varchar2
  ,p_aat_attribute20_o            in varchar2
  ,p_aat_information_category_o   in varchar2
  ,p_aat_information1_o           in varchar2
  ,p_aat_information2_o           in varchar2
  ,p_aat_information3_o           in varchar2
  ,p_aat_information4_o           in varchar2
  ,p_aat_information5_o           in varchar2
  ,p_aat_information6_o           in varchar2
  ,p_aat_information7_o           in varchar2
  ,p_aat_information8_o           in varchar2
  ,p_aat_information9_o           in varchar2
  ,p_aat_information10_o          in varchar2
  ,p_aat_information11_o          in varchar2
  ,p_aat_information12_o          in varchar2
  ,p_aat_information13_o          in varchar2
  ,p_aat_information14_o          in varchar2
  ,p_aat_information15_o          in varchar2
  ,p_aat_information16_o          in varchar2
  ,p_aat_information17_o          in varchar2
  ,p_aat_information18_o          in varchar2
  ,p_aat_information19_o          in varchar2
  ,p_aat_information20_o          in varchar2
  ,p_lgps_process_flag_o            in varchar2
  ,p_lgps_exclusion_type_o          in varchar2
  ,p_lgps_pensionable_pay_o         in varchar2
  ,p_lgps_trans_arrang_flag_o       in varchar2
  ,p_lgps_membership_number_o       in varchar2
  );
--
end pqp_aat_rkd;

/
