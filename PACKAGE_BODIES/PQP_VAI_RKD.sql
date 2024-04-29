--------------------------------------------------------
--  DDL for Package Body PQP_VAI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAI_RKD" as
/* $Header: pqvairhi.pkb 120.0.12010000.2 2008/08/08 07:19:09 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_VEH_ALLOC_EXTRA_INFO_ID in NUMBER
,P_VEHICLE_ALLOCATION_ID_O in NUMBER
,P_INFORMATION_TYPE_O in VARCHAR2
,P_VAEI_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_VAEI_ATTRIBUTE1_O in VARCHAR2
,P_VAEI_ATTRIBUTE2_O in VARCHAR2
,P_VAEI_ATTRIBUTE3_O in VARCHAR2
,P_VAEI_ATTRIBUTE4_O in VARCHAR2
,P_VAEI_ATTRIBUTE5_O in VARCHAR2
,P_VAEI_ATTRIBUTE6_O in VARCHAR2
,P_VAEI_ATTRIBUTE7_O in VARCHAR2
,P_VAEI_ATTRIBUTE8_O in VARCHAR2
,P_VAEI_ATTRIBUTE9_O in VARCHAR2
,P_VAEI_ATTRIBUTE10_O in VARCHAR2
,P_VAEI_ATTRIBUTE11_O in VARCHAR2
,P_VAEI_ATTRIBUTE12_O in VARCHAR2
,P_VAEI_ATTRIBUTE13_O in VARCHAR2
,P_VAEI_ATTRIBUTE14_O in VARCHAR2
,P_VAEI_ATTRIBUTE15_O in VARCHAR2
,P_VAEI_ATTRIBUTE16_O in VARCHAR2
,P_VAEI_ATTRIBUTE17_O in VARCHAR2
,P_VAEI_ATTRIBUTE18_O in VARCHAR2
,P_VAEI_ATTRIBUTE19_O in VARCHAR2
,P_VAEI_ATTRIBUTE20_O in VARCHAR2
,P_VAEI_INFORMATION_CATEGORY_O in VARCHAR2
,P_VAEI_INFORMATION1_O in VARCHAR2
,P_VAEI_INFORMATION2_O in VARCHAR2
,P_VAEI_INFORMATION3_O in VARCHAR2
,P_VAEI_INFORMATION4_O in VARCHAR2
,P_VAEI_INFORMATION5_O in VARCHAR2
,P_VAEI_INFORMATION6_O in VARCHAR2
,P_VAEI_INFORMATION7_O in VARCHAR2
,P_VAEI_INFORMATION8_O in VARCHAR2
,P_VAEI_INFORMATION9_O in VARCHAR2
,P_VAEI_INFORMATION10_O in VARCHAR2
,P_VAEI_INFORMATION11_O in VARCHAR2
,P_VAEI_INFORMATION12_O in VARCHAR2
,P_VAEI_INFORMATION13_O in VARCHAR2
,P_VAEI_INFORMATION14_O in VARCHAR2
,P_VAEI_INFORMATION15_O in VARCHAR2
,P_VAEI_INFORMATION16_O in VARCHAR2
,P_VAEI_INFORMATION17_O in VARCHAR2
,P_VAEI_INFORMATION18_O in VARCHAR2
,P_VAEI_INFORMATION19_O in VARCHAR2
,P_VAEI_INFORMATION20_O in VARCHAR2
,P_VAEI_INFORMATION21_O in VARCHAR2
,P_VAEI_INFORMATION22_O in VARCHAR2
,P_VAEI_INFORMATION23_O in VARCHAR2
,P_VAEI_INFORMATION24_O in VARCHAR2
,P_VAEI_INFORMATION25_O in VARCHAR2
,P_VAEI_INFORMATION26_O in VARCHAR2
,P_VAEI_INFORMATION27_O in VARCHAR2
,P_VAEI_INFORMATION28_O in VARCHAR2
,P_VAEI_INFORMATION29_O in VARCHAR2
,P_VAEI_INFORMATION30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: PQP_VAI_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQP_VAI_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQP_VAI_RKD;

/