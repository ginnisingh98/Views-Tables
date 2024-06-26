--------------------------------------------------------
--  DDL for Package PAY_FED_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FED_RKD" AUTHID CURRENT_USER as
/* $Header: pyfedrhi.pkh 120.0.12000000.2 2007/05/01 22:39:23 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_emp_fed_tax_rule_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_effective_date                 in date
 ,p_object_version_number          in number
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_assignment_id_o                in number
 ,p_sui_state_code_o               in varchar2
 ,p_sui_jurisdiction_code_o        in varchar2
 ,p_business_group_id_o            in number
 ,p_additional_wa_amount_o         in number
 ,p_filing_status_code_o           in varchar2
 ,p_fit_override_amount_o          in number
 ,p_fit_override_rate_o            in number
 ,p_withholding_allowances_o       in number
 ,p_cumulative_taxation_o          in varchar2
 ,p_eic_filing_status_code_o       in varchar2
 ,p_fit_additional_tax_o           in number
 ,p_fit_exempt_o                   in varchar2
 ,p_futa_tax_exempt_o              in varchar2
 ,p_medicare_tax_exempt_o          in varchar2
 ,p_ss_tax_exempt_o                in varchar2
 ,p_wage_exempt_o                  in varchar2
 ,p_statutory_employee_o           in varchar2
 ,p_w2_filed_year_o                in number
 ,p_supp_tax_override_rate_o       in number
 ,p_excessive_wa_reject_date_o     in date
 ,p_object_version_number_o        in number
 ,p_attribute_category               in varchar2
 ,p_attribute1                       in varchar2
 ,p_attribute2                       in varchar2
 ,p_attribute3                       in varchar2
 ,p_attribute4                       in varchar2
 ,p_attribute5                       in varchar2
 ,p_attribute6                       in varchar2
 ,p_attribute7                       in varchar2
 ,p_attribute8                       in varchar2
 ,p_attribute9                       in varchar2
 ,p_attribute10                      in varchar2
 ,p_attribute11                      in varchar2
 ,p_attribute12                      in varchar2
 ,p_attribute13                      in varchar2
 ,p_attribute14                      in varchar2
 ,p_attribute15                      in varchar2
 ,p_attribute16                      in varchar2
 ,p_attribute17                      in varchar2
 ,p_attribute18                      in varchar2
 ,p_attribute19                      in varchar2
 ,p_attribute20                      in varchar2
 ,p_attribute21                      in varchar2
 ,p_attribute22                      in varchar2
 ,p_attribute23                      in varchar2
 ,p_attribute24                      in varchar2
 ,p_attribute25                      in varchar2
 ,p_attribute26                      in varchar2
 ,p_attribute27                      in varchar2
 ,p_attribute28                      in varchar2
 ,p_attribute29                      in varchar2
 ,p_attribute30                      in varchar2
 ,p_fed_information_category         in varchar2
 ,p_fed_information1                 in varchar2
 ,p_fed_information2                 in varchar2
 ,p_fed_information3                 in varchar2
 ,p_fed_information4                 in varchar2
 ,p_fed_information5                 in varchar2
 ,p_fed_information6                 in varchar2
 ,p_fed_information7                 in varchar2
 ,p_fed_information8                 in varchar2
 ,p_fed_information9                 in varchar2
 ,p_fed_information10                in varchar2
 ,p_fed_information11                in varchar2
 ,p_fed_information12                in varchar2
 ,p_fed_information13                in varchar2
 ,p_fed_information14                in varchar2
 ,p_fed_information15                in varchar2
 ,p_fed_information16                in varchar2
 ,p_fed_information17                in varchar2
 ,p_fed_information18                in varchar2
 ,p_fed_information19                in varchar2
 ,p_fed_information20                in varchar2
 ,p_fed_information21                in varchar2
 ,p_fed_information22                in varchar2
 ,p_fed_information23                in varchar2
 ,p_fed_information24                in varchar2
 ,p_fed_information25                in varchar2
 ,p_fed_information26                in varchar2
 ,p_fed_information27                in varchar2
 ,p_fed_information28                in varchar2
 ,p_fed_information29                in varchar2
 ,p_fed_information30                in varchar2
  );
--
end pay_fed_rkd;

 

/
