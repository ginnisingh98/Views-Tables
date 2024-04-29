--------------------------------------------------------
--  DDL for Package PER_ABC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABC_RKI" AUTHID CURRENT_USER as
/* $Header: peabcrhi.pkh 120.1 2005/09/28 05:02 snukala noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_abc_rki;

 

/
