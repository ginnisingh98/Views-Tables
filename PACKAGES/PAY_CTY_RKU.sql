--------------------------------------------------------
--  DDL for Package PAY_CTY_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CTY_RKU" AUTHID CURRENT_USER as
/* $Header: pyctyrhi.pkh 120.0.12000000.2 2007/05/01 22:38:44 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_emp_city_tax_rule_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_additional_wa_rate             in number
 ,p_filing_status_code             in varchar2
 ,p_lit_additional_tax             in number
 ,p_lit_override_amount            in number
 ,p_lit_override_rate              in number
 ,p_withholding_allowances         in number
 ,p_lit_exempt                     in varchar2
 ,p_sd_exempt                      in varchar2
 ,p_ht_exempt                      in varchar2
 ,p_wage_exempt                    in varchar2
 ,p_school_district_code           in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_assignment_id_o                in number
 ,p_state_code_o                   in varchar2
 ,p_county_code_o                  in varchar2
 ,p_city_code_o                    in varchar2
 ,p_business_group_id_o            in number
 ,p_additional_wa_rate_o           in number
 ,p_filing_status_code_o           in varchar2
 ,p_jurisdiction_code_o            in varchar2
 ,p_lit_additional_tax_o           in number
 ,p_lit_override_amount_o          in number
 ,p_lit_override_rate_o            in number
 ,p_withholding_allowances_o       in number
 ,p_lit_exempt_o                   in varchar2
 ,p_sd_exempt_o                    in varchar2
 ,p_ht_exempt_o                    in varchar2
 ,p_wage_exempt_o                  in varchar2
 ,p_school_district_code_o         in varchar2
 ,p_object_version_number_o        in number
 ,p_attribute_category              in varchar2,
      p_attribute1                      in varchar2,
      p_attribute2                      in varchar2,
      p_attribute3                      in varchar2,
      p_attribute4                      in varchar2,
      p_attribute5                      in varchar2,
      p_attribute6                      in varchar2,
      p_attribute7                      in varchar2,
      p_attribute8                      in varchar2,
      p_attribute9                      in varchar2,
      p_attribute10                     in varchar2,
      p_attribute11                     in varchar2,
      p_attribute12                     in varchar2,
      p_attribute13                     in varchar2,
      p_attribute14                     in varchar2,
      p_attribute15                     in varchar2,
      p_attribute16                     in varchar2,
      p_attribute17                     in varchar2,
      p_attribute18                     in varchar2,
      p_attribute19                     in varchar2,
      p_attribute20                     in varchar2,
      p_attribute21                     in varchar2,
      p_attribute22                     in varchar2,
      p_attribute23                     in varchar2,
      p_attribute24                     in varchar2,
      p_attribute25                     in varchar2,
      p_attribute26                     in varchar2,
      p_attribute27                     in varchar2,
      p_attribute28                     in varchar2,
      p_attribute29                     in varchar2,
      p_attribute30                     in varchar2,
      p_cty_information_category        in varchar2,
      p_cty_information1                in varchar2,
      p_cty_information2                in varchar2,
      p_cty_information3                in varchar2,
      p_cty_information4                in varchar2,
      p_cty_information5                in varchar2,
      p_cty_information6                in varchar2,
      p_cty_information7                in varchar2,
      p_cty_information8                in varchar2,
      p_cty_information9                in varchar2,
      p_cty_information10               in varchar2,
      p_cty_information11               in varchar2,
      p_cty_information12               in varchar2,
      p_cty_information13               in varchar2,
      p_cty_information14               in varchar2,
      p_cty_information15               in varchar2,
      p_cty_information16               in varchar2,
      p_cty_information17               in varchar2,
      p_cty_information18               in varchar2,
      p_cty_information19               in varchar2,
      p_cty_information20               in varchar2,
      p_cty_information21               in varchar2,
      p_cty_information22               in varchar2,
      p_cty_information23               in varchar2,
      p_cty_information24               in varchar2,
      p_cty_information25               in varchar2,
      p_cty_information26               in varchar2,
      p_cty_information27               in varchar2,
      p_cty_information28               in varchar2,
      p_cty_information29               in varchar2,
      p_cty_information30               in varchar2
  );
--
end pay_cty_rku;

 

/
