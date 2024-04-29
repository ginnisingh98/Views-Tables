--------------------------------------------------------
--  DDL for Package PAY_PRF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRF_RKD" AUTHID CURRENT_USER as
/* $Header: pyprfrhi.pkh 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_range_table_id               in number
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
end pay_prf_rkd;

 

/
