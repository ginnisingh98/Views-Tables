--------------------------------------------------------
--  DDL for Package HR_ORI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORI_RKI" AUTHID CURRENT_USER as
/* $Header: hrorirhi.pkh 120.0.12010000.1 2008/07/28 03:36:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_org_information_id           in number
  ,p_org_information_context      in varchar2
  ,p_organization_id              in number
  ,p_org_information1             in varchar2
  ,p_org_information10            in varchar2
  ,p_org_information11            in varchar2
  ,p_org_information12            in varchar2
  ,p_org_information13            in varchar2
  ,p_org_information14            in varchar2
  ,p_org_information15            in varchar2
  ,p_org_information16            in varchar2
  ,p_org_information17            in varchar2
  ,p_org_information18            in varchar2
  ,p_org_information19            in varchar2
  ,p_org_information2             in varchar2
  ,p_org_information20            in varchar2
  ,p_org_information3             in varchar2
  ,p_org_information4             in varchar2
  ,p_org_information5             in varchar2
  ,p_org_information6             in varchar2
  ,p_org_information7             in varchar2
  ,p_org_information8             in varchar2
  ,p_org_information9             in varchar2
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
  ,p_object_version_number        in number
  );
end hr_ori_rki;

/
