--------------------------------------------------------
--  DDL for Package Body HR_DE_ORGANIZATION_LINKS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_ORGANIZATION_LINKS_BK1" as
/* $Header: hrordapi.pkb 115.4 2002/12/16 10:38:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:11 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_LINK_A
(P_EFFECTIVE_DATE in DATE
,P_PARENT_ORGANIZATION_ID in NUMBER
,P_CHILD_ORGANIZATION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ORG_LINK_TYPE in VARCHAR2
,P_ORG_LINK_INFORMATION_CATEGOR in VARCHAR2
,P_ORG_LINK_INFORMATION1 in VARCHAR2
,P_ORG_LINK_INFORMATION2 in VARCHAR2
,P_ORG_LINK_INFORMATION3 in VARCHAR2
,P_ORG_LINK_INFORMATION4 in VARCHAR2
,P_ORG_LINK_INFORMATION5 in VARCHAR2
,P_ORG_LINK_INFORMATION6 in VARCHAR2
,P_ORG_LINK_INFORMATION7 in VARCHAR2
,P_ORG_LINK_INFORMATION8 in VARCHAR2
,P_ORG_LINK_INFORMATION9 in VARCHAR2
,P_ORG_LINK_INFORMATION10 in VARCHAR2
,P_ORG_LINK_INFORMATION11 in VARCHAR2
,P_ORG_LINK_INFORMATION12 in VARCHAR2
,P_ORG_LINK_INFORMATION13 in VARCHAR2
,P_ORG_LINK_INFORMATION14 in VARCHAR2
,P_ORG_LINK_INFORMATION15 in VARCHAR2
,P_ORG_LINK_INFORMATION16 in VARCHAR2
,P_ORG_LINK_INFORMATION17 in VARCHAR2
,P_ORG_LINK_INFORMATION18 in VARCHAR2
,P_ORG_LINK_INFORMATION19 in VARCHAR2
,P_ORG_LINK_INFORMATION20 in VARCHAR2
,P_ORG_LINK_INFORMATION21 in VARCHAR2
,P_ORG_LINK_INFORMATION22 in VARCHAR2
,P_ORG_LINK_INFORMATION23 in VARCHAR2
,P_ORG_LINK_INFORMATION24 in VARCHAR2
,P_ORG_LINK_INFORMATION25 in VARCHAR2
,P_ORG_LINK_INFORMATION26 in VARCHAR2
,P_ORG_LINK_INFORMATION27 in VARCHAR2
,P_ORG_LINK_INFORMATION28 in VARCHAR2
,P_ORG_LINK_INFORMATION29 in VARCHAR2
,P_ORG_LINK_INFORMATION30 in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_ORGANIZATION_LINK_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_DE_ORGANIZATION_LINKS_BK1.CREATE_LINK_A', 10);
hr_utility.set_location(' Leaving: HR_DE_ORGANIZATION_LINKS_BK1.CREATE_LINK_A', 20);
end CREATE_LINK_A;
procedure CREATE_LINK_B
(P_EFFECTIVE_DATE in DATE
,P_PARENT_ORGANIZATION_ID in NUMBER
,P_CHILD_ORGANIZATION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ORG_LINK_TYPE in VARCHAR2
,P_ORG_LINK_INFORMATION_CATEGOR in VARCHAR2
,P_ORG_LINK_INFORMATION1 in VARCHAR2
,P_ORG_LINK_INFORMATION2 in VARCHAR2
,P_ORG_LINK_INFORMATION3 in VARCHAR2
,P_ORG_LINK_INFORMATION4 in VARCHAR2
,P_ORG_LINK_INFORMATION5 in VARCHAR2
,P_ORG_LINK_INFORMATION6 in VARCHAR2
,P_ORG_LINK_INFORMATION7 in VARCHAR2
,P_ORG_LINK_INFORMATION8 in VARCHAR2
,P_ORG_LINK_INFORMATION9 in VARCHAR2
,P_ORG_LINK_INFORMATION10 in VARCHAR2
,P_ORG_LINK_INFORMATION11 in VARCHAR2
,P_ORG_LINK_INFORMATION12 in VARCHAR2
,P_ORG_LINK_INFORMATION13 in VARCHAR2
,P_ORG_LINK_INFORMATION14 in VARCHAR2
,P_ORG_LINK_INFORMATION15 in VARCHAR2
,P_ORG_LINK_INFORMATION16 in VARCHAR2
,P_ORG_LINK_INFORMATION17 in VARCHAR2
,P_ORG_LINK_INFORMATION18 in VARCHAR2
,P_ORG_LINK_INFORMATION19 in VARCHAR2
,P_ORG_LINK_INFORMATION20 in VARCHAR2
,P_ORG_LINK_INFORMATION21 in VARCHAR2
,P_ORG_LINK_INFORMATION22 in VARCHAR2
,P_ORG_LINK_INFORMATION23 in VARCHAR2
,P_ORG_LINK_INFORMATION24 in VARCHAR2
,P_ORG_LINK_INFORMATION25 in VARCHAR2
,P_ORG_LINK_INFORMATION26 in VARCHAR2
,P_ORG_LINK_INFORMATION27 in VARCHAR2
,P_ORG_LINK_INFORMATION28 in VARCHAR2
,P_ORG_LINK_INFORMATION29 in VARCHAR2
,P_ORG_LINK_INFORMATION30 in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_DE_ORGANIZATION_LINKS_BK1.CREATE_LINK_B', 10);
hr_utility.set_location(' Leaving: HR_DE_ORGANIZATION_LINKS_BK1.CREATE_LINK_B', 20);
end CREATE_LINK_B;
end HR_DE_ORGANIZATION_LINKS_BK1;

/
