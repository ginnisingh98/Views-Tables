--------------------------------------------------------
--  DDL for Package Body PQP_VAL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VAL_RKD" as
/* $Header: pqvalrhi.pkb 120.0.12010000.3 2008/08/08 07:22:41 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_VEHICLE_ALLOCATION_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ASSIGNMENT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ACROSS_ASSIGNMENTS_O in VARCHAR2
,P_VEHICLE_REPOSITORY_ID_O in NUMBER
,P_USAGE_TYPE_O in VARCHAR2
,P_CAPITAL_CONTRIBUTION_O in NUMBER
,P_PRIVATE_CONTRIBUTION_O in NUMBER
,P_DEFAULT_VEHICLE_O in VARCHAR2
,P_FUEL_CARD_O in VARCHAR2
,P_FUEL_CARD_NUMBER_O in VARCHAR2
,P_CALCULATION_METHOD_O in VARCHAR2
,P_RATES_TABLE_ID_O in NUMBER
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_PRIVATE_USE_FLAG_O in VARCHAR2
,P_INSURANCE_NUMBER_O in VARCHAR2
,P_INSURANCE_EXPIRY_DATE_O in DATE
,P_VAL_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_VAL_ATTRIBUTE1_O in VARCHAR2
,P_VAL_ATTRIBUTE2_O in VARCHAR2
,P_VAL_ATTRIBUTE3_O in VARCHAR2
,P_VAL_ATTRIBUTE4_O in VARCHAR2
,P_VAL_ATTRIBUTE5_O in VARCHAR2
,P_VAL_ATTRIBUTE6_O in VARCHAR2
,P_VAL_ATTRIBUTE7_O in VARCHAR2
,P_VAL_ATTRIBUTE8_O in VARCHAR2
,P_VAL_ATTRIBUTE9_O in VARCHAR2
,P_VAL_ATTRIBUTE10_O in VARCHAR2
,P_VAL_ATTRIBUTE11_O in VARCHAR2
,P_VAL_ATTRIBUTE12_O in VARCHAR2
,P_VAL_ATTRIBUTE13_O in VARCHAR2
,P_VAL_ATTRIBUTE14_O in VARCHAR2
,P_VAL_ATTRIBUTE15_O in VARCHAR2
,P_VAL_ATTRIBUTE16_O in VARCHAR2
,P_VAL_ATTRIBUTE17_O in VARCHAR2
,P_VAL_ATTRIBUTE18_O in VARCHAR2
,P_VAL_ATTRIBUTE19_O in VARCHAR2
,P_VAL_ATTRIBUTE20_O in VARCHAR2
,P_VAL_INFORMATION_CATEGORY_O in VARCHAR2
,P_VAL_INFORMATION1_O in VARCHAR2
,P_VAL_INFORMATION2_O in VARCHAR2
,P_VAL_INFORMATION3_O in VARCHAR2
,P_VAL_INFORMATION4_O in VARCHAR2
,P_VAL_INFORMATION5_O in VARCHAR2
,P_VAL_INFORMATION6_O in VARCHAR2
,P_VAL_INFORMATION7_O in VARCHAR2
,P_VAL_INFORMATION8_O in VARCHAR2
,P_VAL_INFORMATION9_O in VARCHAR2
,P_VAL_INFORMATION10_O in VARCHAR2
,P_VAL_INFORMATION11_O in VARCHAR2
,P_VAL_INFORMATION12_O in VARCHAR2
,P_VAL_INFORMATION13_O in VARCHAR2
,P_VAL_INFORMATION14_O in VARCHAR2
,P_VAL_INFORMATION15_O in VARCHAR2
,P_VAL_INFORMATION16_O in VARCHAR2
,P_VAL_INFORMATION17_O in VARCHAR2
,P_VAL_INFORMATION18_O in VARCHAR2
,P_VAL_INFORMATION19_O in VARCHAR2
,P_VAL_INFORMATION20_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FUEL_BENEFIT_O in VARCHAR2
,P_SLIDING_RATES_INFO_O in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PQP_VAL_RKD.AFTER_DELETE', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := HR_API.RETURN_LEGISLATION_CODE(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID_O
);
if l_legislation_code = 'IE' then
PAY_IE_BIK_CHECK.CHECK_BIK_ENTRY
(P_ASSIGNMENT_ID_O => P_ASSIGNMENT_ID_O
,P_VEHICLE_ALLOCATION_ID => P_VEHICLE_ALLOCATION_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DATETRACK_MODE => P_DATETRACK_MODE
,P_VALIDATION_START_DATE => P_VALIDATION_START_DATE
,P_VALIDATION_END_DATE => P_VALIDATION_END_DATE
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PQP_VEHICLE_ALLOCATIONS_F', 'AD');
hr_utility.set_location(' Leaving: PQP_VAL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQP_VAL_RKD;

/
