--------------------------------------------------------
--  DDL for Package PER_MEA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEA_RKD" AUTHID CURRENT_USER as
/* $Header: pemearhi.pkh 120.0 2005/05/31 11:22:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_medical_assessment_id        in number
  ,p_person_id_o                  in number
  ,p_examiner_name_o              in varchar2
  ,p_organization_id_o            in number
  ,p_consultation_date_o          in date
  ,p_consultation_type_o          in varchar2
  ,p_incident_id_o                in number
  ,p_consultation_result_o        in varchar2
  ,p_disability_id_o              in number
  ,p_next_consultation_date_o     in date
  ,p_description_o                in varchar2
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
  ,p_mea_information_category_o   in varchar2
  ,p_mea_information1_o           in varchar2
  ,p_mea_information2_o           in varchar2
  ,p_mea_information3_o           in varchar2
  ,p_mea_information4_o           in varchar2
  ,p_mea_information5_o           in varchar2
  ,p_mea_information6_o           in varchar2
  ,p_mea_information7_o           in varchar2
  ,p_mea_information8_o           in varchar2
  ,p_mea_information9_o           in varchar2
  ,p_mea_information10_o          in varchar2
  ,p_mea_information11_o          in varchar2
  ,p_mea_information12_o          in varchar2
  ,p_mea_information13_o          in varchar2
  ,p_mea_information14_o          in varchar2
  ,p_mea_information15_o          in varchar2
  ,p_mea_information16_o          in varchar2
  ,p_mea_information17_o          in varchar2
  ,p_mea_information18_o          in varchar2
  ,p_mea_information19_o          in varchar2
  ,p_mea_information20_o          in varchar2
  ,p_mea_information21_o          in varchar2
  ,p_mea_information22_o          in varchar2
  ,p_mea_information23_o          in varchar2
  ,p_mea_information24_o          in varchar2
  ,p_mea_information25_o          in varchar2
  ,p_mea_information26_o          in varchar2
  ,p_mea_information27_o          in varchar2
  ,p_mea_information28_o          in varchar2
  ,p_mea_information29_o          in varchar2
  ,p_mea_information30_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_mea_rkd;

 

/
