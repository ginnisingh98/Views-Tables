--------------------------------------------------------
--  DDL for Package PAY_PRF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRF_RKU" AUTHID CURRENT_USER as
/* $Header: pyprfrhi.pkh 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_range_table_id               in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_range_table_number           in number
  ,p_row_value_uom                in varchar2
  ,p_period_frequency             in varchar2
  ,p_earnings_type                in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_last_updated_login           in number
  ,p_created_date                 in date
  ,p_object_version_number        in number
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_ran_information_category     in varchar2
  ,p_ran_information1             in varchar2
  ,p_ran_information2             in varchar2
  ,p_ran_information3             in varchar2
  ,p_ran_information4             in varchar2
  ,p_ran_information5             in varchar2
  ,p_ran_information6             in varchar2
  ,p_ran_information7             in varchar2
  ,p_ran_information8             in varchar2
  ,p_ran_information9             in varchar2
  ,p_ran_information10            in varchar2
  ,p_ran_information11            in varchar2
  ,p_ran_information12            in varchar2
  ,p_ran_information13            in varchar2
  ,p_ran_information14            in varchar2
  ,p_ran_information15            in varchar2
  ,p_ran_information16            in varchar2
  ,p_ran_information17            in varchar2
  ,p_ran_information18            in varchar2
  ,p_ran_information19            in varchar2
  ,p_ran_information20            in varchar2
  ,p_ran_information21            in varchar2
  ,p_ran_information22            in varchar2
  ,p_ran_information23            in varchar2
  ,p_ran_information24            in varchar2
  ,p_ran_information25            in varchar2
  ,p_ran_information26            in varchar2
  ,p_ran_information27            in varchar2
  ,p_ran_information28            in varchar2
  ,p_ran_information29            in varchar2
  ,p_ran_information30            in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_range_table_number_o         in number
  ,p_row_value_uom_o              in varchar2
  ,p_period_frequency_o           in varchar2
  ,p_earnings_type_o              in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_last_updated_login_o         in number
  ,p_created_date_o               in date
  ,p_object_version_number_o      in number
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  ,p_ran_information_category_o   in varchar2
  ,p_ran_information1_o           in varchar2
  ,p_ran_information2_o           in varchar2
  ,p_ran_information3_o           in varchar2
  ,p_ran_information4_o           in varchar2
  ,p_ran_information5_o           in varchar2
  ,p_ran_information6_o           in varchar2
  ,p_ran_information7_o           in varchar2
  ,p_ran_information8_o           in varchar2
  ,p_ran_information9_o           in varchar2
  ,p_ran_information10_o          in varchar2
  ,p_ran_information11_o          in varchar2
  ,p_ran_information12_o          in varchar2
  ,p_ran_information13_o          in varchar2
  ,p_ran_information14_o          in varchar2
  ,p_ran_information15_o          in varchar2
  ,p_ran_information16_o          in varchar2
  ,p_ran_information17_o          in varchar2
  ,p_ran_information18_o          in varchar2
  ,p_ran_information19_o          in varchar2
  ,p_ran_information20_o          in varchar2
  ,p_ran_information21_o          in varchar2
  ,p_ran_information22_o          in varchar2
  ,p_ran_information23_o          in varchar2
  ,p_ran_information24_o          in varchar2
  ,p_ran_information25_o          in varchar2
  ,p_ran_information26_o          in varchar2
  ,p_ran_information27_o          in varchar2
  ,p_ran_information28_o          in varchar2
  ,p_ran_information29_o          in varchar2
  ,p_ran_information30_o          in varchar2
  );
--
end pay_prf_rku;

 

/
