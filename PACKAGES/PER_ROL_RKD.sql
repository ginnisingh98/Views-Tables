--------------------------------------------------------
--  DDL for Package PER_ROL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ROL_RKD" AUTHID CURRENT_USER as
/* $Header: perolrhi.pkh 120.0 2005/05/31 18:35:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_role_id                      in number
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
end per_rol_rkd;

 

/
