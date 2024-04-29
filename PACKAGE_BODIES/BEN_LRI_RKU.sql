--------------------------------------------------------
--  DDL for Package Body BEN_LRI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LRI_RKU" as
/* $Header: belrirhi.pkb 115.0 2003/09/23 10:18:35 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:53 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_LER_EXTRA_INFO_ID in NUMBER
,P_INFORMATION_TYPE in VARCHAR2
,P_LER_ID in NUMBER
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_LRI_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LRI_ATTRIBUTE1 in VARCHAR2
,P_LRI_ATTRIBUTE2 in VARCHAR2
,P_LRI_ATTRIBUTE3 in VARCHAR2
,P_LRI_ATTRIBUTE4 in VARCHAR2
,P_LRI_ATTRIBUTE5 in VARCHAR2
,P_LRI_ATTRIBUTE6 in VARCHAR2
,P_LRI_ATTRIBUTE7 in VARCHAR2
,P_LRI_ATTRIBUTE8 in VARCHAR2
,P_LRI_ATTRIBUTE9 in VARCHAR2
,P_LRI_ATTRIBUTE10 in VARCHAR2
,P_LRI_ATTRIBUTE11 in VARCHAR2
,P_LRI_ATTRIBUTE12 in VARCHAR2
,P_LRI_ATTRIBUTE13 in VARCHAR2
,P_LRI_ATTRIBUTE14 in VARCHAR2
,P_LRI_ATTRIBUTE15 in VARCHAR2
,P_LRI_ATTRIBUTE16 in VARCHAR2
,P_LRI_ATTRIBUTE17 in VARCHAR2
,P_LRI_ATTRIBUTE18 in VARCHAR2
,P_LRI_ATTRIBUTE19 in VARCHAR2
,P_LRI_ATTRIBUTE20 in VARCHAR2
,P_LRI_INFORMATION_CATEGORY in VARCHAR2
,P_LRI_INFORMATION1 in VARCHAR2
,P_LRI_INFORMATION2 in VARCHAR2
,P_LRI_INFORMATION3 in VARCHAR2
,P_LRI_INFORMATION4 in VARCHAR2
,P_LRI_INFORMATION5 in VARCHAR2
,P_LRI_INFORMATION6 in VARCHAR2
,P_LRI_INFORMATION7 in VARCHAR2
,P_LRI_INFORMATION8 in VARCHAR2
,P_LRI_INFORMATION9 in VARCHAR2
,P_LRI_INFORMATION10 in VARCHAR2
,P_LRI_INFORMATION11 in VARCHAR2
,P_LRI_INFORMATION12 in VARCHAR2
,P_LRI_INFORMATION13 in VARCHAR2
,P_LRI_INFORMATION14 in VARCHAR2
,P_LRI_INFORMATION15 in VARCHAR2
,P_LRI_INFORMATION16 in VARCHAR2
,P_LRI_INFORMATION17 in VARCHAR2
,P_LRI_INFORMATION18 in VARCHAR2
,P_LRI_INFORMATION19 in VARCHAR2
,P_LRI_INFORMATION20 in VARCHAR2
,P_LRI_INFORMATION21 in VARCHAR2
,P_LRI_INFORMATION22 in VARCHAR2
,P_LRI_INFORMATION23 in VARCHAR2
,P_LRI_INFORMATION24 in VARCHAR2
,P_LRI_INFORMATION25 in VARCHAR2
,P_LRI_INFORMATION26 in VARCHAR2
,P_LRI_INFORMATION27 in VARCHAR2
,P_LRI_INFORMATION28 in VARCHAR2
,P_LRI_INFORMATION29 in VARCHAR2
,P_LRI_INFORMATION30 in VARCHAR2
,P_INFORMATION_TYPE_O in VARCHAR2
,P_LER_ID_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_LRI_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LRI_ATTRIBUTE1_O in VARCHAR2
,P_LRI_ATTRIBUTE2_O in VARCHAR2
,P_LRI_ATTRIBUTE3_O in VARCHAR2
,P_LRI_ATTRIBUTE4_O in VARCHAR2
,P_LRI_ATTRIBUTE5_O in VARCHAR2
,P_LRI_ATTRIBUTE6_O in VARCHAR2
,P_LRI_ATTRIBUTE7_O in VARCHAR2
,P_LRI_ATTRIBUTE8_O in VARCHAR2
,P_LRI_ATTRIBUTE9_O in VARCHAR2
,P_LRI_ATTRIBUTE10_O in VARCHAR2
,P_LRI_ATTRIBUTE11_O in VARCHAR2
,P_LRI_ATTRIBUTE12_O in VARCHAR2
,P_LRI_ATTRIBUTE13_O in VARCHAR2
,P_LRI_ATTRIBUTE14_O in VARCHAR2
,P_LRI_ATTRIBUTE15_O in VARCHAR2
,P_LRI_ATTRIBUTE16_O in VARCHAR2
,P_LRI_ATTRIBUTE17_O in VARCHAR2
,P_LRI_ATTRIBUTE18_O in VARCHAR2
,P_LRI_ATTRIBUTE19_O in VARCHAR2
,P_LRI_ATTRIBUTE20_O in VARCHAR2
,P_LRI_INFORMATION_CATEGORY_O in VARCHAR2
,P_LRI_INFORMATION1_O in VARCHAR2
,P_LRI_INFORMATION2_O in VARCHAR2
,P_LRI_INFORMATION3_O in VARCHAR2
,P_LRI_INFORMATION4_O in VARCHAR2
,P_LRI_INFORMATION5_O in VARCHAR2
,P_LRI_INFORMATION6_O in VARCHAR2
,P_LRI_INFORMATION7_O in VARCHAR2
,P_LRI_INFORMATION8_O in VARCHAR2
,P_LRI_INFORMATION9_O in VARCHAR2
,P_LRI_INFORMATION10_O in VARCHAR2
,P_LRI_INFORMATION11_O in VARCHAR2
,P_LRI_INFORMATION12_O in VARCHAR2
,P_LRI_INFORMATION13_O in VARCHAR2
,P_LRI_INFORMATION14_O in VARCHAR2
,P_LRI_INFORMATION15_O in VARCHAR2
,P_LRI_INFORMATION16_O in VARCHAR2
,P_LRI_INFORMATION17_O in VARCHAR2
,P_LRI_INFORMATION18_O in VARCHAR2
,P_LRI_INFORMATION19_O in VARCHAR2
,P_LRI_INFORMATION20_O in VARCHAR2
,P_LRI_INFORMATION21_O in VARCHAR2
,P_LRI_INFORMATION22_O in VARCHAR2
,P_LRI_INFORMATION23_O in VARCHAR2
,P_LRI_INFORMATION24_O in VARCHAR2
,P_LRI_INFORMATION25_O in VARCHAR2
,P_LRI_INFORMATION26_O in VARCHAR2
,P_LRI_INFORMATION27_O in VARCHAR2
,P_LRI_INFORMATION28_O in VARCHAR2
,P_LRI_INFORMATION29_O in VARCHAR2
,P_LRI_INFORMATION30_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LRI_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_LRI_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_LRI_RKU;

/