--------------------------------------------------------
--  DDL for Package Body PER_SHT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHT_RKI" as
/* $Header: peshtrhi.pkb 120.0 2005/05/31 21:06:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_SHARED_TYPE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SHARED_TYPE_NAME in VARCHAR2
,P_SHARED_TYPE_CODE in VARCHAR2
,P_SYSTEM_TYPE_CD in VARCHAR2
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
,P_INFORMATION_CATEGORY in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_LOOKUP_TYPE in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: per_sht_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: per_sht_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end per_sht_RKI;

/
