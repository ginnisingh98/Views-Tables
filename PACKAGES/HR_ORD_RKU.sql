--------------------------------------------------------
--  DDL for Package HR_ORD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORD_RKU" AUTHID CURRENT_USER as
/* $Header: hrordrhi.pkh 120.0 2005/05/31 01:49:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_organization_link_id         in number
  ,p_parent_organization_id       in number
  ,p_child_organization_id        in number
  ,p_business_group_id            in number
  ,p_org_link_information_categor in varchar2
  ,p_org_link_information1        in varchar2
  ,p_org_link_information2        in varchar2
  ,p_org_link_information3        in varchar2
  ,p_org_link_information4        in varchar2
  ,p_org_link_information5        in varchar2
  ,p_org_link_information6        in varchar2
  ,p_org_link_information7        in varchar2
  ,p_org_link_information8        in varchar2
  ,p_org_link_information9        in varchar2
  ,p_org_link_information10       in varchar2
  ,p_org_link_information11       in varchar2
  ,p_org_link_information12       in varchar2
  ,p_org_link_information13       in varchar2
  ,p_org_link_information14       in varchar2
  ,p_org_link_information15       in varchar2
  ,p_org_link_information16       in varchar2
  ,p_org_link_information17       in varchar2
  ,p_org_link_information18       in varchar2
  ,p_org_link_information19       in varchar2
  ,p_org_link_information20       in varchar2
  ,p_org_link_information21       in varchar2
  ,p_org_link_information22       in varchar2
  ,p_org_link_information23       in varchar2
  ,p_org_link_information24       in varchar2
  ,p_org_link_information25       in varchar2
  ,p_org_link_information26       in varchar2
  ,p_org_link_information27       in varchar2
  ,p_org_link_information28       in varchar2
  ,p_org_link_information29       in varchar2
  ,p_org_link_information30       in varchar2
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
  ,p_object_version_number        in number
  ,p_org_link_type                in varchar2
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
end hr_ord_rku;

 

/
