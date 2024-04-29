--------------------------------------------------------
--  DDL for Package HR_DE_ORGANIZATION_LINKS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_ORGANIZATION_LINKS_BK1" AUTHID CURRENT_USER as
/* $Header: hrordapi.pkh 120.1 2005/10/02 02:04:52 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_link_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_link_b
  (p_effective_date                 in     date
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_business_group_id              in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2
  ,p_org_link_information1          in     varchar2
  ,p_org_link_information2          in     varchar2
  ,p_org_link_information3          in     varchar2
  ,p_org_link_information4          in     varchar2
  ,p_org_link_information5          in     varchar2
  ,p_org_link_information6          in     varchar2
  ,p_org_link_information7          in     varchar2
  ,p_org_link_information8          in     varchar2
  ,p_org_link_information9          in     varchar2
  ,p_org_link_information10         in     varchar2
  ,p_org_link_information11         in     varchar2
  ,p_org_link_information12         in     varchar2
  ,p_org_link_information13         in     varchar2
  ,p_org_link_information14         in     varchar2
  ,p_org_link_information15         in     varchar2
  ,p_org_link_information16         in     varchar2
  ,p_org_link_information17         in     varchar2
  ,p_org_link_information18         in     varchar2
  ,p_org_link_information19         in     varchar2
  ,p_org_link_information20         in     varchar2
  ,p_org_link_information21         in     varchar2
  ,p_org_link_information22         in     varchar2
  ,p_org_link_information23         in     varchar2
  ,p_org_link_information24         in     varchar2
  ,p_org_link_information25         in     varchar2
  ,p_org_link_information26         in     varchar2
  ,p_org_link_information27         in     varchar2
  ,p_org_link_information28         in     varchar2
  ,p_org_link_information29         in     varchar2
  ,p_org_link_information30         in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------- -------< create_link_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_link_a
  (p_effective_date                 in     date
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_business_group_id              in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2
  ,p_org_link_information1          in     varchar2
  ,p_org_link_information2          in     varchar2
  ,p_org_link_information3          in     varchar2
  ,p_org_link_information4          in     varchar2
  ,p_org_link_information5          in     varchar2
  ,p_org_link_information6          in     varchar2
  ,p_org_link_information7          in     varchar2
  ,p_org_link_information8          in     varchar2
  ,p_org_link_information9          in     varchar2
  ,p_org_link_information10         in     varchar2
  ,p_org_link_information11         in     varchar2
  ,p_org_link_information12         in     varchar2
  ,p_org_link_information13         in     varchar2
  ,p_org_link_information14         in     varchar2
  ,p_org_link_information15         in     varchar2
  ,p_org_link_information16         in     varchar2
  ,p_org_link_information17         in     varchar2
  ,p_org_link_information18         in     varchar2
  ,p_org_link_information19         in     varchar2
  ,p_org_link_information20         in     varchar2
  ,p_org_link_information21         in     varchar2
  ,p_org_link_information22         in     varchar2
  ,p_org_link_information23         in     varchar2
  ,p_org_link_information24         in     varchar2
  ,p_org_link_information25         in     varchar2
  ,p_org_link_information26         in     varchar2
  ,p_org_link_information27         in     varchar2
  ,p_org_link_information28         in     varchar2
  ,p_org_link_information29         in     varchar2
  ,p_org_link_information30         in     varchar2
  ,p_attribute_category             in     varchar2
  ,p_attribute1                     in     varchar2
  ,p_attribute2                     in     varchar2
  ,p_attribute3                     in     varchar2
  ,p_attribute4                     in     varchar2
  ,p_attribute5                     in     varchar2
  ,p_attribute6                     in     varchar2
  ,p_attribute7                     in     varchar2
  ,p_attribute8                     in     varchar2
  ,p_attribute9                     in     varchar2
  ,p_attribute10                    in     varchar2
  ,p_attribute11                    in     varchar2
  ,p_attribute12                    in     varchar2
  ,p_attribute13                    in     varchar2
  ,p_attribute14                    in     varchar2
  ,p_attribute15                    in     varchar2
  ,p_attribute16                    in     varchar2
  ,p_attribute17                    in     varchar2
  ,p_attribute18                    in     varchar2
  ,p_attribute19                    in     varchar2
  ,p_attribute20                    in     varchar2
  ,p_attribute21                    in     varchar2
  ,p_attribute22                    in     varchar2
  ,p_attribute23                    in     varchar2
  ,p_attribute24                    in     varchar2
  ,p_attribute25                    in     varchar2
  ,p_attribute26                    in     varchar2
  ,p_attribute27                    in     varchar2
  ,p_attribute28                    in     varchar2
  ,p_attribute29                    in     varchar2
  ,p_attribute30                    in     varchar2
  ,p_organization_link_id           in     number
  ,p_object_version_number          in     number
  );
--
end hr_de_organization_links_bk1;

 

/
