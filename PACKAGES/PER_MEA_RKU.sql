--------------------------------------------------------
--  DDL for Package PER_MEA_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEA_RKU" AUTHID CURRENT_USER as
/* $Header: pemearhi.pkh 120.0 2005/05/31 11:22:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_medical_assessment_id        in number
  ,p_person_id                    in number
  ,p_examiner_name                in varchar2
  ,p_organization_id              in number
  ,p_consultation_date            in date
  ,p_consultation_type            in varchar2
  ,p_incident_id                  in number
  ,p_consultation_result          in varchar2
  ,p_disability_id                in number
  ,p_next_consultation_date       in date
  ,p_description                  in varchar2
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
  ,p_mea_information_category     in varchar2
  ,p_mea_information1             in varchar2
  ,p_mea_information2             in varchar2
  ,p_mea_information3             in varchar2
  ,p_mea_information4             in varchar2
  ,p_mea_information5             in varchar2
  ,p_mea_information6             in varchar2
  ,p_mea_information7             in varchar2
  ,p_mea_information8             in varchar2
  ,p_mea_information9             in varchar2
  ,p_mea_information10            in varchar2
  ,p_mea_information11            in varchar2
  ,p_mea_information12            in varchar2
  ,p_mea_information13            in varchar2
  ,p_mea_information14            in varchar2
  ,p_mea_information15            in varchar2
  ,p_mea_information16            in varchar2
  ,p_mea_information17            in varchar2
  ,p_mea_information18            in varchar2
  ,p_mea_information19            in varchar2
  ,p_mea_information20            in varchar2
  ,p_mea_information21            in varchar2
  ,p_mea_information22            in varchar2
  ,p_mea_information23            in varchar2
  ,p_mea_information24            in varchar2
  ,p_mea_information25            in varchar2
  ,p_mea_information26            in varchar2
  ,p_mea_information27            in varchar2
  ,p_mea_information28            in varchar2
  ,p_mea_information29            in varchar2
  ,p_mea_information30            in varchar2
  ,p_object_version_number        in number
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
end per_mea_rku;

 

/
