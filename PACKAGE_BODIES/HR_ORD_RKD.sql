--------------------------------------------------------
--  DDL for Package Body HR_ORD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORD_RKD" as
/* $Header: hrordrhi.pkb 115.7 2002/12/04 06:20:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ORGANIZATION_LINK_ID in NUMBER
,P_PARENT_ORGANIZATION_ID_O in NUMBER
,P_CHILD_ORGANIZATION_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ORG_LINK_INFORMATION_CATEG_O in VARCHAR2
,P_ORG_LINK_INFORMATION1_O in VARCHAR2
,P_ORG_LINK_INFORMATION2_O in VARCHAR2
,P_ORG_LINK_INFORMATION3_O in VARCHAR2
,P_ORG_LINK_INFORMATION4_O in VARCHAR2
,P_ORG_LINK_INFORMATION5_O in VARCHAR2
,P_ORG_LINK_INFORMATION6_O in VARCHAR2
,P_ORG_LINK_INFORMATION7_O in VARCHAR2
,P_ORG_LINK_INFORMATION8_O in VARCHAR2
,P_ORG_LINK_INFORMATION9_O in VARCHAR2
,P_ORG_LINK_INFORMATION10_O in VARCHAR2
,P_ORG_LINK_INFORMATION11_O in VARCHAR2
,P_ORG_LINK_INFORMATION12_O in VARCHAR2
,P_ORG_LINK_INFORMATION13_O in VARCHAR2
,P_ORG_LINK_INFORMATION14_O in VARCHAR2
,P_ORG_LINK_INFORMATION15_O in VARCHAR2
,P_ORG_LINK_INFORMATION16_O in VARCHAR2
,P_ORG_LINK_INFORMATION17_O in VARCHAR2
,P_ORG_LINK_INFORMATION18_O in VARCHAR2
,P_ORG_LINK_INFORMATION19_O in VARCHAR2
,P_ORG_LINK_INFORMATION20_O in VARCHAR2
,P_ORG_LINK_INFORMATION21_O in VARCHAR2
,P_ORG_LINK_INFORMATION22_O in VARCHAR2
,P_ORG_LINK_INFORMATION23_O in VARCHAR2
,P_ORG_LINK_INFORMATION24_O in VARCHAR2
,P_ORG_LINK_INFORMATION25_O in VARCHAR2
,P_ORG_LINK_INFORMATION26_O in VARCHAR2
,P_ORG_LINK_INFORMATION27_O in VARCHAR2
,P_ORG_LINK_INFORMATION28_O in VARCHAR2
,P_ORG_LINK_INFORMATION29_O in VARCHAR2
,P_ORG_LINK_INFORMATION30_O in VARCHAR2
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
,P_ATTRIBUTE21_O in VARCHAR2
,P_ATTRIBUTE22_O in VARCHAR2
,P_ATTRIBUTE23_O in VARCHAR2
,P_ATTRIBUTE24_O in VARCHAR2
,P_ATTRIBUTE25_O in VARCHAR2
,P_ATTRIBUTE26_O in VARCHAR2
,P_ATTRIBUTE27_O in VARCHAR2
,P_ATTRIBUTE28_O in VARCHAR2
,P_ATTRIBUTE29_O in VARCHAR2
,P_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ORG_LINK_TYPE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ORD_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: HR_ORD_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end HR_ORD_RKD;

/