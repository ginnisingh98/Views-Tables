--------------------------------------------------------
--  DDL for Package Body HR_ORD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORD_RKI" as
/* $Header: hrordrhi.pkb 115.7 2002/12/04 06:20:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_ORGANIZATION_LINK_ID in NUMBER
,P_PARENT_ORGANIZATION_ID in NUMBER
,P_CHILD_ORGANIZATION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
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
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ORG_LINK_TYPE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ORD_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_ORD_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_ORD_RKI;

/
