--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_REPOSITORY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_REPOSITORY_BK1" as
/* $Header: pqvreapi.pkb 120.0 2005/05/29 02:18:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/10/10 13:38:24 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_VEHICLE_A
(P_EFFECTIVE_DATE in DATE
,P_REGISTRATION_NUMBER in VARCHAR2
,P_VEHICLE_TYPE in VARCHAR2
,P_VEHICLE_ID_NUMBER in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_MAKE in VARCHAR2
,P_ENGINE_CAPACITY_IN_CC in NUMBER
,P_FUEL_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_VEHICLE_STATUS in VARCHAR2
,P_VEHICLE_INACTIVITY_REASON in VARCHAR2
,P_MODEL in VARCHAR2
,P_INITIAL_REGISTRATION in DATE
,P_LAST_REGISTRATION_RENEW_DATE in DATE
,P_LIST_PRICE in NUMBER
,P_ACCESSORY_VALUE_AT_STARTDATE in NUMBER
,P_ACCESSORY_VALUE_ADDED_LATER in NUMBER
,P_MARKET_VALUE_CLASSIC_CAR in NUMBER
,P_FISCAL_RATINGS in NUMBER
,P_FISCAL_RATINGS_UOM in VARCHAR2
,P_VEHICLE_PROVIDER in VARCHAR2
,P_VEHICLE_OWNERSHIP in VARCHAR2
,P_SHARED_VEHICLE in VARCHAR2
,P_ASSET_NUMBER in VARCHAR2
,P_LEASE_CONTRACT_NUMBER in VARCHAR2
,P_LEASE_CONTRACT_EXPIRY_DATE in DATE
,P_TAXATION_METHOD in VARCHAR2
,P_FLEET_INFO in VARCHAR2
,P_FLEET_TRANSFER_DATE in DATE
,P_COLOR in VARCHAR2
,P_SEATING_CAPACITY in NUMBER
,P_WEIGHT in NUMBER
,P_WEIGHT_UOM in VARCHAR2
,P_MODEL_YEAR in NUMBER
,P_INSURANCE_NUMBER in VARCHAR2
,P_INSURANCE_EXPIRY_DATE in DATE
,P_COMMENTS in VARCHAR2
,P_VRE_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VRE_ATTRIBUTE1 in VARCHAR2
,P_VRE_ATTRIBUTE2 in VARCHAR2
,P_VRE_ATTRIBUTE3 in VARCHAR2
,P_VRE_ATTRIBUTE4 in VARCHAR2
,P_VRE_ATTRIBUTE5 in VARCHAR2
,P_VRE_ATTRIBUTE6 in VARCHAR2
,P_VRE_ATTRIBUTE7 in VARCHAR2
,P_VRE_ATTRIBUTE8 in VARCHAR2
,P_VRE_ATTRIBUTE9 in VARCHAR2
,P_VRE_ATTRIBUTE10 in VARCHAR2
,P_VRE_ATTRIBUTE11 in VARCHAR2
,P_VRE_ATTRIBUTE12 in VARCHAR2
,P_VRE_ATTRIBUTE13 in VARCHAR2
,P_VRE_ATTRIBUTE14 in VARCHAR2
,P_VRE_ATTRIBUTE15 in VARCHAR2
,P_VRE_ATTRIBUTE16 in VARCHAR2
,P_VRE_ATTRIBUTE17 in VARCHAR2
,P_VRE_ATTRIBUTE18 in VARCHAR2
,P_VRE_ATTRIBUTE19 in VARCHAR2
,P_VRE_ATTRIBUTE20 in VARCHAR2
,P_VRE_INFORMATION_CATEGORY in VARCHAR2
,P_VRE_INFORMATION1 in VARCHAR2
,P_VRE_INFORMATION2 in VARCHAR2
,P_VRE_INFORMATION3 in VARCHAR2
,P_VRE_INFORMATION4 in VARCHAR2
,P_VRE_INFORMATION5 in VARCHAR2
,P_VRE_INFORMATION6 in VARCHAR2
,P_VRE_INFORMATION7 in VARCHAR2
,P_VRE_INFORMATION8 in VARCHAR2
,P_VRE_INFORMATION9 in VARCHAR2
,P_VRE_INFORMATION10 in VARCHAR2
,P_VRE_INFORMATION11 in VARCHAR2
,P_VRE_INFORMATION12 in VARCHAR2
,P_VRE_INFORMATION13 in VARCHAR2
,P_VRE_INFORMATION14 in VARCHAR2
,P_VRE_INFORMATION15 in VARCHAR2
,P_VRE_INFORMATION16 in VARCHAR2
,P_VRE_INFORMATION17 in VARCHAR2
,P_VRE_INFORMATION18 in VARCHAR2
,P_VRE_INFORMATION19 in VARCHAR2
,P_VRE_INFORMATION20 in VARCHAR2
,P_VEHICLE_REPOSITORY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQP_VEHICLE_REPOSITORY_BK1.CREATE_VEHICLE_A', 10);
hr_utility.set_location(' Leaving: PQP_VEHICLE_REPOSITORY_BK1.CREATE_VEHICLE_A', 20);
end CREATE_VEHICLE_A;
procedure CREATE_VEHICLE_B
(P_EFFECTIVE_DATE in DATE
,P_REGISTRATION_NUMBER in VARCHAR2
,P_VEHICLE_TYPE in VARCHAR2
,P_VEHICLE_ID_NUMBER in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_MAKE in VARCHAR2
,P_ENGINE_CAPACITY_IN_CC in NUMBER
,P_FUEL_TYPE in VARCHAR2
,P_CURRENCY_CODE in VARCHAR2
,P_VEHICLE_STATUS in VARCHAR2
,P_VEHICLE_INACTIVITY_REASON in VARCHAR2
,P_MODEL in VARCHAR2
,P_INITIAL_REGISTRATION in DATE
,P_LAST_REGISTRATION_RENEW_DATE in DATE
,P_LIST_PRICE in NUMBER
,P_ACCESSORY_VALUE_AT_STARTDATE in NUMBER
,P_ACCESSORY_VALUE_ADDED_LATER in NUMBER
,P_MARKET_VALUE_CLASSIC_CAR in NUMBER
,P_FISCAL_RATINGS in NUMBER
,P_FISCAL_RATINGS_UOM in VARCHAR2
,P_VEHICLE_PROVIDER in VARCHAR2
,P_VEHICLE_OWNERSHIP in VARCHAR2
,P_SHARED_VEHICLE in VARCHAR2
,P_ASSET_NUMBER in VARCHAR2
,P_LEASE_CONTRACT_NUMBER in VARCHAR2
,P_LEASE_CONTRACT_EXPIRY_DATE in DATE
,P_TAXATION_METHOD in VARCHAR2
,P_FLEET_INFO in VARCHAR2
,P_FLEET_TRANSFER_DATE in DATE
,P_COLOR in VARCHAR2
,P_SEATING_CAPACITY in NUMBER
,P_WEIGHT in NUMBER
,P_WEIGHT_UOM in VARCHAR2
,P_MODEL_YEAR in NUMBER
,P_INSURANCE_NUMBER in VARCHAR2
,P_INSURANCE_EXPIRY_DATE in DATE
,P_COMMENTS in VARCHAR2
,P_VRE_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VRE_ATTRIBUTE1 in VARCHAR2
,P_VRE_ATTRIBUTE2 in VARCHAR2
,P_VRE_ATTRIBUTE3 in VARCHAR2
,P_VRE_ATTRIBUTE4 in VARCHAR2
,P_VRE_ATTRIBUTE5 in VARCHAR2
,P_VRE_ATTRIBUTE6 in VARCHAR2
,P_VRE_ATTRIBUTE7 in VARCHAR2
,P_VRE_ATTRIBUTE8 in VARCHAR2
,P_VRE_ATTRIBUTE9 in VARCHAR2
,P_VRE_ATTRIBUTE10 in VARCHAR2
,P_VRE_ATTRIBUTE11 in VARCHAR2
,P_VRE_ATTRIBUTE12 in VARCHAR2
,P_VRE_ATTRIBUTE13 in VARCHAR2
,P_VRE_ATTRIBUTE14 in VARCHAR2
,P_VRE_ATTRIBUTE15 in VARCHAR2
,P_VRE_ATTRIBUTE16 in VARCHAR2
,P_VRE_ATTRIBUTE17 in VARCHAR2
,P_VRE_ATTRIBUTE18 in VARCHAR2
,P_VRE_ATTRIBUTE19 in VARCHAR2
,P_VRE_ATTRIBUTE20 in VARCHAR2
,P_VRE_INFORMATION_CATEGORY in VARCHAR2
,P_VRE_INFORMATION1 in VARCHAR2
,P_VRE_INFORMATION2 in VARCHAR2
,P_VRE_INFORMATION3 in VARCHAR2
,P_VRE_INFORMATION4 in VARCHAR2
,P_VRE_INFORMATION5 in VARCHAR2
,P_VRE_INFORMATION6 in VARCHAR2
,P_VRE_INFORMATION7 in VARCHAR2
,P_VRE_INFORMATION8 in VARCHAR2
,P_VRE_INFORMATION9 in VARCHAR2
,P_VRE_INFORMATION10 in VARCHAR2
,P_VRE_INFORMATION11 in VARCHAR2
,P_VRE_INFORMATION12 in VARCHAR2
,P_VRE_INFORMATION13 in VARCHAR2
,P_VRE_INFORMATION14 in VARCHAR2
,P_VRE_INFORMATION15 in VARCHAR2
,P_VRE_INFORMATION16 in VARCHAR2
,P_VRE_INFORMATION17 in VARCHAR2
,P_VRE_INFORMATION18 in VARCHAR2
,P_VRE_INFORMATION19 in VARCHAR2
,P_VRE_INFORMATION20 in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PQP_VEHICLE_REPOSITORY_BK1.CREATE_VEHICLE_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := hr_api.return_legislation_code(p_business_group_id => P_BUSINESS_GROUP_ID);
if l_legislation_code = 'PL' then
PQP_PL_VEHICLE_REPOSITORY.CREATE_PL_VEHICLE
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_REGISTRATION_NUMBER => P_REGISTRATION_NUMBER
,P_VEHICLE_TYPE => P_VEHICLE_TYPE
,P_VEHICLE_ID_NUMBER => P_VEHICLE_ID_NUMBER
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_MAKE => P_MAKE
,P_ENGINE_CAPACITY_IN_CC => P_ENGINE_CAPACITY_IN_CC
,P_FUEL_TYPE => P_FUEL_TYPE
,P_CURRENCY_CODE => P_CURRENCY_CODE
,P_VEHICLE_STATUS => P_VEHICLE_STATUS
,P_VEHICLE_INACTIVITY_REASON => P_VEHICLE_INACTIVITY_REASON
,P_MODEL => P_MODEL
,P_INITIAL_REGISTRATION => P_INITIAL_REGISTRATION
,P_LAST_REGISTRATION_RENEW_DATE => P_LAST_REGISTRATION_RENEW_DATE
,P_LIST_PRICE => P_LIST_PRICE
,P_ACCESSORY_VALUE_AT_STARTDATE => P_ACCESSORY_VALUE_AT_STARTDATE
,P_ACCESSORY_VALUE_ADDED_LATER => P_ACCESSORY_VALUE_ADDED_LATER
,P_MARKET_VALUE_CLASSIC_CAR => P_MARKET_VALUE_CLASSIC_CAR
,P_FISCAL_RATINGS => P_FISCAL_RATINGS
,P_FISCAL_RATINGS_UOM => P_FISCAL_RATINGS_UOM
,P_VEHICLE_PROVIDER => P_VEHICLE_PROVIDER
,P_VEHICLE_OWNERSHIP => P_VEHICLE_OWNERSHIP
,P_SHARED_VEHICLE => P_SHARED_VEHICLE
,P_ASSET_NUMBER => P_ASSET_NUMBER
,P_LEASE_CONTRACT_NUMBER => P_LEASE_CONTRACT_NUMBER
,P_LEASE_CONTRACT_EXPIRY_DATE => P_LEASE_CONTRACT_EXPIRY_DATE
,P_TAXATION_METHOD => P_TAXATION_METHOD
,P_FLEET_INFO => P_FLEET_INFO
,P_FLEET_TRANSFER_DATE => P_FLEET_TRANSFER_DATE
,P_COLOR => P_COLOR
,P_SEATING_CAPACITY => P_SEATING_CAPACITY
,P_WEIGHT => P_WEIGHT
,P_WEIGHT_UOM => P_WEIGHT_UOM
,P_MODEL_YEAR => P_MODEL_YEAR
,P_INSURANCE_NUMBER => P_INSURANCE_NUMBER
,P_INSURANCE_EXPIRY_DATE => P_INSURANCE_EXPIRY_DATE
,P_COMMENTS => P_COMMENTS
,P_VRE_ATTRIBUTE_CATEGORY => P_VRE_ATTRIBUTE_CATEGORY
,P_VRE_INFORMATION_CATEGORY => P_VRE_INFORMATION_CATEGORY
,P_VRE_INFORMATION1 => P_VRE_INFORMATION1
,P_VRE_INFORMATION2 => P_VRE_INFORMATION2
,P_VRE_INFORMATION3 => P_VRE_INFORMATION3
,P_VRE_INFORMATION4 => P_VRE_INFORMATION4
,P_VRE_INFORMATION5 => P_VRE_INFORMATION5
,P_VRE_INFORMATION6 => P_VRE_INFORMATION6
,P_VRE_INFORMATION7 => P_VRE_INFORMATION7
,P_VRE_INFORMATION8 => P_VRE_INFORMATION8
,P_VRE_INFORMATION9 => P_VRE_INFORMATION9
,P_VRE_INFORMATION10 => P_VRE_INFORMATION10
,P_VRE_INFORMATION11 => P_VRE_INFORMATION11
,P_VRE_INFORMATION12 => P_VRE_INFORMATION12
,P_VRE_INFORMATION13 => P_VRE_INFORMATION13
,P_VRE_INFORMATION14 => P_VRE_INFORMATION14
,P_VRE_INFORMATION15 => P_VRE_INFORMATION15
,P_VRE_INFORMATION16 => P_VRE_INFORMATION16
,P_VRE_INFORMATION17 => P_VRE_INFORMATION17
,P_VRE_INFORMATION18 => P_VRE_INFORMATION18
,P_VRE_INFORMATION19 => P_VRE_INFORMATION19
,P_VRE_INFORMATION20 => P_VRE_INFORMATION20
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_VEHICLE', 'BP');
hr_utility.set_location(' Leaving: PQP_VEHICLE_REPOSITORY_BK1.CREATE_VEHICLE_B', 20);
end CREATE_VEHICLE_B;
end PQP_VEHICLE_REPOSITORY_BK1;

/
