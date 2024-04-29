--------------------------------------------------------
--  DDL for Package Body HR_LOCATION_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LOCATION_BK5" as
/* $Header: hrlocapi.pkb 120.1.12010000.3 2010/01/19 13:26:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:18 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_LOCATION_LEGAL_ADR_A
(P_EFFECTIVE_DATE in DATE
,P_LOCATION_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_TIMEZONE_CODE in VARCHAR2
,P_ADDRESS_LINE_1 in VARCHAR2
,P_ADDRESS_LINE_2 in VARCHAR2
,P_ADDRESS_LINE_3 in VARCHAR2
,P_INACTIVE_DATE in DATE
,P_POSTAL_CODE in VARCHAR2
,P_REGION_1 in VARCHAR2
,P_REGION_2 in VARCHAR2
,P_REGION_3 in VARCHAR2
,P_STYLE in VARCHAR2
,P_TOWN_OR_CITY in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_TELEPHONE_NUMBER_1 in VARCHAR2
,P_TELEPHONE_NUMBER_2 in VARCHAR2
,P_TELEPHONE_NUMBER_3 in VARCHAR2
,P_LOC_INFORMATION13 in VARCHAR2
,P_LOC_INFORMATION14 in VARCHAR2
,P_LOC_INFORMATION15 in VARCHAR2
,P_LOC_INFORMATION16 in VARCHAR2
,P_LOC_INFORMATION17 in VARCHAR2
,P_LOC_INFORMATION18 in VARCHAR2
,P_LOC_INFORMATION19 in VARCHAR2
,P_LOC_INFORMATION20 in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_LOCATION_BK5.UPDATE_LOCATION_LEGAL_ADR_A', 10);
hr_utility.set_location(' Leaving: HR_LOCATION_BK5.UPDATE_LOCATION_LEGAL_ADR_A', 20);
end UPDATE_LOCATION_LEGAL_ADR_A;
procedure UPDATE_LOCATION_LEGAL_ADR_B
(P_EFFECTIVE_DATE in DATE
,P_LOCATION_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_TIMEZONE_CODE in VARCHAR2
,P_ADDRESS_LINE_1 in VARCHAR2
,P_ADDRESS_LINE_2 in VARCHAR2
,P_ADDRESS_LINE_3 in VARCHAR2
,P_INACTIVE_DATE in DATE
,P_POSTAL_CODE in VARCHAR2
,P_REGION_1 in VARCHAR2
,P_REGION_2 in VARCHAR2
,P_REGION_3 in VARCHAR2
,P_STYLE in VARCHAR2
,P_TOWN_OR_CITY in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_TELEPHONE_NUMBER_1 in VARCHAR2
,P_TELEPHONE_NUMBER_2 in VARCHAR2
,P_TELEPHONE_NUMBER_3 in VARCHAR2
,P_LOC_INFORMATION13 in VARCHAR2
,P_LOC_INFORMATION14 in VARCHAR2
,P_LOC_INFORMATION15 in VARCHAR2
,P_LOC_INFORMATION16 in VARCHAR2
,P_LOC_INFORMATION17 in VARCHAR2
,P_LOC_INFORMATION18 in VARCHAR2
,P_LOC_INFORMATION19 in VARCHAR2
,P_LOC_INFORMATION20 in VARCHAR2
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
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_LOCATION_BK5.UPDATE_LOCATION_LEGAL_ADR_B', 10);
hr_utility.set_location(' Leaving: HR_LOCATION_BK5.UPDATE_LOCATION_LEGAL_ADR_B', 20);
end UPDATE_LOCATION_LEGAL_ADR_B;
end HR_LOCATION_BK5;

/
