--------------------------------------------------------
--  DDL for Package PER_PEM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEM_RKU" AUTHID CURRENT_USER as
/* $Header: pepemrhi.pkh 120.0.12010000.3 2008/08/06 09:22:15 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_previous_employer_id         in number
  ,p_business_group_id            in number
  ,p_person_id                    in number
  ,p_party_id                     in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_period_years                 in number
  ,p_period_days                  in number
  ,p_employer_name                in varchar2
  ,p_employer_country             in varchar2
  ,p_employer_address             in varchar2
  ,p_employer_type                in varchar2
  ,p_employer_subtype             in varchar2
  ,p_description                  in varchar2
  ,p_pem_attribute_category       in varchar2
  ,p_pem_attribute1               in varchar2
  ,p_pem_attribute2               in varchar2
  ,p_pem_attribute3               in varchar2
  ,p_pem_attribute4               in varchar2
  ,p_pem_attribute5               in varchar2
  ,p_pem_attribute6               in varchar2
  ,p_pem_attribute7               in varchar2
  ,p_pem_attribute8               in varchar2
  ,p_pem_attribute9               in varchar2
  ,p_pem_attribute10              in varchar2
  ,p_pem_attribute11              in varchar2
  ,p_pem_attribute12              in varchar2
  ,p_pem_attribute13              in varchar2
  ,p_pem_attribute14              in varchar2
  ,p_pem_attribute15              in varchar2
  ,p_pem_attribute16              in varchar2
  ,p_pem_attribute17              in varchar2
  ,p_pem_attribute18              in varchar2
  ,p_pem_attribute19              in varchar2
  ,p_pem_attribute20              in varchar2
  ,p_pem_attribute21              in varchar2
  ,p_pem_attribute22              in varchar2
  ,p_pem_attribute23              in varchar2
  ,p_pem_attribute24              in varchar2
  ,p_pem_attribute25              in varchar2
  ,p_pem_attribute26              in varchar2
  ,p_pem_attribute27              in varchar2
  ,p_pem_attribute28              in varchar2
  ,p_pem_attribute29              in varchar2
  ,p_pem_attribute30              in varchar2
  ,p_pem_information_category     in varchar2
  ,p_pem_information1             in varchar2
  ,p_pem_information2             in varchar2
  ,p_pem_information3             in varchar2
  ,p_pem_information4             in varchar2
  ,p_pem_information5             in varchar2
  ,p_pem_information6             in varchar2
  ,p_pem_information7             in varchar2
  ,p_pem_information8             in varchar2
  ,p_pem_information9             in varchar2
  ,p_pem_information10            in varchar2
  ,p_pem_information11            in varchar2
  ,p_pem_information12            in varchar2
  ,p_pem_information13            in varchar2
  ,p_pem_information14            in varchar2
  ,p_pem_information15            in varchar2
  ,p_pem_information16            in varchar2
  ,p_pem_information17            in varchar2
  ,p_pem_information18            in varchar2
  ,p_pem_information19            in varchar2
  ,p_pem_information20            in varchar2
  ,p_pem_information21            in varchar2
  ,p_pem_information22            in varchar2
  ,p_pem_information23            in varchar2
  ,p_pem_information24            in varchar2
  ,p_pem_information25            in varchar2
  ,p_pem_information26            in varchar2
  ,p_pem_information27            in varchar2
  ,p_pem_information28            in varchar2
  ,p_pem_information29            in varchar2
  ,p_pem_information30            in varchar2
  ,p_object_version_number        in number
  ,p_all_assignments              in varchar2
  ,p_period_months                in number
  ,p_business_group_id_o          in number
  ,p_person_id_o                  in number
  ,p_party_id_o                   in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_period_years_o               in number
  ,p_period_days_o                in number
  ,p_employer_name_o              in varchar2
  ,p_employer_country_o           in varchar2
  ,p_employer_address_o           in varchar2
  ,p_employer_type_o              in varchar2
  ,p_employer_subtype_o           in varchar2
  ,p_description_o                in varchar2
  ,p_pem_attribute_category_o     in varchar2
  ,p_pem_attribute1_o             in varchar2
  ,p_pem_attribute2_o             in varchar2
  ,p_pem_attribute3_o             in varchar2
  ,p_pem_attribute4_o             in varchar2
  ,p_pem_attribute5_o             in varchar2
  ,p_pem_attribute6_o             in varchar2
  ,p_pem_attribute7_o             in varchar2
  ,p_pem_attribute8_o             in varchar2
  ,p_pem_attribute9_o             in varchar2
  ,p_pem_attribute10_o            in varchar2
  ,p_pem_attribute11_o            in varchar2
  ,p_pem_attribute12_o            in varchar2
  ,p_pem_attribute13_o            in varchar2
  ,p_pem_attribute14_o            in varchar2
  ,p_pem_attribute15_o            in varchar2
  ,p_pem_attribute16_o            in varchar2
  ,p_pem_attribute17_o            in varchar2
  ,p_pem_attribute18_o            in varchar2
  ,p_pem_attribute19_o            in varchar2
  ,p_pem_attribute20_o            in varchar2
  ,p_pem_attribute21_o            in varchar2
  ,p_pem_attribute22_o            in varchar2
  ,p_pem_attribute23_o            in varchar2
  ,p_pem_attribute24_o            in varchar2
  ,p_pem_attribute25_o            in varchar2
  ,p_pem_attribute26_o            in varchar2
  ,p_pem_attribute27_o            in varchar2
  ,p_pem_attribute28_o            in varchar2
  ,p_pem_attribute29_o            in varchar2
  ,p_pem_attribute30_o            in varchar2
  ,p_pem_information_category_o   in varchar2
  ,p_pem_information1_o           in varchar2
  ,p_pem_information2_o           in varchar2
  ,p_pem_information3_o           in varchar2
  ,p_pem_information4_o           in varchar2
  ,p_pem_information5_o           in varchar2
  ,p_pem_information6_o           in varchar2
  ,p_pem_information7_o           in varchar2
  ,p_pem_information8_o           in varchar2
  ,p_pem_information9_o           in varchar2
  ,p_pem_information10_o          in varchar2
  ,p_pem_information11_o          in varchar2
  ,p_pem_information12_o          in varchar2
  ,p_pem_information13_o          in varchar2
  ,p_pem_information14_o          in varchar2
  ,p_pem_information15_o          in varchar2
  ,p_pem_information16_o          in varchar2
  ,p_pem_information17_o          in varchar2
  ,p_pem_information18_o          in varchar2
  ,p_pem_information19_o          in varchar2
  ,p_pem_information20_o          in varchar2
  ,p_pem_information21_o          in varchar2
  ,p_pem_information22_o          in varchar2
  ,p_pem_information23_o          in varchar2
  ,p_pem_information24_o          in varchar2
  ,p_pem_information25_o          in varchar2
  ,p_pem_information26_o          in varchar2
  ,p_pem_information27_o          in varchar2
  ,p_pem_information28_o          in varchar2
  ,p_pem_information29_o          in varchar2
  ,p_pem_information30_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_all_assignments_o            in varchar2
  ,p_period_months_o              in number
  );
--
end per_pem_rku;

/
