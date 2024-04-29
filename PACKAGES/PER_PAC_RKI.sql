--------------------------------------------------------
--  DDL for Package PER_PAC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAC_RKI" AUTHID CURRENT_USER as
/* $Header: pepacrhi.pkh 120.2 2005/10/27 04:01 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_allocated_checklist_id       in number
  ,p_checklist_id                 in number
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_checklist_name               in varchar2
  ,p_description                  in varchar2
  ,p_checklist_category           in varchar2
  ,p_object_version_number        in number
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
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4                 in varchar2
  ,p_information5                 in varchar2
  ,p_information6                 in varchar2
  ,p_information7                 in varchar2
  ,p_information8                 in varchar2
  ,p_information9                 in varchar2
  ,p_information10                in varchar2
  ,p_information11                in varchar2
  ,p_information12                in varchar2
  ,p_information13                in varchar2
  ,p_information14                in varchar2
  ,p_information15                in varchar2
  ,p_information16                in varchar2
  ,p_information17                in varchar2
  ,p_information18                in varchar2
  ,p_information19                in varchar2
  ,p_information20                in varchar2
  );
end per_pac_rki;

 

/
