--------------------------------------------------------
--  DDL for Package Body PER_ABC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABC_RKU" as
/* $Header: peabcrhi.pkb 120.1 2005/09/28 05:04:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ABSENCE_CASE_ID in NUMBER
,P_NAME in VARCHAR2
,P_PERSON_ID in NUMBER
,P_INCIDENT_ID in VARCHAR2
,P_ABSENCE_CATEGORY in VARCHAR2
,P_AC_INFORMATION_CATEGORY in VARCHAR2
,P_AC_INFORMATION1 in VARCHAR2
,P_AC_INFORMATION2 in VARCHAR2
,P_AC_INFORMATION3 in VARCHAR2
,P_AC_INFORMATION4 in VARCHAR2
,P_AC_INFORMATION5 in VARCHAR2
,P_AC_INFORMATION6 in VARCHAR2
,P_AC_INFORMATION7 in VARCHAR2
,P_AC_INFORMATION8 in VARCHAR2
,P_AC_INFORMATION9 in VARCHAR2
,P_AC_INFORMATION10 in VARCHAR2
,P_AC_INFORMATION11 in VARCHAR2
,P_AC_INFORMATION12 in VARCHAR2
,P_AC_INFORMATION13 in VARCHAR2
,P_AC_INFORMATION14 in VARCHAR2
,P_AC_INFORMATION15 in VARCHAR2
,P_AC_INFORMATION16 in VARCHAR2
,P_AC_INFORMATION17 in VARCHAR2
,P_AC_INFORMATION18 in VARCHAR2
,P_AC_INFORMATION19 in VARCHAR2
,P_AC_INFORMATION20 in VARCHAR2
,P_AC_INFORMATION21 in VARCHAR2
,P_AC_INFORMATION22 in VARCHAR2
,P_AC_INFORMATION23 in VARCHAR2
,P_AC_INFORMATION24 in VARCHAR2
,P_AC_INFORMATION25 in VARCHAR2
,P_AC_INFORMATION26 in VARCHAR2
,P_AC_INFORMATION27 in VARCHAR2
,P_AC_INFORMATION28 in VARCHAR2
,P_AC_INFORMATION29 in VARCHAR2
,P_AC_INFORMATION30 in VARCHAR2
,P_AC_ATTRIBUTE_CATEGORY in VARCHAR2
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
,P_BUSINESS_GROUP_ID in NUMBER
,P_COMMENTS in VARCHAR2
,P_NAME_O in VARCHAR2
,P_PERSON_ID_O in NUMBER
,P_INCIDENT_ID_O in VARCHAR2
,P_ABSENCE_CATEGORY_O in VARCHAR2
,P_AC_INFORMATION_CATEGORY_O in VARCHAR2
,P_AC_INFORMATION1_O in VARCHAR2
,P_AC_INFORMATION2_O in VARCHAR2
,P_AC_INFORMATION3_O in VARCHAR2
,P_AC_INFORMATION4_O in VARCHAR2
,P_AC_INFORMATION5_O in VARCHAR2
,P_AC_INFORMATION6_O in VARCHAR2
,P_AC_INFORMATION7_O in VARCHAR2
,P_AC_INFORMATION8_O in VARCHAR2
,P_AC_INFORMATION9_O in VARCHAR2
,P_AC_INFORMATION10_O in VARCHAR2
,P_AC_INFORMATION11_O in VARCHAR2
,P_AC_INFORMATION12_O in VARCHAR2
,P_AC_INFORMATION13_O in VARCHAR2
,P_AC_INFORMATION14_O in VARCHAR2
,P_AC_INFORMATION15_O in VARCHAR2
,P_AC_INFORMATION16_O in VARCHAR2
,P_AC_INFORMATION17_O in VARCHAR2
,P_AC_INFORMATION18_O in VARCHAR2
,P_AC_INFORMATION19_O in VARCHAR2
,P_AC_INFORMATION20_O in VARCHAR2
,P_AC_INFORMATION21_O in VARCHAR2
,P_AC_INFORMATION22_O in VARCHAR2
,P_AC_INFORMATION23_O in VARCHAR2
,P_AC_INFORMATION24_O in VARCHAR2
,P_AC_INFORMATION25_O in VARCHAR2
,P_AC_INFORMATION26_O in VARCHAR2
,P_AC_INFORMATION27_O in VARCHAR2
,P_AC_INFORMATION28_O in VARCHAR2
,P_AC_INFORMATION29_O in VARCHAR2
,P_AC_INFORMATION30_O in VARCHAR2
,P_AC_ATTRIBUTE_CATEGORY_O in VARCHAR2
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
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_COMMENTS_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_ABC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_ABC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_ABC_RKU;

/