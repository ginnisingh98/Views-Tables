--------------------------------------------------------
--  DDL for Package PER_DIS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DIS_RKD" AUTHID CURRENT_USER as
/* $Header: pedisrhi.pkh 120.0 2005/05/31 07:41:06 appldev noship $ */
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
  ,p_disability_id                in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_person_id_o                  in number
  ,p_incident_id_o                in number
  ,p_organization_id_o            in number
  ,p_registration_id_o            in varchar2
  ,p_registration_date_o          in date
  ,p_registration_exp_date_o      in date
  ,p_category_o                   in varchar2
  ,p_status_o                     in varchar2
  ,p_description_o                in varchar2
  ,p_degree_o                     in number
  ,p_quota_fte_o                  in number
  ,p_reason_o                     in varchar2
  ,p_pre_registration_job_o       in varchar2
  ,p_work_restriction_o           in varchar2
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
  ,p_dis_information_category_o   in varchar2
  ,p_dis_information1_o           in varchar2
  ,p_dis_information2_o           in varchar2
  ,p_dis_information3_o           in varchar2
  ,p_dis_information4_o           in varchar2
  ,p_dis_information5_o           in varchar2
  ,p_dis_information6_o           in varchar2
  ,p_dis_information7_o           in varchar2
  ,p_dis_information8_o           in varchar2
  ,p_dis_information9_o           in varchar2
  ,p_dis_information10_o          in varchar2
  ,p_dis_information11_o          in varchar2
  ,p_dis_information12_o          in varchar2
  ,p_dis_information13_o          in varchar2
  ,p_dis_information14_o          in varchar2
  ,p_dis_information15_o          in varchar2
  ,p_dis_information16_o          in varchar2
  ,p_dis_information17_o          in varchar2
  ,p_dis_information18_o          in varchar2
  ,p_dis_information19_o          in varchar2
  ,p_dis_information20_o          in varchar2
  ,p_dis_information21_o          in varchar2
  ,p_dis_information22_o          in varchar2
  ,p_dis_information23_o          in varchar2
  ,p_dis_information24_o          in varchar2
  ,p_dis_information25_o          in varchar2
  ,p_dis_information26_o          in varchar2
  ,p_dis_information27_o          in varchar2
  ,p_dis_information28_o          in varchar2
  ,p_dis_information29_o          in varchar2
  ,p_dis_information30_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_dis_rkd;

 

/
