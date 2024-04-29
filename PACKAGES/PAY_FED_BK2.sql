--------------------------------------------------------
--  DDL for Package PAY_FED_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FED_BK2" AUTHID CURRENT_USER as
/* $Header: pyfedapi.pkh 120.3 2007/07/16 02:07:21 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_federal_tax_rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_federal_tax_rule_b
  (
   p_emp_fed_tax_rule_id            in  number
  ,p_assignment_id                  in  number
  ,p_sui_state_code                 in  varchar2
  ,p_sui_jurisdiction_code          in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_amount           in  number
  ,p_filing_status_code             in  varchar2
  ,p_fit_override_amount            in  number
  ,p_fit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_cumulative_taxation            in  varchar2
  ,p_eic_filing_status_code         in  varchar2
  ,p_fit_additional_tax             in  number
  ,p_fit_exempt                     in  varchar2
  ,p_futa_tax_exempt                in  varchar2
  ,p_medicare_tax_exempt            in  varchar2
  ,p_ss_tax_exempt                  in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_statutory_employee             in  varchar2
  ,p_w2_filed_year                  in  number
  ,p_supp_tax_override_rate         in  number
  ,p_excessive_wa_reject_date       in  date
  ,p_object_version_number          in  number
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_fed_information_category       in  varchar2
  ,p_fed_information1               in  varchar2
  ,p_fed_information2               in  varchar2
  ,p_fed_information3               in  varchar2
  ,p_fed_information4               in  varchar2
  ,p_fed_information5               in  varchar2
  ,p_fed_information6               in  varchar2
  ,p_fed_information7               in  varchar2
  ,p_fed_information8               in  varchar2
  ,p_fed_information9               in  varchar2
  ,p_fed_information10              in  varchar2
  ,p_fed_information11              in  varchar2
  ,p_fed_information12              in  varchar2
  ,p_fed_information13              in  varchar2
  ,p_fed_information14              in  varchar2
  ,p_fed_information15              in  varchar2
  ,p_fed_information16              in  varchar2
  ,p_fed_information17              in  varchar2
  ,p_fed_information18              in  varchar2
  ,p_fed_information19              in  varchar2
  ,p_fed_information20              in  varchar2
  ,p_fed_information21              in  varchar2
  ,p_fed_information22              in  varchar2
  ,p_fed_information23              in  varchar2
  ,p_fed_information24              in  varchar2
  ,p_fed_information25              in  varchar2
  ,p_fed_information26              in  varchar2
  ,p_fed_information27              in  varchar2
  ,p_fed_information28              in  varchar2
  ,p_fed_information29              in  varchar2
  ,p_fed_information30              in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_federal_tax_rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_federal_tax_rule_a
  (
   p_emp_fed_tax_rule_id            in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_assignment_id                  in  number
  ,p_sui_state_code                 in  varchar2
  ,p_sui_jurisdiction_code          in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_amount           in  number
  ,p_filing_status_code             in  varchar2
  ,p_fit_override_amount            in  number
  ,p_fit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_cumulative_taxation            in  varchar2
  ,p_eic_filing_status_code         in  varchar2
  ,p_fit_additional_tax             in  number
  ,p_fit_exempt                     in  varchar2
  ,p_futa_tax_exempt                in  varchar2
  ,p_medicare_tax_exempt            in  varchar2
  ,p_ss_tax_exempt                  in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_statutory_employee             in  varchar2
  ,p_w2_filed_year                  in  number
  ,p_supp_tax_override_rate         in  number
  ,p_excessive_wa_reject_date       in  date
  ,p_object_version_number          in  number
  ,p_attribute_category             in  varchar2
  ,p_attribute1                     in  varchar2
  ,p_attribute2                     in  varchar2
  ,p_attribute3                     in  varchar2
  ,p_attribute4                     in  varchar2
  ,p_attribute5                     in  varchar2
  ,p_attribute6                     in  varchar2
  ,p_attribute7                     in  varchar2
  ,p_attribute8                     in  varchar2
  ,p_attribute9                     in  varchar2
  ,p_attribute10                    in  varchar2
  ,p_attribute11                    in  varchar2
  ,p_attribute12                    in  varchar2
  ,p_attribute13                    in  varchar2
  ,p_attribute14                    in  varchar2
  ,p_attribute15                    in  varchar2
  ,p_attribute16                    in  varchar2
  ,p_attribute17                    in  varchar2
  ,p_attribute18                    in  varchar2
  ,p_attribute19                    in  varchar2
  ,p_attribute20                    in  varchar2
  ,p_attribute21                    in  varchar2
  ,p_attribute22                    in  varchar2
  ,p_attribute23                    in  varchar2
  ,p_attribute24                    in  varchar2
  ,p_attribute25                    in  varchar2
  ,p_attribute26                    in  varchar2
  ,p_attribute27                    in  varchar2
  ,p_attribute28                    in  varchar2
  ,p_attribute29                    in  varchar2
  ,p_attribute30                    in  varchar2
  ,p_fed_information_category       in  varchar2
  ,p_fed_information1               in  varchar2
  ,p_fed_information2               in  varchar2
  ,p_fed_information3               in  varchar2
  ,p_fed_information4               in  varchar2
  ,p_fed_information5               in  varchar2
  ,p_fed_information6               in  varchar2
  ,p_fed_information7               in  varchar2
  ,p_fed_information8               in  varchar2
  ,p_fed_information9               in  varchar2
  ,p_fed_information10              in  varchar2
  ,p_fed_information11              in  varchar2
  ,p_fed_information12              in  varchar2
  ,p_fed_information13              in  varchar2
  ,p_fed_information14              in  varchar2
  ,p_fed_information15              in  varchar2
  ,p_fed_information16              in  varchar2
  ,p_fed_information17              in  varchar2
  ,p_fed_information18              in  varchar2
  ,p_fed_information19              in  varchar2
  ,p_fed_information20              in  varchar2
  ,p_fed_information21              in  varchar2
  ,p_fed_information22              in  varchar2
  ,p_fed_information23              in  varchar2
  ,p_fed_information24              in  varchar2
  ,p_fed_information25              in  varchar2
  ,p_fed_information26              in  varchar2
  ,p_fed_information27              in  varchar2
  ,p_fed_information28              in  varchar2
  ,p_fed_information29              in  varchar2
  ,p_fed_information30              in  varchar2
  );
--
end pay_fed_bk2;

/
