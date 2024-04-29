--------------------------------------------------------
--  DDL for Package PER_ROL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ROL_RKI" AUTHID CURRENT_USER as
/* $Header: perolrhi.pkh 120.0 2005/05/31 18:35:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end per_rol_rki;

 

/
