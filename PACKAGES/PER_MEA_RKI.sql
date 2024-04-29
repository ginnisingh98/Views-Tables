--------------------------------------------------------
--  DDL for Package PER_MEA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEA_RKI" AUTHID CURRENT_USER as
/* $Header: pemearhi.pkh 120.0 2005/05/31 11:22:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_mea_rki;

 

/
