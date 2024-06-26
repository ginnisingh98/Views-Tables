--------------------------------------------------------
--  DDL for Package Body OTA_ACTIVITY_VERSION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACTIVITY_VERSION_BK2" as
/* $Header: ottavapi.pkb 120.0.12010000.2 2009/08/11 13:13:11 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:59 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ACTIVITY_VERSION_A
(P_EFFECTIVE_DATE in DATE
,P_ACTIVITY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_SUPERSEDED_BY_ACT_VERSION_ID in NUMBER
,P_DEVELOPER_ORGANIZATION_ID in NUMBER
,P_CONTROLLING_PERSON_ID in NUMBER
,P_VERSION_NAME in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_DURATION in NUMBER
,P_DURATION_UNITS in VARCHAR2
,P_END_DATE in DATE
,P_INTENDED_AUDIENCE in VARCHAR2
,P_LANGUAGE_ID in NUMBER
,P_MAXIMUM_ATTENDEES in NUMBER
,P_MINIMUM_ATTENDEES in NUMBER
,P_OBJECTIVES in VARCHAR2
,P_START_DATE in DATE
,P_SUCCESS_CRITERIA in VARCHAR2
,P_USER_STATUS in VARCHAR2
,P_VENDOR_ID in NUMBER
,P_ACTUAL_COST in NUMBER
,P_BUDGET_COST in NUMBER
,P_BUDGET_CURRENCY_CODE in VARCHAR2
,P_EXPENSES_ALLOWED in VARCHAR2
,P_PROFESSIONAL_CREDIT_TYPE in VARCHAR2
,P_PROFESSIONAL_CREDITS in NUMBER
,P_MAXIMUM_INTERNAL_ATTENDEES in NUMBER
,P_TAV_INFORMATION_CATEGORY in VARCHAR2
,P_TAV_INFORMATION1 in VARCHAR2
,P_TAV_INFORMATION2 in VARCHAR2
,P_TAV_INFORMATION3 in VARCHAR2
,P_TAV_INFORMATION4 in VARCHAR2
,P_TAV_INFORMATION5 in VARCHAR2
,P_TAV_INFORMATION6 in VARCHAR2
,P_TAV_INFORMATION7 in VARCHAR2
,P_TAV_INFORMATION8 in VARCHAR2
,P_TAV_INFORMATION9 in VARCHAR2
,P_TAV_INFORMATION10 in VARCHAR2
,P_TAV_INFORMATION11 in VARCHAR2
,P_TAV_INFORMATION12 in VARCHAR2
,P_TAV_INFORMATION13 in VARCHAR2
,P_TAV_INFORMATION14 in VARCHAR2
,P_TAV_INFORMATION15 in VARCHAR2
,P_TAV_INFORMATION16 in VARCHAR2
,P_TAV_INFORMATION17 in VARCHAR2
,P_TAV_INFORMATION18 in VARCHAR2
,P_TAV_INFORMATION19 in VARCHAR2
,P_TAV_INFORMATION20 in VARCHAR2
,P_INVENTORY_ITEM_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_RCO_ID in NUMBER
,P_VERSION_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_DATA_SOURCE in VARCHAR2
,P_ACTIVITY_VERSION_ID in NUMBER
,P_COMPETENCY_UPDATE_LEVEL in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_ACTIVITY_VERSION_BK2.UPDATE_ACTIVITY_VERSION_A', 10);
hr_utility.set_location(' Leaving: OTA_ACTIVITY_VERSION_BK2.UPDATE_ACTIVITY_VERSION_A', 20);
end UPDATE_ACTIVITY_VERSION_A;
procedure UPDATE_ACTIVITY_VERSION_B
(P_EFFECTIVE_DATE in DATE
,P_ACTIVITY_ID in NUMBER
,P_SUPERSEDED_BY_ACT_VERSION_ID in NUMBER
,P_DEVELOPER_ORGANIZATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CONTROLLING_PERSON_ID in NUMBER
,P_VERSION_NAME in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_DURATION in NUMBER
,P_DURATION_UNITS in VARCHAR2
,P_END_DATE in DATE
,P_INTENDED_AUDIENCE in VARCHAR2
,P_LANGUAGE_ID in NUMBER
,P_MAXIMUM_ATTENDEES in NUMBER
,P_MINIMUM_ATTENDEES in NUMBER
,P_OBJECTIVES in VARCHAR2
,P_START_DATE in DATE
,P_SUCCESS_CRITERIA in VARCHAR2
,P_USER_STATUS in VARCHAR2
,P_VENDOR_ID in NUMBER
,P_ACTUAL_COST in NUMBER
,P_BUDGET_COST in NUMBER
,P_BUDGET_CURRENCY_CODE in VARCHAR2
,P_EXPENSES_ALLOWED in VARCHAR2
,P_PROFESSIONAL_CREDIT_TYPE in VARCHAR2
,P_PROFESSIONAL_CREDITS in NUMBER
,P_MAXIMUM_INTERNAL_ATTENDEES in NUMBER
,P_TAV_INFORMATION_CATEGORY in VARCHAR2
,P_TAV_INFORMATION1 in VARCHAR2
,P_TAV_INFORMATION2 in VARCHAR2
,P_TAV_INFORMATION3 in VARCHAR2
,P_TAV_INFORMATION4 in VARCHAR2
,P_TAV_INFORMATION5 in VARCHAR2
,P_TAV_INFORMATION6 in VARCHAR2
,P_TAV_INFORMATION7 in VARCHAR2
,P_TAV_INFORMATION8 in VARCHAR2
,P_TAV_INFORMATION9 in VARCHAR2
,P_TAV_INFORMATION10 in VARCHAR2
,P_TAV_INFORMATION11 in VARCHAR2
,P_TAV_INFORMATION12 in VARCHAR2
,P_TAV_INFORMATION13 in VARCHAR2
,P_TAV_INFORMATION14 in VARCHAR2
,P_TAV_INFORMATION15 in VARCHAR2
,P_TAV_INFORMATION16 in VARCHAR2
,P_TAV_INFORMATION17 in VARCHAR2
,P_TAV_INFORMATION18 in VARCHAR2
,P_TAV_INFORMATION19 in VARCHAR2
,P_TAV_INFORMATION20 in VARCHAR2
,P_INVENTORY_ITEM_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_RCO_ID in NUMBER
,P_VERSION_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_DATA_SOURCE in VARCHAR2
,P_ACTIVITY_VERSION_ID in NUMBER
,P_COMPETENCY_UPDATE_LEVEL in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_ACTIVITY_VERSION_BK2.UPDATE_ACTIVITY_VERSION_B', 10);
hr_utility.set_location(' Leaving: OTA_ACTIVITY_VERSION_BK2.UPDATE_ACTIVITY_VERSION_B', 20);
end UPDATE_ACTIVITY_VERSION_B;
end OTA_ACTIVITY_VERSION_BK2;

/
