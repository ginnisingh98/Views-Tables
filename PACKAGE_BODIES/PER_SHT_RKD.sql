--------------------------------------------------------
--  DDL for Package Body PER_SHT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHT_RKD" as
/* $Header: peshtrhi.pkb 120.0 2005/05/31 21:06:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SHARED_TYPE_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_SHARED_TYPE_NAME_O in VARCHAR2
,P_SHARED_TYPE_CODE_O in VARCHAR2
,P_SYSTEM_TYPE_CD_O in VARCHAR2
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
,P_INFORMATION_CATEGORY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_LOOKUP_TYPE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: per_sht_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: per_sht_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end per_sht_RKD;

/
