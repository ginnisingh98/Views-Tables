--------------------------------------------------------
--  DDL for Package PAY_ETP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ETP_RKD" AUTHID CURRENT_USER as
/* $Header: pyetprhi.pkh 120.2.12010000.2 2008/08/06 07:14:25 ubhat ship $ */
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
  ,p_element_type_id              in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_formula_id_o                 in number
  ,p_input_currency_code_o        in varchar2
  ,p_output_currency_code_o       in varchar2
  ,p_classification_id_o          in number
  ,p_benefit_classification_id_o  in number
  ,p_additional_entry_allowed_f_o in varchar2
  ,p_adjustment_only_flag_o       in varchar2
  ,p_closed_for_entry_flag_o      in varchar2
  ,p_element_name_o               in varchar2
  ,p_indirect_only_flag_o         in varchar2
  ,p_multiple_entries_allowed_f_o in varchar2
  ,p_multiply_value_flag_o        in varchar2
  ,p_post_termination_rule_o      in varchar2
  ,p_process_in_run_flag_o        in varchar2
  ,p_processing_priority_o        in number
  ,p_processing_type_o            in varchar2
  ,p_standard_link_flag_o         in varchar2
  ,p_comment_id_o                 in number
  ,p_comments_o                   in varchar2
  ,p_description_o                in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_qualifying_age_o             in number
  ,p_qualifying_length_of_servi_o in number
  ,p_qualifying_units_o           in varchar2
  ,p_reporting_name_o             in varchar2
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_element_information_catego_o in varchar2
  ,p_element_information1_o       in varchar2
  ,p_element_information2_o       in varchar2
  ,p_element_information3_o       in varchar2
  ,p_element_information4_o       in varchar2
  ,p_element_information5_o       in varchar2
  ,p_element_information6_o       in varchar2
  ,p_element_information7_o       in varchar2
  ,p_element_information8_o       in varchar2
  ,p_element_information9_o       in varchar2
  ,p_element_information10_o      in varchar2
  ,p_element_information11_o      in varchar2
  ,p_element_information12_o      in varchar2
  ,p_element_information13_o      in varchar2
  ,p_element_information14_o      in varchar2
  ,p_element_information15_o      in varchar2
  ,p_element_information16_o      in varchar2
  ,p_element_information17_o      in varchar2
  ,p_element_information18_o      in varchar2
  ,p_element_information19_o      in varchar2
  ,p_element_information20_o      in varchar2
  ,p_third_party_pay_only_flag_o  in varchar2
  ,p_object_version_number_o      in number
  ,p_iterative_flag_o             in varchar2
  ,p_iterative_formula_id_o       in number
  ,p_iterative_priority_o         in number
  ,p_creator_type_o               in varchar2
  ,p_retro_summ_ele_id_o          in number
  ,p_grossup_flag_o               in varchar2
  ,p_process_mode_o               in varchar2
  ,p_advance_indicator_o          in varchar2
  ,p_advance_payable_o            in varchar2
  ,p_advance_deduction_o          in varchar2
  ,p_process_advance_entry_o      in varchar2
  ,p_proration_group_id_o         in number
  ,p_proration_formula_id_o       in number
  ,p_recalc_event_group_id_o      in number
  ,p_once_each_period_flag_o      in varchar2
  ,p_time_definition_type_o	  in varchar2
  ,p_time_definition_id_o	  in number
  ,p_advance_element_type_id_o	  in number
  ,p_deduction_element_type_id_o  in number
  );
--
end pay_etp_rkd;

/
