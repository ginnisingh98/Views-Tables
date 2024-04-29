--------------------------------------------------------
--  DDL for Package PER_ABC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABC_RKU" AUTHID CURRENT_USER as
/* $Header: peabcrhi.pkh 120.1 2005/09/28 05:02 snukala noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_absence_case_id              in number
  ,p_name                         in varchar2
  ,p_person_id                    in number
  ,p_incident_id                  in varchar2
  ,p_absence_category             in varchar2
  ,p_ac_information_category      in varchar2
  ,p_ac_information1              in varchar2
  ,p_ac_information2              in varchar2
  ,p_ac_information3              in varchar2
  ,p_ac_information4              in varchar2
  ,p_ac_information5              in varchar2
  ,p_ac_information6              in varchar2
  ,p_ac_information7              in varchar2
  ,p_ac_information8              in varchar2
  ,p_ac_information9              in varchar2
  ,p_ac_information10             in varchar2
  ,p_ac_information11             in varchar2
  ,p_ac_information12             in varchar2
  ,p_ac_information13             in varchar2
  ,p_ac_information14             in varchar2
  ,p_ac_information15             in varchar2
  ,p_ac_information16             in varchar2
  ,p_ac_information17             in varchar2
  ,p_ac_information18             in varchar2
  ,p_ac_information19             in varchar2
  ,p_ac_information20             in varchar2
  ,p_ac_information21             in varchar2
  ,p_ac_information22             in varchar2
  ,p_ac_information23             in varchar2
  ,p_ac_information24             in varchar2
  ,p_ac_information25             in varchar2
  ,p_ac_information26             in varchar2
  ,p_ac_information27             in varchar2
  ,p_ac_information28             in varchar2
  ,p_ac_information29             in varchar2
  ,p_ac_information30             in varchar2
  ,p_ac_attribute_category        in varchar2
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
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_comments                     in varchar2
  ,p_name_o                       in varchar2
  ,p_person_id_o                  in number
  ,p_incident_id_o                in varchar2
  ,p_absence_category_o           in varchar2
  ,p_ac_information_category_o    in varchar2
  ,p_ac_information1_o            in varchar2
  ,p_ac_information2_o            in varchar2
  ,p_ac_information3_o            in varchar2
  ,p_ac_information4_o            in varchar2
  ,p_ac_information5_o            in varchar2
  ,p_ac_information6_o            in varchar2
  ,p_ac_information7_o            in varchar2
  ,p_ac_information8_o            in varchar2
  ,p_ac_information9_o            in varchar2
  ,p_ac_information10_o           in varchar2
  ,p_ac_information11_o           in varchar2
  ,p_ac_information12_o           in varchar2
  ,p_ac_information13_o           in varchar2
  ,p_ac_information14_o           in varchar2
  ,p_ac_information15_o           in varchar2
  ,p_ac_information16_o           in varchar2
  ,p_ac_information17_o           in varchar2
  ,p_ac_information18_o           in varchar2
  ,p_ac_information19_o           in varchar2
  ,p_ac_information20_o           in varchar2
  ,p_ac_information21_o           in varchar2
  ,p_ac_information22_o           in varchar2
  ,p_ac_information23_o           in varchar2
  ,p_ac_information24_o           in varchar2
  ,p_ac_information25_o           in varchar2
  ,p_ac_information26_o           in varchar2
  ,p_ac_information27_o           in varchar2
  ,p_ac_information28_o           in varchar2
  ,p_ac_information29_o           in varchar2
  ,p_ac_information30_o           in varchar2
  ,p_ac_attribute_category_o      in varchar2
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
  ,p_business_group_id_o          in number
  ,p_comments_o                   in varchar2
  );
--
end per_abc_rku;

 

/
