--------------------------------------------------------
--  DDL for Package PAY_CFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CFT_RKI" AUTHID CURRENT_USER as
/* $Header: pycatrhi.pkh 120.1 2005/10/05 06:45:04 saurgupt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_emp_fed_tax_inf_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_legislation_code               in varchar2
 ,p_assignment_id                  in number
 ,p_business_group_id              in number
 ,p_employment_province            in varchar2
 ,p_tax_credit_amount              in number
 ,p_claim_code                     in varchar2
 ,p_basic_exemption_flag           in varchar2
 ,p_additional_tax                 in number
 ,p_annual_dedn                    in number
 ,p_total_expense_by_commission    in number
 ,p_total_remnrtn_by_commission    in number
 ,p_prescribed_zone_dedn_amt       in number
 ,p_other_fedtax_credits           in varchar2
 ,p_cpp_qpp_exempt_flag            in varchar2
 ,p_fed_exempt_flag                in varchar2
 ,p_ei_exempt_flag                 in varchar2
 ,p_tax_calc_method                in varchar2
 ,p_fed_override_amount            in number
 ,p_fed_override_rate              in number
 ,p_ca_tax_information_category    in varchar2
 ,p_ca_tax_information1            in varchar2
 ,p_ca_tax_information2            in varchar2
 ,p_ca_tax_information3            in varchar2
 ,p_ca_tax_information4            in varchar2
 ,p_ca_tax_information5            in varchar2
 ,p_ca_tax_information6            in varchar2
 ,p_ca_tax_information7            in varchar2
 ,p_ca_tax_information8            in varchar2
 ,p_ca_tax_information9            in varchar2
 ,p_ca_tax_information10           in varchar2
 ,p_ca_tax_information11           in varchar2
 ,p_ca_tax_information12           in varchar2
 ,p_ca_tax_information13           in varchar2
 ,p_ca_tax_information14           in varchar2
 ,p_ca_tax_information15           in varchar2
 ,p_ca_tax_information16           in varchar2
 ,p_ca_tax_information17           in varchar2
 ,p_ca_tax_information18           in varchar2
 ,p_ca_tax_information19           in varchar2
 ,p_ca_tax_information20           in varchar2
 ,p_ca_tax_information21           in varchar2
 ,p_ca_tax_information22           in varchar2
 ,p_ca_tax_information23           in varchar2
 ,p_ca_tax_information24           in varchar2
 ,p_ca_tax_information25           in varchar2
 ,p_ca_tax_information26           in varchar2
 ,p_ca_tax_information27           in varchar2
 ,p_ca_tax_information28           in varchar2
 ,p_ca_tax_information29           in varchar2
 ,p_ca_tax_information30           in varchar2
 ,p_object_version_number          in number
 ,p_fed_lsf_amount	           in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end pay_cft_rki;

 

/
