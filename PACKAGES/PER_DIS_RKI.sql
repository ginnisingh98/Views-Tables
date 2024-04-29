--------------------------------------------------------
--  DDL for Package PER_DIS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DIS_RKI" AUTHID CURRENT_USER as
/* $Header: pedisrhi.pkh 120.0 2005/05/31 07:41:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_disability_id                in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_person_id                    in number
  ,p_incident_id                  in number
  ,p_organization_id              in number
  ,p_registration_id              in varchar2
  ,p_registration_date            in date
  ,p_registration_exp_date        in date
  ,p_category                     in varchar2
  ,p_status                       in varchar2
  ,p_description                  in varchar2
  ,p_degree                       in number
  ,p_quota_fte                    in number
  ,p_reason                       in varchar2
  ,p_pre_registration_job         in varchar2
  ,p_work_restriction             in varchar2
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
  ,p_dis_information_category     in varchar2
  ,p_dis_information1             in varchar2
  ,p_dis_information2             in varchar2
  ,p_dis_information3             in varchar2
  ,p_dis_information4             in varchar2
  ,p_dis_information5             in varchar2
  ,p_dis_information6             in varchar2
  ,p_dis_information7             in varchar2
  ,p_dis_information8             in varchar2
  ,p_dis_information9             in varchar2
  ,p_dis_information10            in varchar2
  ,p_dis_information11            in varchar2
  ,p_dis_information12            in varchar2
  ,p_dis_information13            in varchar2
  ,p_dis_information14            in varchar2
  ,p_dis_information15            in varchar2
  ,p_dis_information16            in varchar2
  ,p_dis_information17            in varchar2
  ,p_dis_information18            in varchar2
  ,p_dis_information19            in varchar2
  ,p_dis_information20            in varchar2
  ,p_dis_information21            in varchar2
  ,p_dis_information22            in varchar2
  ,p_dis_information23            in varchar2
  ,p_dis_information24            in varchar2
  ,p_dis_information25            in varchar2
  ,p_dis_information26            in varchar2
  ,p_dis_information27            in varchar2
  ,p_dis_information28            in varchar2
  ,p_dis_information29            in varchar2
  ,p_dis_information30            in varchar2
  ,p_object_version_number        in number
  );
end per_dis_rki;

 

/
