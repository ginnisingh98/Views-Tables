--------------------------------------------------------
--  DDL for Package PAY_CPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CPT_RKD" AUTHID CURRENT_USER as
/* $Header: pycprrhi.pkh 120.1.12010000.1 2008/07/27 22:24:00 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_emp_province_tax_inf_id        in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_legislation_code_o             in varchar2
 ,p_assignment_id_o                in number
 ,p_business_group_id_o            in number
 ,p_province_code_o                in varchar2
 ,p_jurisdiction_code_o            in varchar2
 ,p_tax_credit_amount_o            in number
 ,p_basic_exemption_flag_o         in varchar2
 ,p_deduction_code_o               in varchar2
 ,p_extra_info_not_provided_o              in varchar2
 ,p_marriage_status_o              in varchar2
 ,p_no_of_infirm_dependants_o      in number
 ,p_non_resident_status_o          in varchar2
 ,p_disability_status_o            in varchar2
 ,p_no_of_dependants_o             in number
 ,p_annual_dedn_o                  in number
 ,p_total_expense_by_commissio_o  in number
 ,p_total_remnrtn_by_commissio_o  in number
 ,p_prescribed_zone_dedn_amt_o     in number
 ,p_additional_tax_o               in number
 ,p_prov_override_rate_o           in number
 ,p_prov_override_amount_o         in number
 ,p_prov_exempt_flag_o             in varchar2
 ,p_pmed_exempt_flag_o             in varchar2
 ,p_wc_exempt_flag_o               in varchar2
 ,p_qpp_exempt_flag_o              in varchar2
 ,p_tax_calc_method_o              in varchar2
 ,p_other_tax_credit_o             in number
 ,p_ca_tax_information_categor_o  in varchar2
 ,p_ca_tax_information1_o          in varchar2
 ,p_ca_tax_information2_o          in varchar2
 ,p_ca_tax_information3_o          in varchar2
 ,p_ca_tax_information4_o          in varchar2
 ,p_ca_tax_information5_o          in varchar2
 ,p_ca_tax_information6_o          in varchar2
 ,p_ca_tax_information7_o          in varchar2
 ,p_ca_tax_information8_o          in varchar2
 ,p_ca_tax_information9_o          in varchar2
 ,p_ca_tax_information10_o         in varchar2
 ,p_ca_tax_information11_o         in varchar2
 ,p_ca_tax_information12_o         in varchar2
 ,p_ca_tax_information13_o         in varchar2
 ,p_ca_tax_information14_o         in varchar2
 ,p_ca_tax_information15_o         in varchar2
 ,p_ca_tax_information16_o         in varchar2
 ,p_ca_tax_information17_o         in varchar2
 ,p_ca_tax_information18_o         in varchar2
 ,p_ca_tax_information19_o         in varchar2
 ,p_ca_tax_information20_o         in varchar2
 ,p_ca_tax_information21_o         in varchar2
 ,p_ca_tax_information22_o         in varchar2
 ,p_ca_tax_information23_o         in varchar2
 ,p_ca_tax_information24_o         in varchar2
 ,p_ca_tax_information25_o         in varchar2
 ,p_ca_tax_information26_o         in varchar2
 ,p_ca_tax_information27_o         in varchar2
 ,p_ca_tax_information28_o         in varchar2
 ,p_ca_tax_information29_o         in varchar2
 ,p_ca_tax_information30_o         in varchar2
 ,p_object_version_number_o        in number
 ,p_prov_lsp_amount_o              in number
 ,p_ppip_exempt_flag_o              in varchar2
  );
--
end pay_cpt_rkd;

/
