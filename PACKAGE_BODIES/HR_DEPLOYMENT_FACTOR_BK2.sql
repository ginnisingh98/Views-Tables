--------------------------------------------------------
--  DDL for Package Body HR_DEPLOYMENT_FACTOR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DEPLOYMENT_FACTOR_BK2" as
/* $Header: pedpfapi.pkb 115.6 2004/01/29 07:04:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:58 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PERSON_DPMT_FACTOR_A
(P_EFFECTIVE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_WORK_ANY_COUNTRY in VARCHAR2
,P_WORK_ANY_LOCATION in VARCHAR2
,P_RELOCATE_DOMESTICALLY in VARCHAR2
,P_RELOCATE_INTERNATIONALLY in VARCHAR2
,P_TRAVEL_REQUIRED in VARCHAR2
,P_COUNTRY1 in VARCHAR2
,P_COUNTRY2 in VARCHAR2
,P_COUNTRY3 in VARCHAR2
,P_WORK_DURATION in VARCHAR2
,P_WORK_SCHEDULE in VARCHAR2
,P_WORK_HOURS in VARCHAR2
,P_FTE_CAPACITY in VARCHAR2
,P_VISIT_INTERNATIONALLY in VARCHAR2
,P_ONLY_CURRENT_LOCATION in VARCHAR2
,P_NO_COUNTRY1 in VARCHAR2
,P_NO_COUNTRY2 in VARCHAR2
,P_NO_COUNTRY3 in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_EARLIEST_AVAILABLE_DATE in DATE
,P_AVAILABLE_FOR_TRANSFER in VARCHAR2
,P_RELOCATION_PREFERENCE in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
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
,P_DEPLOYMENT_FACTOR_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_DEPLOYMENT_FACTOR_BK2.UPDATE_PERSON_DPMT_FACTOR_A', 10);
hr_utility.set_location(' Leaving: HR_DEPLOYMENT_FACTOR_BK2.UPDATE_PERSON_DPMT_FACTOR_A', 20);
end UPDATE_PERSON_DPMT_FACTOR_A;
procedure UPDATE_PERSON_DPMT_FACTOR_B
(P_EFFECTIVE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_WORK_ANY_COUNTRY in VARCHAR2
,P_WORK_ANY_LOCATION in VARCHAR2
,P_RELOCATE_DOMESTICALLY in VARCHAR2
,P_RELOCATE_INTERNATIONALLY in VARCHAR2
,P_TRAVEL_REQUIRED in VARCHAR2
,P_COUNTRY1 in VARCHAR2
,P_COUNTRY2 in VARCHAR2
,P_COUNTRY3 in VARCHAR2
,P_WORK_DURATION in VARCHAR2
,P_WORK_SCHEDULE in VARCHAR2
,P_WORK_HOURS in VARCHAR2
,P_FTE_CAPACITY in VARCHAR2
,P_VISIT_INTERNATIONALLY in VARCHAR2
,P_ONLY_CURRENT_LOCATION in VARCHAR2
,P_NO_COUNTRY1 in VARCHAR2
,P_NO_COUNTRY2 in VARCHAR2
,P_NO_COUNTRY3 in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_EARLIEST_AVAILABLE_DATE in DATE
,P_AVAILABLE_FOR_TRANSFER in VARCHAR2
,P_RELOCATION_PREFERENCE in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
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
,P_DEPLOYMENT_FACTOR_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_DEPLOYMENT_FACTOR_BK2.UPDATE_PERSON_DPMT_FACTOR_B', 10);
hr_utility.set_location(' Leaving: HR_DEPLOYMENT_FACTOR_BK2.UPDATE_PERSON_DPMT_FACTOR_B', 20);
end UPDATE_PERSON_DPMT_FACTOR_B;
end HR_DEPLOYMENT_FACTOR_BK2;

/
