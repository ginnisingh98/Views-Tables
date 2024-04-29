--------------------------------------------------------
--  DDL for Package PAY_STA_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STA_BK1" AUTHID CURRENT_USER as
/* $Header: pystaapi.pkh 120.2.12010000.1 2008/07/27 23:43:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_state_tax_rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_state_tax_rule_b
  (
   p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_amount           in  number
  ,p_filing_status_code             in  varchar2
  ,p_remainder_percent              in  number
  ,p_secondary_wa                   in  number
  ,p_sit_additional_tax             in  number
  ,p_sit_override_amount            in  number
  ,p_sit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_excessive_wa_reject_date       in  date
  ,p_sdi_exempt                     in  varchar2
  ,p_sit_exempt                     in  varchar2
  ,p_sit_optional_calc_ind          in  varchar2
  ,p_state_non_resident_cert        in  varchar2
  ,p_sui_exempt                     in  varchar2
  ,p_wc_exempt                      in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_sui_wage_base_override_amoun   in  number
  ,p_supp_tax_override_rate         in  number
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
  ,p_sta_information_category       in  varchar2
  ,p_sta_information1               in  varchar2
  ,p_sta_information2               in  varchar2
  ,p_sta_information3               in  varchar2
  ,p_sta_information4               in  varchar2
  ,p_sta_information5               in  varchar2
  ,p_sta_information6               in  varchar2
  ,p_sta_information7               in  varchar2
  ,p_sta_information8               in  varchar2
  ,p_sta_information9               in  varchar2
  ,p_sta_information10              in  varchar2
  ,p_sta_information11              in  varchar2
  ,p_sta_information12              in  varchar2
  ,p_sta_information13              in  varchar2
  ,p_sta_information14              in  varchar2
  ,p_sta_information15              in  varchar2
  ,p_sta_information16              in  varchar2
  ,p_sta_information17              in  varchar2
  ,p_sta_information18              in  varchar2
  ,p_sta_information19              in  varchar2
  ,p_sta_information20              in  varchar2
  ,p_sta_information21              in  varchar2
  ,p_sta_information22              in  varchar2
  ,p_sta_information23              in  varchar2
  ,p_sta_information24              in  varchar2
  ,p_sta_information25              in  varchar2
  ,p_sta_information26              in  varchar2
  ,p_sta_information27              in  varchar2
  ,p_sta_information28              in  varchar2
  ,p_sta_information29              in  varchar2
  ,p_sta_information30              in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_state_tax_rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_state_tax_rule_a
  (
   p_emp_state_tax_rule_id          in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_amount           in  number
  ,p_filing_status_code             in  varchar2
  ,p_remainder_percent              in  number
  ,p_secondary_wa                   in  number
  ,p_sit_additional_tax             in  number
  ,p_sit_override_amount            in  number
  ,p_sit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_excessive_wa_reject_date       in  date
  ,p_sdi_exempt                     in  varchar2
  ,p_sit_exempt                     in  varchar2
  ,p_sit_optional_calc_ind          in  varchar2
  ,p_state_non_resident_cert        in  varchar2
  ,p_sui_exempt                     in  varchar2
  ,p_wc_exempt                      in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_sui_wage_base_override_amoun   in  number
  ,p_supp_tax_override_rate         in  number
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
  ,p_sta_information_category       in  varchar2
  ,p_sta_information1               in  varchar2
  ,p_sta_information2               in  varchar2
  ,p_sta_information3               in  varchar2
  ,p_sta_information4               in  varchar2
  ,p_sta_information5               in  varchar2
  ,p_sta_information6               in  varchar2
  ,p_sta_information7               in  varchar2
  ,p_sta_information8               in  varchar2
  ,p_sta_information9               in  varchar2
  ,p_sta_information10              in  varchar2
  ,p_sta_information11              in  varchar2
  ,p_sta_information12              in  varchar2
  ,p_sta_information13              in  varchar2
  ,p_sta_information14              in  varchar2
  ,p_sta_information15              in  varchar2
  ,p_sta_information16              in  varchar2
  ,p_sta_information17              in  varchar2
  ,p_sta_information18              in  varchar2
  ,p_sta_information19              in  varchar2
  ,p_sta_information20              in  varchar2
  ,p_sta_information21              in  varchar2
  ,p_sta_information22              in  varchar2
  ,p_sta_information23              in  varchar2
  ,p_sta_information24              in  varchar2
  ,p_sta_information25              in  varchar2
  ,p_sta_information26              in  varchar2
  ,p_sta_information27              in  varchar2
  ,p_sta_information28              in  varchar2
  ,p_sta_information29              in  varchar2
  ,p_sta_information30              in  varchar2
  );
--
end pay_sta_bk1;

/
