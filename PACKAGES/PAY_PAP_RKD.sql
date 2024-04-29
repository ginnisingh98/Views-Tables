--------------------------------------------------------
--  DDL for Package PAY_PAP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAP_RKD" AUTHID CURRENT_USER as
/* $Header: pypaprhi.pkh 120.0 2005/05/29 07:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_accrual_plan_id                in number
 ,p_business_group_id_o            in number
 ,p_accrual_plan_element_type__o in number
 ,p_pto_input_value_id_o           in number
 ,p_co_input_value_id_o            in number
 ,p_residual_input_value_id_o      in number
 ,p_accrual_category_o             in varchar2
 ,p_accrual_plan_name_o            in varchar2
 ,p_accrual_start_o                in varchar2
 ,p_accrual_units_of_measure_o     in varchar2
 ,p_ineligible_period_length_o     in number
 ,p_ineligible_period_type_o       in varchar2
 ,p_accrual_formula_id_o           in number
 ,p_co_formula_id_o                in number
 ,p_co_date_input_value_id_o       in number
 ,p_co_exp_date_input_value_id_o   in number
 ,p_residual_date_input_value__o in number
 ,p_description_o                  in varchar2
 ,p_ineligibility_formula_id_o     in number
 ,p_payroll_formula_id_o           in number
 ,p_defined_balance_id_o           in number
 ,p_tagging_element_type_id_o      in number
 ,p_balance_element_type_id_o      in number
 ,p_object_version_number_o        in number
 ,p_information_category_o         in varchar2
 ,p_information1_o                 in varchar2
 ,p_information2_o                 in varchar2
 ,p_information3_o                 in varchar2
 ,p_information4_o                 in varchar2
 ,p_information5_o                 in varchar2
 ,p_information6_o                 in varchar2
 ,p_information7_o                 in varchar2
 ,p_information8_o                 in varchar2
 ,p_information9_o                 in varchar2
 ,p_information10_o                in varchar2
 ,p_information11_o                in varchar2
 ,p_information12_o                in varchar2
 ,p_information13_o                in varchar2
 ,p_information14_o                in varchar2
 ,p_information15_o                in varchar2
 ,p_information16_o                in varchar2
 ,p_information17_o                in varchar2
 ,p_information18_o                in varchar2
 ,p_information19_o                in varchar2
 ,p_information20_o                in varchar2
 ,p_information21_o                in varchar2
 ,p_information22_o                in varchar2
 ,p_information23_o                in varchar2
 ,p_information24_o                in varchar2
 ,p_information25_o                in varchar2
 ,p_information26_o                in varchar2
 ,p_information27_o                in varchar2
 ,p_information28_o                in varchar2
 ,p_information29_o                in varchar2
 ,p_information30_o                in varchar2

  );
--
end pay_pap_rkd;

 

/
