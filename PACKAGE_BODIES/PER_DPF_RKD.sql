--------------------------------------------------------
--  DDL for Package Body PER_DPF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DPF_RKD" as
/* $Header: pedpfrhi.pkb 115.13 2002/12/05 10:20:52 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:58 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_DEPLOYMENT_FACTOR_ID in NUMBER
,P_POSITION_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_JOB_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_WORK_ANY_COUNTRY_O in VARCHAR2
,P_WORK_ANY_LOCATION_O in VARCHAR2
,P_RELOCATE_DOMESTICALLY_O in VARCHAR2
,P_RELOCATE_INTERNATIONALLY_O in VARCHAR2
,P_TRAVEL_REQUIRED_O in VARCHAR2
,P_COUNTRY1_O in VARCHAR2
,P_COUNTRY2_O in VARCHAR2
,P_COUNTRY3_O in VARCHAR2
,P_WORK_DURATION_O in VARCHAR2
,P_WORK_SCHEDULE_O in VARCHAR2
,P_WORK_HOURS_O in VARCHAR2
,P_FTE_CAPACITY_O in VARCHAR2
,P_VISIT_INTERNATIONALLY_O in VARCHAR2
,P_ONLY_CURRENT_LOCATION_O in VARCHAR2
,P_NO_COUNTRY1_O in VARCHAR2
,P_NO_COUNTRY2_O in VARCHAR2
,P_NO_COUNTRY3_O in VARCHAR2
,P_COMMENTS_O in VARCHAR2
,P_EARLIEST_AVAILABLE_DATE_O in DATE
,P_AVAILABLE_FOR_TRANSFER_O in VARCHAR2
,P_RELOCATION_PREFERENCE_O in VARCHAR2
,P_RELOCATION_REQUIRED_O in VARCHAR2
,P_PASSPORT_REQUIRED_O in VARCHAR2
,P_LOCATION1_O in VARCHAR2
,P_LOCATION2_O in VARCHAR2
,P_LOCATION3_O in VARCHAR2
,P_OTHER_REQUIREMENTS_O in VARCHAR2
,P_SERVICE_MINIMUM_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ATTRIBUTE1_O in VARCHAR2
,P_ATTRIBUTE2_O in VARCHAR2
,P_ATTRIBUTE3_O in VARCHAR2
,P_ATTRIBUTE4_O in VARCHAR2
,P_ATTRIBUTE5_O in VARCHAR2
,P_ATTRIBUTE6_O in VARCHAR2
,P_ATTRIBUTE7_O in VARCHAR2
,P_ATTRIBUTE8_O in VARCHAR2
,P_ATTRIBUTE9_O in VARCHAR2
,P_ATTRIBUTE10_O in VARCHAR2
,P_ATTRIBUTE11_O in VARCHAR2
,P_ATTRIBUTE12_O in VARCHAR2
,P_ATTRIBUTE13_O in VARCHAR2
,P_ATTRIBUTE14_O in VARCHAR2
,P_ATTRIBUTE15_O in VARCHAR2
,P_ATTRIBUTE16_O in VARCHAR2
,P_ATTRIBUTE17_O in VARCHAR2
,P_ATTRIBUTE18_O in VARCHAR2
,P_ATTRIBUTE19_O in VARCHAR2
,P_ATTRIBUTE20_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_DPF_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_DPF_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_DPF_RKD;

/