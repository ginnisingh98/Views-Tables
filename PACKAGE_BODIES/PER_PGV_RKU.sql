--------------------------------------------------------
--  DDL for Package Body PER_PGV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PGV_RKU" as
/* $Header: pepgvrhi.pkb 115.11 2004/06/10 23:41:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:45 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_HIERARCHY_VERSION_ID in NUMBER
,P_VERSION_NUMBER in NUMBER
,P_DATE_FROM in DATE
,P_DATE_TO in DATE
,P_STATUS in VARCHAR2
,P_VALIDATE_FLAG in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
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
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_VERSION_NUMBER_O in NUMBER
,P_HIERARCHY_ID_O in NUMBER
,P_DATE_FROM_O in DATE
,P_DATE_TO_O in DATE
,P_STATUS_O in VARCHAR2
,P_VALIDATE_FLAG_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
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
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_INFORMATION1_O in VARCHAR2
,P_INFORMATION2_O in VARCHAR2
,P_INFORMATION3_O in VARCHAR2
,P_INFORMATION4_O in VARCHAR2
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in VARCHAR2
,P_INFORMATION11_O in VARCHAR2
,P_INFORMATION12_O in VARCHAR2
,P_INFORMATION13_O in VARCHAR2
,P_INFORMATION14_O in VARCHAR2
,P_INFORMATION15_O in VARCHAR2
,P_INFORMATION16_O in VARCHAR2
,P_INFORMATION17_O in VARCHAR2
,P_INFORMATION18_O in VARCHAR2
,P_INFORMATION19_O in VARCHAR2
,P_INFORMATION20_O in VARCHAR2
,P_INFORMATION21_O in VARCHAR2
,P_INFORMATION22_O in VARCHAR2
,P_INFORMATION23_O in VARCHAR2
,P_INFORMATION24_O in VARCHAR2
,P_INFORMATION25_O in VARCHAR2
,P_INFORMATION26_O in VARCHAR2
,P_INFORMATION27_O in VARCHAR2
,P_INFORMATION28_O in VARCHAR2
,P_INFORMATION29_O in VARCHAR2
,P_INFORMATION30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: per_pgv_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: per_pgv_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end per_pgv_RKU;

/