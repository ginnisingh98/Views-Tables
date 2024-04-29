--------------------------------------------------------
--  DDL for Package HR_ORD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORD_RKD" AUTHID CURRENT_USER as
/* $Header: hrordrhi.pkh 120.0 2005/05/31 01:49:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_organization_link_id         in number
  ,p_parent_organization_id_o     in number
  ,p_child_organization_id_o      in number
  ,p_business_group_id_o          in number
  ,p_org_link_information_categ_o in varchar2
  ,p_org_link_information1_o      in varchar2
  ,p_org_link_information2_o      in varchar2
  ,p_org_link_information3_o      in varchar2
  ,p_org_link_information4_o      in varchar2
  ,p_org_link_information5_o      in varchar2
  ,p_org_link_information6_o      in varchar2
  ,p_org_link_information7_o      in varchar2
  ,p_org_link_information8_o      in varchar2
  ,p_org_link_information9_o      in varchar2
  ,p_org_link_information10_o     in varchar2
  ,p_org_link_information11_o     in varchar2
  ,p_org_link_information12_o     in varchar2
  ,p_org_link_information13_o     in varchar2
  ,p_org_link_information14_o     in varchar2
  ,p_org_link_information15_o     in varchar2
  ,p_org_link_information16_o     in varchar2
  ,p_org_link_information17_o     in varchar2
  ,p_org_link_information18_o     in varchar2
  ,p_org_link_information19_o     in varchar2
  ,p_org_link_information20_o     in varchar2
  ,p_org_link_information21_o     in varchar2
  ,p_org_link_information22_o     in varchar2
  ,p_org_link_information23_o     in varchar2
  ,p_org_link_information24_o     in varchar2
  ,p_org_link_information25_o     in varchar2
  ,p_org_link_information26_o     in varchar2
  ,p_org_link_information27_o     in varchar2
  ,p_org_link_information28_o     in varchar2
  ,p_org_link_information29_o     in varchar2
  ,p_org_link_information30_o     in varchar2
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
  ,p_object_version_number_o      in number
  ,p_org_link_type_o              in varchar2
  );
--
end hr_ord_rkd;

 

/
