--------------------------------------------------------
--  DDL for Package PER_ROL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ROL_RKU" AUTHID CURRENT_USER as
/* $Header: perolrhi.pkh 120.0 2005/05/31 18:35:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_role_id                      in number
  ,p_job_id                       in number
  ,p_job_group_id                 in number
  ,p_person_id                    in number
  ,p_organization_id              in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_confidential_date            in date
  ,p_emp_rights_flag              in varchar2
  ,p_end_of_rights_date           in date
  ,p_primary_contact_flag         in varchar2
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
  ,p_role_information_category    in varchar2
  ,p_role_information1            in varchar2
  ,p_role_information2            in varchar2
  ,p_role_information3            in varchar2
  ,p_role_information4            in varchar2
  ,p_role_information5            in varchar2
  ,p_role_information6            in varchar2
  ,p_role_information7            in varchar2
  ,p_role_information8            in varchar2
  ,p_role_information9            in varchar2
  ,p_role_information10           in varchar2
  ,p_role_information11           in varchar2
  ,p_role_information12           in varchar2
  ,p_role_information13           in varchar2
  ,p_role_information14           in varchar2
  ,p_role_information15           in varchar2
  ,p_role_information16           in varchar2
  ,p_role_information17           in varchar2
  ,p_role_information18           in varchar2
  ,p_role_information19           in varchar2
  ,p_role_information20           in varchar2
  ,p_object_version_number        in number
  ,p_job_id_o                     in number
  ,p_job_group_id_o               in number
  ,p_person_id_o                  in number
  ,p_organization_id_o            in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_confidential_date_o          in date
  ,p_emp_rights_flag_o            in varchar2
  ,p_end_of_rights_date_o         in date
  ,p_primary_contact_flag_o       in varchar2
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
  ,p_role_information_category_o  in varchar2
  ,p_role_information1_o          in varchar2
  ,p_role_information2_o          in varchar2
  ,p_role_information3_o          in varchar2
  ,p_role_information4_o          in varchar2
  ,p_role_information5_o          in varchar2
  ,p_role_information6_o          in varchar2
  ,p_role_information7_o          in varchar2
  ,p_role_information8_o          in varchar2
  ,p_role_information9_o          in varchar2
  ,p_role_information10_o         in varchar2
  ,p_role_information11_o         in varchar2
  ,p_role_information12_o         in varchar2
  ,p_role_information13_o         in varchar2
  ,p_role_information14_o         in varchar2
  ,p_role_information15_o         in varchar2
  ,p_role_information16_o         in varchar2
  ,p_role_information17_o         in varchar2
  ,p_role_information18_o         in varchar2
  ,p_role_information19_o         in varchar2
  ,p_role_information20_o         in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_rol_rku;

 

/
