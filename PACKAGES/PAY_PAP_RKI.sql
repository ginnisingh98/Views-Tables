--------------------------------------------------------
--  DDL for Package PAY_PAP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAP_RKI" AUTHID CURRENT_USER as
/* $Header: pypaprhi.pkh 120.0 2005/05/29 07:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_accrual_plan_id                in number
 ,p_business_group_id              in number
 ,p_accrual_plan_element_type_id   in number
 ,p_pto_input_value_id             in number
 ,p_co_input_value_id              in number
 ,p_residual_input_value_id        in number
 ,p_accrual_category               in varchar2
 ,p_accrual_plan_name              in varchar2
 ,p_accrual_start                  in varchar2
 ,p_accrual_units_of_measure       in varchar2
 ,p_ineligible_period_length       in number
 ,p_ineligible_period_type         in varchar2
 ,p_accrual_formula_id             in number
 ,p_co_formula_id                  in number
 ,p_co_date_input_value_id         in number
 ,p_co_exp_date_input_value_id     in number
 ,p_residual_date_input_value_id   in number
 ,p_description                    in varchar2
 ,p_ineligibility_formula_id       in number
 ,p_payroll_formula_id             in number
 ,p_defined_balance_id             in number
 ,p_tagging_element_type_id        in number
 ,p_balance_element_type_id        in number
 ,p_object_version_number          in number
 ,p_information_category             in varchar2
 ,p_information1                     in varchar2
 ,p_information2                     in varchar2
 ,p_information3                     in varchar2
 ,p_information4                     in varchar2
 ,p_information5                     in varchar2
 ,p_information6                     in varchar2
 ,p_information7                     in varchar2
 ,p_information8                     in varchar2
 ,p_information9                     in varchar2
 ,p_information10                    in varchar2
 ,p_information11                    in varchar2
 ,p_information12                    in varchar2
 ,p_information13                    in varchar2
 ,p_information14                    in varchar2
 ,p_information15                    in varchar2
 ,p_information16                    in varchar2
 ,p_information17                    in varchar2
 ,p_information18                    in varchar2
 ,p_information19                    in varchar2
 ,p_information20                    in varchar2
 ,p_information21                    in varchar2
 ,p_information22                    in varchar2
 ,p_information23                    in varchar2
 ,p_information24                    in varchar2
 ,p_information25                    in varchar2
 ,p_information26                    in varchar2
 ,p_information27                    in varchar2
 ,p_information28                    in varchar2
 ,p_information29                    in varchar2
 ,p_information30                    in varchar2
  );
end pay_pap_rki;

 

/
