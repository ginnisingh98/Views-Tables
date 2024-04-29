--------------------------------------------------------
--  DDL for Package HR_ORI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORI_RKD" AUTHID CURRENT_USER as
/* $Header: hrorirhi.pkh 120.0.12010000.1 2008/07/28 03:36:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_org_information_id           in number
  ,p_org_information_context_o    in varchar2
  ,p_organization_id_o            in number
  ,p_org_information1_o           in varchar2
  ,p_org_information10_o          in varchar2
  ,p_org_information11_o          in varchar2
  ,p_org_information12_o          in varchar2
  ,p_org_information13_o          in varchar2
  ,p_org_information14_o          in varchar2
  ,p_org_information15_o          in varchar2
  ,p_org_information16_o          in varchar2
  ,p_org_information17_o          in varchar2
  ,p_org_information18_o          in varchar2
  ,p_org_information19_o          in varchar2
  ,p_org_information2_o           in varchar2
  ,p_org_information20_o          in varchar2
  ,p_org_information3_o           in varchar2
  ,p_org_information4_o           in varchar2
  ,p_org_information5_o           in varchar2
  ,p_org_information6_o           in varchar2
  ,p_org_information7_o           in varchar2
  ,p_org_information8_o           in varchar2
  ,p_org_information9_o           in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
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
  ,p_object_version_number_o      in number
  );
--
end hr_ori_rkd;

/
