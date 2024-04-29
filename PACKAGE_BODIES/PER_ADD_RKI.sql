--------------------------------------------------------
--  DDL for Package Body PER_ADD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_RKI" as
/* $Header: peaddrhi.pkb 120.1.12010000.3 2008/08/06 08:53:04 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:02:21 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ADDRESS_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_DATE_FROM in DATE
,P_PRIMARY_FLAG in VARCHAR2
,P_STYLE in VARCHAR2
,P_ADDRESS_LINE1 in VARCHAR2
,P_ADDRESS_LINE2 in VARCHAR2
,P_ADDRESS_LINE3 in VARCHAR2
,P_ADDRESS_TYPE in VARCHAR2
,P_COMMENTS in LONG
,P_COUNTRY in VARCHAR2
,P_DATE_TO in DATE
,P_POSTAL_CODE in VARCHAR2
,P_REGION_1 in VARCHAR2
,P_REGION_2 in VARCHAR2
,P_REGION_3 in VARCHAR2
,P_TELEPHONE_NUMBER_1 in VARCHAR2
,P_TELEPHONE_NUMBER_2 in VARCHAR2
,P_TELEPHONE_NUMBER_3 in VARCHAR2
,P_TOWN_OR_CITY in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_ADDR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ADDR_ATTRIBUTE1 in VARCHAR2
,P_ADDR_ATTRIBUTE2 in VARCHAR2
,P_ADDR_ATTRIBUTE3 in VARCHAR2
,P_ADDR_ATTRIBUTE4 in VARCHAR2
,P_ADDR_ATTRIBUTE5 in VARCHAR2
,P_ADDR_ATTRIBUTE6 in VARCHAR2
,P_ADDR_ATTRIBUTE7 in VARCHAR2
,P_ADDR_ATTRIBUTE8 in VARCHAR2
,P_ADDR_ATTRIBUTE9 in VARCHAR2
,P_ADDR_ATTRIBUTE10 in VARCHAR2
,P_ADDR_ATTRIBUTE11 in VARCHAR2
,P_ADDR_ATTRIBUTE12 in VARCHAR2
,P_ADDR_ATTRIBUTE13 in VARCHAR2
,P_ADDR_ATTRIBUTE14 in VARCHAR2
,P_ADDR_ATTRIBUTE15 in VARCHAR2
,P_ADDR_ATTRIBUTE16 in VARCHAR2
,P_ADDR_ATTRIBUTE17 in VARCHAR2
,P_ADDR_ATTRIBUTE18 in VARCHAR2
,P_ADDR_ATTRIBUTE19 in VARCHAR2
,P_ADDR_ATTRIBUTE20 in VARCHAR2
,P_ADD_INFORMATION13 in VARCHAR2
,P_ADD_INFORMATION14 in VARCHAR2
,P_ADD_INFORMATION15 in VARCHAR2
,P_ADD_INFORMATION16 in VARCHAR2
,P_ADD_INFORMATION17 in VARCHAR2
,P_ADD_INFORMATION18 in VARCHAR2
,P_ADD_INFORMATION19 in VARCHAR2
,P_ADD_INFORMATION20 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATE_COUNTY in BOOLEAN
,P_PARTY_ID in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PER_ADD_RKI.AFTER_INSERT', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := hr_api.return_legislation_code(p_business_group_id => P_BUSINESS_GROUP_ID);
if l_legislation_code = 'IN' then
PER_IN_ADD_LEG_HOOK.CHECK_PER_ADDRESS_INS
(P_STYLE => P_STYLE
,P_ADDRESS_ID => P_ADDRESS_ID
,P_ADD_INFORMATION14 => P_ADD_INFORMATION14
,P_ADD_INFORMATION15 => P_ADD_INFORMATION15
,P_POSTAL_CODE => P_POSTAL_CODE
);
elsif l_legislation_code = 'KR' then
PER_KR_ADDRESS_UPDATE_HOOK_PKG.UPDATE_ADDRESS_LINE1_AI
(P_ADDRESS_ID => P_ADDRESS_ID
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_PERSON_ID => P_PERSON_ID
,P_STYLE => P_STYLE
,P_ADD_INFORMATION17 => P_ADD_INFORMATION17
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PER_ADDRESSES', 'AI');
hr_utility.set_location(' Leaving: PER_ADD_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_ADD_RKI;

/
