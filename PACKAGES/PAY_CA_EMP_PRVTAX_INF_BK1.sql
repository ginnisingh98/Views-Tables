--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_PRVTAX_INF_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_PRVTAX_INF_BK1" AUTHID CURRENT_USER as
/* $Header: pycprapi.pkh 120.3.12000000.1 2007/01/17 18:12:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ca_emp_prvtax_inf_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_emp_prvtax_inf_b
  (
   p_legislation_code               in  varchar2
  ,p_assignment_id                  in  number
  ,p_business_group_id              in  number
  ,p_province_code                  in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_tax_credit_amount              in  number
  ,p_basic_exemption_flag           in  varchar2
  ,p_deduction_code                 in  varchar2
  ,p_extra_info_not_provided        in  varchar2
  ,p_marriage_status                in  varchar2
  ,p_no_of_infirm_dependants        in  number
  ,p_non_resident_status            in  varchar2
  ,p_disability_status              in  varchar2
  ,p_no_of_dependants               in  number
  ,p_annual_dedn                    in  number
  ,p_total_expense_by_commission    in  number
  ,p_total_remnrtn_by_commission    in  number
  ,p_prescribed_zone_dedn_amt       in  number
  ,p_additional_tax                 in  number
  ,p_prov_override_rate             in  number
  ,p_prov_override_amount           in  number
  ,p_prov_exempt_flag               in  varchar2
  ,p_pmed_exempt_flag               in  varchar2
  ,p_wc_exempt_flag                 in  varchar2
  ,p_qpp_exempt_flag                in  varchar2
  ,p_tax_calc_method                in  varchar2
  ,p_other_tax_credit               in  number
  ,p_ca_tax_information_category    in  varchar2
  ,p_ca_tax_information1            in  varchar2
  ,p_ca_tax_information2            in  varchar2
  ,p_ca_tax_information3            in  varchar2
  ,p_ca_tax_information4            in  varchar2
  ,p_ca_tax_information5            in  varchar2
  ,p_ca_tax_information6            in  varchar2
  ,p_ca_tax_information7            in  varchar2
  ,p_ca_tax_information8            in  varchar2
  ,p_ca_tax_information9            in  varchar2
  ,p_ca_tax_information10           in  varchar2
  ,p_ca_tax_information11           in  varchar2
  ,p_ca_tax_information12           in  varchar2
  ,p_ca_tax_information13           in  varchar2
  ,p_ca_tax_information14           in  varchar2
  ,p_ca_tax_information15           in  varchar2
  ,p_ca_tax_information16           in  varchar2
  ,p_ca_tax_information17           in  varchar2
  ,p_ca_tax_information18           in  varchar2
  ,p_ca_tax_information19           in  varchar2
  ,p_ca_tax_information20           in  varchar2
  ,p_ca_tax_information21           in  varchar2
  ,p_ca_tax_information22           in  varchar2
  ,p_ca_tax_information23           in  varchar2
  ,p_ca_tax_information24           in  varchar2
  ,p_ca_tax_information25           in  varchar2
  ,p_ca_tax_information26           in  varchar2
  ,p_ca_tax_information27           in  varchar2
  ,p_ca_tax_information28           in  varchar2
  ,p_ca_tax_information29           in  varchar2
  ,p_ca_tax_information30           in  varchar2
  ,p_prov_lsp_amount                in  number
  ,p_effective_date                 in  date
  ,p_ppip_exempt_flag               in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ca_emp_prvtax_inf_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_ca_emp_prvtax_inf_a
  (
   p_emp_province_tax_inf_id        in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_legislation_code               in  varchar2
  ,p_assignment_id                  in  number
  ,p_business_group_id              in  number
  ,p_province_code                  in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_tax_credit_amount              in  number
  ,p_basic_exemption_flag           in  varchar2
  ,p_deduction_code                 in  varchar2
  ,p_extra_info_not_provided        in  varchar2
  ,p_marriage_status                in  varchar2
  ,p_no_of_infirm_dependants        in  number
  ,p_non_resident_status            in  varchar2
  ,p_disability_status              in  varchar2
  ,p_no_of_dependants               in  number
  ,p_annual_dedn                    in  number
  ,p_total_expense_by_commission    in  number
  ,p_total_remnrtn_by_commission    in  number
  ,p_prescribed_zone_dedn_amt       in  number
  ,p_additional_tax                 in  number
  ,p_prov_override_rate             in  number
  ,p_prov_override_amount           in  number
  ,p_prov_exempt_flag               in  varchar2
  ,p_pmed_exempt_flag               in  varchar2
  ,p_wc_exempt_flag                 in  varchar2
  ,p_qpp_exempt_flag                in  varchar2
  ,p_tax_calc_method                in  varchar2
  ,p_other_tax_credit               in  number
  ,p_ca_tax_information_category    in  varchar2
  ,p_ca_tax_information1            in  varchar2
  ,p_ca_tax_information2            in  varchar2
  ,p_ca_tax_information3            in  varchar2
  ,p_ca_tax_information4            in  varchar2
  ,p_ca_tax_information5            in  varchar2
  ,p_ca_tax_information6            in  varchar2
  ,p_ca_tax_information7            in  varchar2
  ,p_ca_tax_information8            in  varchar2
  ,p_ca_tax_information9            in  varchar2
  ,p_ca_tax_information10           in  varchar2
  ,p_ca_tax_information11           in  varchar2
  ,p_ca_tax_information12           in  varchar2
  ,p_ca_tax_information13           in  varchar2
  ,p_ca_tax_information14           in  varchar2
  ,p_ca_tax_information15           in  varchar2
  ,p_ca_tax_information16           in  varchar2
  ,p_ca_tax_information17           in  varchar2
  ,p_ca_tax_information18           in  varchar2
  ,p_ca_tax_information19           in  varchar2
  ,p_ca_tax_information20           in  varchar2
  ,p_ca_tax_information21           in  varchar2
  ,p_ca_tax_information22           in  varchar2
  ,p_ca_tax_information23           in  varchar2
  ,p_ca_tax_information24           in  varchar2
  ,p_ca_tax_information25           in  varchar2
  ,p_ca_tax_information26           in  varchar2
  ,p_ca_tax_information27           in  varchar2
  ,p_ca_tax_information28           in  varchar2
  ,p_ca_tax_information29           in  varchar2
  ,p_ca_tax_information30           in  varchar2
  ,p_object_version_number          in  number
  ,p_prov_lsp_amount                in  number
  ,p_effective_date                 in  date
  ,p_ppip_exempt_flag               in  varchar2
  );
--
end pay_ca_emp_prvtax_inf_bk1;

 

/
