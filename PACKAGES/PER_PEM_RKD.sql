--------------------------------------------------------
--  DDL for Package PER_PEM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PEM_RKD" AUTHID CURRENT_USER as
/* $Header: pepemrhi.pkh 120.0.12010000.3 2008/08/06 09:22:15 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_previous_employer_id         in number
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
end per_pem_rkd;

/
