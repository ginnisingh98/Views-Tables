--------------------------------------------------------
--  DDL for Package Body PER_PSP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSP_RKD" as
/* $Header: pepsprhi.pkb 115.5 2003/11/17 13:06:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:53:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SPINAL_POINT_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PARENT_SPINE_ID_O in NUMBER
,P_SEQUENCE_O in NUMBER
,P_SPINAL_POINT_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
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
hr_utility.set_location('Entering: PER_PSP_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_PSP_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_PSP_RKD;

/
