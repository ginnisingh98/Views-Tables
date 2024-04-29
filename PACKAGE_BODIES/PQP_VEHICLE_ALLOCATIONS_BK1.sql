--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_ALLOCATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_ALLOCATIONS_BK1" as
/* $Header: pqvalapi.pkb 120.0.12010000.2 2008/08/08 07:21:04 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:37:24 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_VEHICLE_ALLOCATION_A
(P_EFFECTIVE_DATE in DATE
,P_ASSIGNMENT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_VEHICLE_REPOSITORY_ID in NUMBER
,P_ACROSS_ASSIGNMENTS in VARCHAR2
,P_USAGE_TYPE in VARCHAR2
,P_CAPITAL_CONTRIBUTION in NUMBER
,P_PRIVATE_CONTRIBUTION in NUMBER
,P_DEFAULT_VEHICLE in VARCHAR2
,P_FUEL_CARD in VARCHAR2
,P_FUEL_CARD_NUMBER in VARCHAR2
,P_CALCULATION_METHOD in VARCHAR2
,P_RATES_TABLE_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_PRIVATE_USE_FLAG in VARCHAR2
,P_INSURANCE_NUMBER in VARCHAR2
,P_INSURANCE_EXPIRY_DATE in DATE
,P_VAL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VAL_ATTRIBUTE1 in VARCHAR2
,P_VAL_ATTRIBUTE2 in VARCHAR2
,P_VAL_ATTRIBUTE3 in VARCHAR2
,P_VAL_ATTRIBUTE4 in VARCHAR2
,P_VAL_ATTRIBUTE5 in VARCHAR2
,P_VAL_ATTRIBUTE6 in VARCHAR2
,P_VAL_ATTRIBUTE7 in VARCHAR2
,P_VAL_ATTRIBUTE8 in VARCHAR2
,P_VAL_ATTRIBUTE9 in VARCHAR2
,P_VAL_ATTRIBUTE10 in VARCHAR2
,P_VAL_ATTRIBUTE11 in VARCHAR2
,P_VAL_ATTRIBUTE12 in VARCHAR2
,P_VAL_ATTRIBUTE13 in VARCHAR2
,P_VAL_ATTRIBUTE14 in VARCHAR2
,P_VAL_ATTRIBUTE15 in VARCHAR2
,P_VAL_ATTRIBUTE16 in VARCHAR2
,P_VAL_ATTRIBUTE17 in VARCHAR2
,P_VAL_ATTRIBUTE18 in VARCHAR2
,P_VAL_ATTRIBUTE19 in VARCHAR2
,P_VAL_ATTRIBUTE20 in VARCHAR2
,P_VAL_INFORMATION_CATEGORY in VARCHAR2
,P_VAL_INFORMATION1 in VARCHAR2
,P_VAL_INFORMATION2 in VARCHAR2
,P_VAL_INFORMATION3 in VARCHAR2
,P_VAL_INFORMATION4 in VARCHAR2
,P_VAL_INFORMATION5 in VARCHAR2
,P_VAL_INFORMATION6 in VARCHAR2
,P_VAL_INFORMATION7 in VARCHAR2
,P_VAL_INFORMATION8 in VARCHAR2
,P_VAL_INFORMATION9 in VARCHAR2
,P_VAL_INFORMATION10 in VARCHAR2
,P_VAL_INFORMATION11 in VARCHAR2
,P_VAL_INFORMATION12 in VARCHAR2
,P_VAL_INFORMATION13 in VARCHAR2
,P_VAL_INFORMATION14 in VARCHAR2
,P_VAL_INFORMATION15 in VARCHAR2
,P_VAL_INFORMATION16 in VARCHAR2
,P_VAL_INFORMATION17 in VARCHAR2
,P_VAL_INFORMATION18 in VARCHAR2
,P_VAL_INFORMATION19 in VARCHAR2
,P_VAL_INFORMATION20 in VARCHAR2
,P_FUEL_BENEFIT in VARCHAR2
,P_SLIDING_RATES_INFO in VARCHAR2
,P_VEHICLE_ALLOCATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQP_VEHICLE_ALLOCATIONS_BK1.CREATE_VEHICLE_ALLOCATION_A', 10);
hr_utility.set_location(' Leaving: PQP_VEHICLE_ALLOCATIONS_BK1.CREATE_VEHICLE_ALLOCATION_A', 20);
end CREATE_VEHICLE_ALLOCATION_A;
procedure CREATE_VEHICLE_ALLOCATION_B
(P_EFFECTIVE_DATE in DATE
,P_ASSIGNMENT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_VEHICLE_REPOSITORY_ID in NUMBER
,P_ACROSS_ASSIGNMENTS in VARCHAR2
,P_USAGE_TYPE in VARCHAR2
,P_CAPITAL_CONTRIBUTION in NUMBER
,P_PRIVATE_CONTRIBUTION in NUMBER
,P_DEFAULT_VEHICLE in VARCHAR2
,P_FUEL_CARD in VARCHAR2
,P_FUEL_CARD_NUMBER in VARCHAR2
,P_CALCULATION_METHOD in VARCHAR2
,P_RATES_TABLE_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_PRIVATE_USE_FLAG in VARCHAR2
,P_INSURANCE_NUMBER in VARCHAR2
,P_INSURANCE_EXPIRY_DATE in DATE
,P_VAL_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VAL_ATTRIBUTE1 in VARCHAR2
,P_VAL_ATTRIBUTE2 in VARCHAR2
,P_VAL_ATTRIBUTE3 in VARCHAR2
,P_VAL_ATTRIBUTE4 in VARCHAR2
,P_VAL_ATTRIBUTE5 in VARCHAR2
,P_VAL_ATTRIBUTE6 in VARCHAR2
,P_VAL_ATTRIBUTE7 in VARCHAR2
,P_VAL_ATTRIBUTE8 in VARCHAR2
,P_VAL_ATTRIBUTE9 in VARCHAR2
,P_VAL_ATTRIBUTE10 in VARCHAR2
,P_VAL_ATTRIBUTE11 in VARCHAR2
,P_VAL_ATTRIBUTE12 in VARCHAR2
,P_VAL_ATTRIBUTE13 in VARCHAR2
,P_VAL_ATTRIBUTE14 in VARCHAR2
,P_VAL_ATTRIBUTE15 in VARCHAR2
,P_VAL_ATTRIBUTE16 in VARCHAR2
,P_VAL_ATTRIBUTE17 in VARCHAR2
,P_VAL_ATTRIBUTE18 in VARCHAR2
,P_VAL_ATTRIBUTE19 in VARCHAR2
,P_VAL_ATTRIBUTE20 in VARCHAR2
,P_VAL_INFORMATION_CATEGORY in VARCHAR2
,P_VAL_INFORMATION1 in VARCHAR2
,P_VAL_INFORMATION2 in VARCHAR2
,P_VAL_INFORMATION3 in VARCHAR2
,P_VAL_INFORMATION4 in VARCHAR2
,P_VAL_INFORMATION5 in VARCHAR2
,P_VAL_INFORMATION6 in VARCHAR2
,P_VAL_INFORMATION7 in VARCHAR2
,P_VAL_INFORMATION8 in VARCHAR2
,P_VAL_INFORMATION9 in VARCHAR2
,P_VAL_INFORMATION10 in VARCHAR2
,P_VAL_INFORMATION11 in VARCHAR2
,P_VAL_INFORMATION12 in VARCHAR2
,P_VAL_INFORMATION13 in VARCHAR2
,P_VAL_INFORMATION14 in VARCHAR2
,P_VAL_INFORMATION15 in VARCHAR2
,P_VAL_INFORMATION16 in VARCHAR2
,P_VAL_INFORMATION17 in VARCHAR2
,P_VAL_INFORMATION18 in VARCHAR2
,P_VAL_INFORMATION19 in VARCHAR2
,P_VAL_INFORMATION20 in VARCHAR2
,P_FUEL_BENEFIT in VARCHAR2
,P_SLIDING_RATES_INFO in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PQP_VEHICLE_ALLOCATIONS_BK1.CREATE_VEHICLE_ALLOCATION_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := hr_api.return_legislation_code(p_business_group_id => P_BUSINESS_GROUP_ID);
if l_legislation_code = 'GB' then
PQP_GB_VEHICLE_ALLOCATIONS.CREATE_GB_VEHICLE_ALLOCATION
(P_USAGE_TYPE => P_USAGE_TYPE
,P_VEHICLE_REPOSITORY_ID => P_VEHICLE_REPOSITORY_ID
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
);
elsif l_legislation_code = 'PL' then
PQP_PL_VEHICLE_ALLOCATIONS.CREATE_PL_VEHICLE_ALLOCATION
(P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_VEHICLE_REPOSITORY_ID => P_VEHICLE_REPOSITORY_ID
,P_VAL_INFORMATION_CATEGORY => P_VAL_INFORMATION_CATEGORY
,P_VAL_INFORMATION1 => P_VAL_INFORMATION1
,P_VAL_INFORMATION2 => P_VAL_INFORMATION2
,P_VAL_INFORMATION3 => P_VAL_INFORMATION3
,P_VAL_INFORMATION4 => P_VAL_INFORMATION4
,P_VAL_INFORMATION5 => P_VAL_INFORMATION5
,P_VAL_INFORMATION6 => P_VAL_INFORMATION6
,P_VAL_INFORMATION7 => P_VAL_INFORMATION7
,P_VAL_INFORMATION8 => P_VAL_INFORMATION8
,P_VAL_INFORMATION9 => P_VAL_INFORMATION9
,P_VAL_INFORMATION10 => P_VAL_INFORMATION10
,P_VAL_INFORMATION11 => P_VAL_INFORMATION11
,P_VAL_INFORMATION12 => P_VAL_INFORMATION12
,P_VAL_INFORMATION13 => P_VAL_INFORMATION13
,P_VAL_INFORMATION14 => P_VAL_INFORMATION14
,P_VAL_INFORMATION15 => P_VAL_INFORMATION15
,P_VAL_INFORMATION16 => P_VAL_INFORMATION16
,P_VAL_INFORMATION17 => P_VAL_INFORMATION17
,P_VAL_INFORMATION18 => P_VAL_INFORMATION18
,P_VAL_INFORMATION19 => P_VAL_INFORMATION19
,P_VAL_INFORMATION20 => P_VAL_INFORMATION20
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_VEHICLE_ALLOCATION', 'BP');
hr_utility.set_location(' Leaving: PQP_VEHICLE_ALLOCATIONS_BK1.CREATE_VEHICLE_ALLOCATION_B', 20);
end CREATE_VEHICLE_ALLOCATION_B;
end PQP_VEHICLE_ALLOCATIONS_BK1;

/
