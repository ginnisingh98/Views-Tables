--------------------------------------------------------
--  DDL for Package PQH_ACC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ACC_RKD" AUTHID CURRENT_USER as
/* $Header: pqaccrhi.pkh 120.0 2005/05/29 01:23:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_accommodation_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_accommodation_name_o         in varchar2
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_business_group_id_o          in number
  ,p_location_id_o                in number
  ,p_accommodation_desc_o         in varchar2
  ,p_accommodation_type_o         in varchar2
  ,p_style_o                      in varchar2
  ,p_address_line_1_o             in varchar2
  ,p_address_line_2_o             in varchar2
  ,p_address_line_3_o             in varchar2
  ,p_town_or_city_o               in varchar2
  ,p_country_o                    in varchar2
  ,p_postal_code_o                in varchar2
  ,p_region_1_o                   in varchar2
  ,p_region_2_o                   in varchar2
  ,p_region_3_o                   in varchar2
  ,p_telephone_number_1_o         in varchar2
  ,p_telephone_number_2_o         in varchar2
  ,p_telephone_number_3_o         in varchar2
  ,p_floor_number_o               in varchar2
  ,p_floor_area_o                 in number
  ,p_floor_area_measure_unit_o    in varchar2
  ,p_main_rooms_o                 in number
  ,p_family_size_o                in number
  ,p_suitability_disabled_o       in varchar2
  ,p_rental_value_o               in number
  ,p_rental_value_currency_o      in varchar2
  ,p_owner_o                      in varchar2
  ,p_comments_o                   in varchar2
  ,p_information_category_o       in varchar2
  ,p_information1_o               in varchar2
  ,p_information2_o               in varchar2
  ,p_information3_o               in varchar2
  ,p_information4_o               in varchar2
  ,p_information5_o               in varchar2
  ,p_information6_o               in varchar2
  ,p_information7_o               in varchar2
  ,p_information8_o               in varchar2
  ,p_information9_o               in varchar2
  ,p_information10_o              in varchar2
  ,p_information11_o              in varchar2
  ,p_information12_o              in varchar2
  ,p_information13_o              in varchar2
  ,p_information14_o              in varchar2
  ,p_information15_o              in varchar2
  ,p_information16_o              in varchar2
  ,p_information17_o              in varchar2
  ,p_information18_o              in varchar2
  ,p_information19_o              in varchar2
  ,p_information20_o              in varchar2
  ,p_information21_o              in varchar2
  ,p_information22_o              in varchar2
  ,p_information23_o              in varchar2
  ,p_information24_o              in varchar2
  ,p_information25_o              in varchar2
  ,p_information26_o              in varchar2
  ,p_information27_o              in varchar2
  ,p_information28_o              in varchar2
  ,p_information29_o              in varchar2
  ,p_information30_o              in varchar2
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
  ,p_object_version_number_o      in number
  );
--
end pqh_acc_rkd;

 

/
