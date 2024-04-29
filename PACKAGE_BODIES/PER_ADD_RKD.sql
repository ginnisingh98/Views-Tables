--------------------------------------------------------
--  DDL for Package Body PER_ADD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_RKD" as
/* $Header: peaddrhi.pkb 120.1.12010000.3 2008/08/06 08:53:04 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:02:21 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ADDRESS_ID in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DATE_FROM_O in DATE
,P_ADDRESS_LINE1_O in VARCHAR2
,P_ADDRESS_LINE2_O in VARCHAR2
,P_ADDRESS_LINE3_O in VARCHAR2
,P_ADDRESS_TYPE_O in VARCHAR2
,P_COMMENTS_O in LONG
,P_COUNTRY_O in VARCHAR2
,P_DATE_TO_O in DATE
,P_POSTAL_CODE_O in VARCHAR2
,P_REGION_1_O in VARCHAR2
,P_REGION_2_O in VARCHAR2
,P_REGION_3_O in VARCHAR2
,P_TELEPHONE_NUMBER_1_O in VARCHAR2
,P_TELEPHONE_NUMBER_2_O in VARCHAR2
,P_TELEPHONE_NUMBER_3_O in VARCHAR2
,P_TOWN_OR_CITY_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_ADDR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ADDR_ATTRIBUTE1_O in VARCHAR2
,P_ADDR_ATTRIBUTE2_O in VARCHAR2
,P_ADDR_ATTRIBUTE3_O in VARCHAR2
,P_ADDR_ATTRIBUTE4_O in VARCHAR2
,P_ADDR_ATTRIBUTE5_O in VARCHAR2
,P_ADDR_ATTRIBUTE6_O in VARCHAR2
,P_ADDR_ATTRIBUTE7_O in VARCHAR2
,P_ADDR_ATTRIBUTE8_O in VARCHAR2
,P_ADDR_ATTRIBUTE9_O in VARCHAR2
,P_ADDR_ATTRIBUTE10_O in VARCHAR2
,P_ADDR_ATTRIBUTE11_O in VARCHAR2
,P_ADDR_ATTRIBUTE12_O in VARCHAR2
,P_ADDR_ATTRIBUTE13_O in VARCHAR2
,P_ADDR_ATTRIBUTE14_O in VARCHAR2
,P_ADDR_ATTRIBUTE15_O in VARCHAR2
,P_ADDR_ATTRIBUTE16_O in VARCHAR2
,P_ADDR_ATTRIBUTE17_O in VARCHAR2
,P_ADDR_ATTRIBUTE18_O in VARCHAR2
,P_ADDR_ATTRIBUTE19_O in VARCHAR2
,P_ADDR_ATTRIBUTE20_O in VARCHAR2
,P_ADD_INFORMATION13_O in VARCHAR2
,P_ADD_INFORMATION14_O in VARCHAR2
,P_ADD_INFORMATION15_O in VARCHAR2
,P_ADD_INFORMATION16_O in VARCHAR2
,P_ADD_INFORMATION17_O in VARCHAR2
,P_ADD_INFORMATION18_O in VARCHAR2
,P_ADD_INFORMATION19_O in VARCHAR2
,P_ADD_INFORMATION20_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_ADD_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_ADD_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_ADD_RKD;

/