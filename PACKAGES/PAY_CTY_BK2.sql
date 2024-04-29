--------------------------------------------------------
--  DDL for Package PAY_CTY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CTY_BK2" AUTHID CURRENT_USER as
/* $Header: pyctyapi.pkh 120.2 2007/05/01 22:38:19 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_city_tax_rule_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_city_tax_rule_b
  (
   p_emp_city_tax_rule_id           in  number
  ,p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_county_code                    in  varchar2
  ,p_city_code                      in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_rate             in  number
  ,p_filing_status_code             in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_lit_additional_tax             in  number
  ,p_lit_override_amount            in  number
  ,p_lit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_lit_exempt                     in  varchar2
  ,p_sd_exempt                      in  varchar2
  ,p_ht_exempt                      in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_school_district_code           in  varchar2
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
  ,p_cty_information_category       in  varchar2
  ,p_cty_information1               in  varchar2
  ,p_cty_information2               in  varchar2
  ,p_cty_information3               in  varchar2
  ,p_cty_information4               in  varchar2
  ,p_cty_information5               in  varchar2
  ,p_cty_information6               in  varchar2
  ,p_cty_information7               in  varchar2
  ,p_cty_information8               in  varchar2
  ,p_cty_information9               in  varchar2
  ,p_cty_information10              in  varchar2
  ,p_cty_information11              in  varchar2
  ,p_cty_information12              in  varchar2
  ,p_cty_information13              in  varchar2
  ,p_cty_information14              in  varchar2
  ,p_cty_information15              in  varchar2
  ,p_cty_information16              in  varchar2
  ,p_cty_information17              in  varchar2
  ,p_cty_information18              in  varchar2
  ,p_cty_information19              in  varchar2
  ,p_cty_information20              in  varchar2
  ,p_cty_information21              in  varchar2
  ,p_cty_information22              in  varchar2
  ,p_cty_information23              in  varchar2
  ,p_cty_information24              in  varchar2
  ,p_cty_information25              in  varchar2
  ,p_cty_information26              in  varchar2
  ,p_cty_information27              in  varchar2
  ,p_cty_information28              in  varchar2
  ,p_cty_information29              in  varchar2
  ,p_cty_information30              in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_city_tax_rule_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_city_tax_rule_a
  (
   p_emp_city_tax_rule_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_assignment_id                  in  number
  ,p_state_code                     in  varchar2
  ,p_county_code                    in  varchar2
  ,p_city_code                      in  varchar2
  ,p_business_group_id              in  number
  ,p_additional_wa_rate             in  number
  ,p_filing_status_code             in  varchar2
  ,p_jurisdiction_code              in  varchar2
  ,p_lit_additional_tax             in  number
  ,p_lit_override_amount            in  number
  ,p_lit_override_rate              in  number
  ,p_withholding_allowances         in  number
  ,p_lit_exempt                     in  varchar2
  ,p_sd_exempt                      in  varchar2
  ,p_ht_exempt                      in  varchar2
  ,p_wage_exempt                    in  varchar2
  ,p_school_district_code           in  varchar2
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
  ,p_cty_information_category       in  varchar2
  ,p_cty_information1               in  varchar2
  ,p_cty_information2               in  varchar2
  ,p_cty_information3               in  varchar2
  ,p_cty_information4               in  varchar2
  ,p_cty_information5               in  varchar2
  ,p_cty_information6               in  varchar2
  ,p_cty_information7               in  varchar2
  ,p_cty_information8               in  varchar2
  ,p_cty_information9               in  varchar2
  ,p_cty_information10              in  varchar2
  ,p_cty_information11              in  varchar2
  ,p_cty_information12              in  varchar2
  ,p_cty_information13              in  varchar2
  ,p_cty_information14              in  varchar2
  ,p_cty_information15              in  varchar2
  ,p_cty_information16              in  varchar2
  ,p_cty_information17              in  varchar2
  ,p_cty_information18              in  varchar2
  ,p_cty_information19              in  varchar2
  ,p_cty_information20              in  varchar2
  ,p_cty_information21              in  varchar2
  ,p_cty_information22              in  varchar2
  ,p_cty_information23              in  varchar2
  ,p_cty_information24              in  varchar2
  ,p_cty_information25              in  varchar2
  ,p_cty_information26              in  varchar2
  ,p_cty_information27              in  varchar2
  ,p_cty_information28              in  varchar2
  ,p_cty_information29              in  varchar2
  ,p_cty_information30              in  varchar2
  );
--
end pay_cty_bk2;

/
