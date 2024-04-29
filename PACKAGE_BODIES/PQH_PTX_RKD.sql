--------------------------------------------------------
--  DDL for Package Body PQH_PTX_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_RKD" as
/* $Header: pqptxrhi.pkb 120.0.12010000.2 2008/08/05 13:41:09 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_POSITION_TRANSACTION_ID in NUMBER
,P_ACTION_DATE_O in DATE
,P_POSITION_ID_O in NUMBER
,P_AVAILABILITY_STATUS_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ENTRY_STEP_ID_O in NUMBER
,P_ENTRY_GRADE_RULE_ID_O in NUMBER
,P_JOB_ID_O in NUMBER
,P_LOCATION_ID_O in NUMBER
,P_ORGANIZATION_ID_O in NUMBER
,P_PAY_FREQ_PAYROLL_ID_O in NUMBER
,P_POSITION_DEFINITION_ID_O in NUMBER
,P_PRIOR_POSITION_ID_O in NUMBER
,P_RELIEF_POSITION_ID_O in NUMBER
,P_ENTRY_GRADE_ID_O in NUMBER
,P_SUCCESSOR_POSITION_ID_O in NUMBER
,P_SUPERVISOR_POSITION_ID_O in NUMBER
,P_AMENDMENT_DATE_O in DATE
,P_AMENDMENT_RECOMMENDATION_O in VARCHAR2
,P_AMENDMENT_REF_NUMBER_O in VARCHAR2
,P_AVAIL_STATUS_PROP_END_DATE_O in DATE
,P_BARGAINING_UNIT_CD_O in VARCHAR2
,P_COMMENTS_O in LONG
,P_COUNTRY1_O in VARCHAR2
,P_COUNTRY2_O in VARCHAR2
,P_COUNTRY3_O in VARCHAR2
,P_CURRENT_JOB_PROP_END_DATE_O in DATE
,P_CURRENT_ORG_PROP_END_DATE_O in DATE
,P_DATE_EFFECTIVE_O in DATE
,P_DATE_END_O in DATE
,P_EARLIEST_HIRE_DATE_O in DATE
,P_FILL_BY_DATE_O in DATE
,P_FREQUENCY_O in VARCHAR2
,P_FTE_O in NUMBER
,P_FTE_CAPACITY_O in VARCHAR2
,P_LOCATION1_O in VARCHAR2
,P_LOCATION2_O in VARCHAR2
,P_LOCATION3_O in VARCHAR2
,P_MAX_PERSONS_O in NUMBER
,P_NAME_O in VARCHAR2
,P_OTHER_REQUIREMENTS_O in VARCHAR2
,P_OVERLAP_PERIOD_O in NUMBER
,P_OVERLAP_UNIT_CD_O in VARCHAR2
,P_PASSPORT_REQUIRED_O in VARCHAR2
,P_PAY_TERM_END_DAY_CD_O in VARCHAR2
,P_PAY_TERM_END_MONTH_CD_O in VARCHAR2
,P_PERMANENT_TEMPORARY_FLAG_O in VARCHAR2
,P_PERMIT_RECRUITMENT_FLAG_O in VARCHAR2
,P_POSITION_TYPE_O in VARCHAR2
,P_POSTING_DESCRIPTION_O in VARCHAR2
,P_PROBATION_PERIOD_O in NUMBER
,P_PROBATION_PERIOD_UNIT_CD_O in VARCHAR2
,P_RELOCATE_DOMESTICALLY_O in VARCHAR2
,P_RELOCATE_INTERNATIONALLY_O in VARCHAR2
,P_REPLACEMENT_REQUIRED_FLAG_O in VARCHAR2
,P_REVIEW_FLAG_O in VARCHAR2
,P_SEASONAL_FLAG_O in VARCHAR2
,P_SECURITY_REQUIREMENTS_O in VARCHAR2
,P_SERVICE_MINIMUM_O in VARCHAR2
,P_TERM_START_DAY_CD_O in VARCHAR2
,P_TERM_START_MONTH_CD_O in VARCHAR2
,P_TIME_NORMAL_FINISH_O in VARCHAR2
,P_TIME_NORMAL_START_O in VARCHAR2
,P_TRANSACTION_STATUS_O in VARCHAR2
,P_TRAVEL_REQUIRED_O in VARCHAR2
,P_WORKING_HOURS_O in NUMBER
,P_WORKS_COUNCIL_APPROVAL_FLA_O in VARCHAR2
,P_WORK_ANY_COUNTRY_O in VARCHAR2
,P_WORK_ANY_LOCATION_O in VARCHAR2
,P_WORK_PERIOD_TYPE_CD_O in VARCHAR2
,P_WORK_SCHEDULE_O in VARCHAR2
,P_WORK_DURATION_O in VARCHAR2
,P_WORK_TERM_END_DAY_CD_O in VARCHAR2
,P_WORK_TERM_END_MONTH_CD_O in VARCHAR2
,P_PROPOSED_FTE_FOR_LAYOFF_O in NUMBER
,P_PROPOSED_DATE_FOR_LAYOFF_O in DATE
,P_INFORMATION1_O in VARCHAR2
,P_INFORMATION2_O in VARCHAR2
,P_INFORMATION3_O in VARCHAR2
,P_INFORMATION4_O in VARCHAR2
,P_INFORMATION5_O in VARCHAR2
,P_INFORMATION6_O in VARCHAR2
,P_INFORMATION7_O in VARCHAR2
,P_INFORMATION8_O in VARCHAR2
,P_INFORMATION9_O in VARCHAR2
,P_INFORMATION10_O in VARCHAR2
,P_INFORMATION11_O in VARCHAR2
,P_INFORMATION12_O in VARCHAR2
,P_INFORMATION13_O in VARCHAR2
,P_INFORMATION14_O in VARCHAR2
,P_INFORMATION15_O in VARCHAR2
,P_INFORMATION16_O in VARCHAR2
,P_INFORMATION17_O in VARCHAR2
,P_INFORMATION18_O in VARCHAR2
,P_INFORMATION19_O in VARCHAR2
,P_INFORMATION20_O in VARCHAR2
,P_INFORMATION21_O in VARCHAR2
,P_INFORMATION22_O in VARCHAR2
,P_INFORMATION23_O in VARCHAR2
,P_INFORMATION24_O in VARCHAR2
,P_INFORMATION25_O in VARCHAR2
,P_INFORMATION26_O in VARCHAR2
,P_INFORMATION27_O in VARCHAR2
,P_INFORMATION28_O in VARCHAR2
,P_INFORMATION29_O in VARCHAR2
,P_INFORMATION30_O in VARCHAR2
,P_INFORMATION_CATEGORY_O in VARCHAR2
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
,P_ATTRIBUTE21_O in VARCHAR2
,P_ATTRIBUTE22_O in VARCHAR2
,P_ATTRIBUTE23_O in VARCHAR2
,P_ATTRIBUTE24_O in VARCHAR2
,P_ATTRIBUTE25_O in VARCHAR2
,P_ATTRIBUTE26_O in VARCHAR2
,P_ATTRIBUTE27_O in VARCHAR2
,P_ATTRIBUTE28_O in VARCHAR2
,P_ATTRIBUTE29_O in VARCHAR2
,P_ATTRIBUTE30_O in VARCHAR2
,P_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PAY_BASIS_ID_O in NUMBER
,P_SUPERVISOR_ID_O in NUMBER
,P_WF_TRANSACTION_CATEGORY_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_PTX_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_PTX_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_PTX_RKD;

/
