--------------------------------------------------------
--  DDL for Package Body BEN_CPI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPI_RKU" as
/* $Header: becpirhi.pkb 120.0 2005/05/28 01:13:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:13 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_GROUP_PER_IN_LER_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_SUPERVISOR_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_FULL_NAME in VARCHAR2
,P_BRIEF_NAME in VARCHAR2
,P_CUSTOM_NAME in VARCHAR2
,P_SUPERVISOR_FULL_NAME in VARCHAR2
,P_SUPERVISOR_BRIEF_NAME in VARCHAR2
,P_SUPERVISOR_CUSTOM_NAME in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_YEARS_EMPLOYED in NUMBER
,P_YEARS_IN_JOB in NUMBER
,P_YEARS_IN_POSITION in NUMBER
,P_YEARS_IN_GRADE in NUMBER
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_START_DATE in DATE
,P_ORIGINAL_START_DATE in DATE
,P_ADJUSTED_SVC_DATE in DATE
,P_BASE_SALARY in NUMBER
,P_BASE_SALARY_CHANGE_DATE in DATE
,P_PAYROLL_NAME in VARCHAR2
,P_PERFORMANCE_RATING in VARCHAR2
,P_PERFORMANCE_RATING_TYPE in VARCHAR2
,P_PERFORMANCE_RATING_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_JOB_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_POSITION_ID in NUMBER
,P_PEOPLE_GROUP_ID in NUMBER
,P_SOFT_CODING_KEYFLEX_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_PAY_RATE_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_FREQUENCY in VARCHAR2
,P_GRADE_ANNULIZATION_FACTOR in NUMBER
,P_PAY_ANNULIZATION_FACTOR in NUMBER
,P_GRD_MIN_VAL in NUMBER
,P_GRD_MAX_VAL in NUMBER
,P_GRD_MID_POINT in NUMBER
,P_GRD_QUARTILE in VARCHAR2
,P_GRD_COMPARATIO in NUMBER
,P_EMP_CATEGORY in VARCHAR2
,P_CHANGE_REASON in VARCHAR2
,P_NORMAL_HOURS in NUMBER
,P_EMAIL_ADDRESS in VARCHAR2
,P_BASE_SALARY_FREQUENCY in VARCHAR2
,P_NEW_ASSGN_OVN in NUMBER
,P_NEW_PERF_EVENT_ID in NUMBER
,P_NEW_PERF_REVIEW_ID in NUMBER
,P_POST_PROCESS_STAT_CD in VARCHAR2
,P_FEEDBACK_RATING in VARCHAR2
,P_FEEDBACK_COMMENTS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CUSTOM_SEGMENT1 in VARCHAR2
,P_CUSTOM_SEGMENT2 in VARCHAR2
,P_CUSTOM_SEGMENT3 in VARCHAR2
,P_CUSTOM_SEGMENT4 in VARCHAR2
,P_CUSTOM_SEGMENT5 in VARCHAR2
,P_CUSTOM_SEGMENT6 in VARCHAR2
,P_CUSTOM_SEGMENT7 in VARCHAR2
,P_CUSTOM_SEGMENT8 in VARCHAR2
,P_CUSTOM_SEGMENT9 in VARCHAR2
,P_CUSTOM_SEGMENT10 in VARCHAR2
,P_CUSTOM_SEGMENT11 in NUMBER
,P_CUSTOM_SEGMENT12 in NUMBER
,P_CUSTOM_SEGMENT13 in NUMBER
,P_CUSTOM_SEGMENT14 in NUMBER
,P_CUSTOM_SEGMENT15 in NUMBER
,P_CUSTOM_SEGMENT16 in NUMBER
,P_CUSTOM_SEGMENT17 in NUMBER
,P_CUSTOM_SEGMENT18 in NUMBER
,P_CUSTOM_SEGMENT19 in NUMBER
,P_CUSTOM_SEGMENT20 in NUMBER
,P_PEOPLE_GROUP_NAME in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT1 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT2 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT3 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT4 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT5 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT6 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT7 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT8 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT9 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT10 in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT11 in VARCHAR2
,P_ASS_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ASS_ATTRIBUTE1 in VARCHAR2
,P_ASS_ATTRIBUTE2 in VARCHAR2
,P_ASS_ATTRIBUTE3 in VARCHAR2
,P_ASS_ATTRIBUTE4 in VARCHAR2
,P_ASS_ATTRIBUTE5 in VARCHAR2
,P_ASS_ATTRIBUTE6 in VARCHAR2
,P_ASS_ATTRIBUTE7 in VARCHAR2
,P_ASS_ATTRIBUTE8 in VARCHAR2
,P_ASS_ATTRIBUTE9 in VARCHAR2
,P_ASS_ATTRIBUTE10 in VARCHAR2
,P_ASS_ATTRIBUTE11 in VARCHAR2
,P_ASS_ATTRIBUTE12 in VARCHAR2
,P_ASS_ATTRIBUTE13 in VARCHAR2
,P_ASS_ATTRIBUTE14 in VARCHAR2
,P_ASS_ATTRIBUTE15 in VARCHAR2
,P_ASS_ATTRIBUTE16 in VARCHAR2
,P_ASS_ATTRIBUTE17 in VARCHAR2
,P_ASS_ATTRIBUTE18 in VARCHAR2
,P_ASS_ATTRIBUTE19 in VARCHAR2
,P_ASS_ATTRIBUTE20 in VARCHAR2
,P_ASS_ATTRIBUTE21 in VARCHAR2
,P_ASS_ATTRIBUTE22 in VARCHAR2
,P_ASS_ATTRIBUTE23 in VARCHAR2
,P_ASS_ATTRIBUTE24 in VARCHAR2
,P_ASS_ATTRIBUTE25 in VARCHAR2
,P_ASS_ATTRIBUTE26 in VARCHAR2
,P_ASS_ATTRIBUTE27 in VARCHAR2
,P_ASS_ATTRIBUTE28 in VARCHAR2
,P_ASS_ATTRIBUTE29 in VARCHAR2
,P_ASS_ATTRIBUTE30 in VARCHAR2
,P_WS_COMMENTS in VARCHAR2
,P_CPI_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CPI_ATTRIBUTE1 in VARCHAR2
,P_CPI_ATTRIBUTE2 in VARCHAR2
,P_CPI_ATTRIBUTE3 in VARCHAR2
,P_CPI_ATTRIBUTE4 in VARCHAR2
,P_CPI_ATTRIBUTE5 in VARCHAR2
,P_CPI_ATTRIBUTE6 in VARCHAR2
,P_CPI_ATTRIBUTE7 in VARCHAR2
,P_CPI_ATTRIBUTE8 in VARCHAR2
,P_CPI_ATTRIBUTE9 in VARCHAR2
,P_CPI_ATTRIBUTE10 in VARCHAR2
,P_CPI_ATTRIBUTE11 in VARCHAR2
,P_CPI_ATTRIBUTE12 in VARCHAR2
,P_CPI_ATTRIBUTE13 in VARCHAR2
,P_CPI_ATTRIBUTE14 in VARCHAR2
,P_CPI_ATTRIBUTE15 in VARCHAR2
,P_CPI_ATTRIBUTE16 in VARCHAR2
,P_CPI_ATTRIBUTE17 in VARCHAR2
,P_CPI_ATTRIBUTE18 in VARCHAR2
,P_CPI_ATTRIBUTE19 in VARCHAR2
,P_CPI_ATTRIBUTE20 in VARCHAR2
,P_CPI_ATTRIBUTE21 in VARCHAR2
,P_CPI_ATTRIBUTE22 in VARCHAR2
,P_CPI_ATTRIBUTE23 in VARCHAR2
,P_CPI_ATTRIBUTE24 in VARCHAR2
,P_CPI_ATTRIBUTE25 in VARCHAR2
,P_CPI_ATTRIBUTE26 in VARCHAR2
,P_CPI_ATTRIBUTE27 in VARCHAR2
,P_CPI_ATTRIBUTE28 in VARCHAR2
,P_CPI_ATTRIBUTE29 in VARCHAR2
,P_CPI_ATTRIBUTE30 in VARCHAR2
,P_FEEDBACK_DATE in DATE
,P_ASSIGNMENT_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_SUPERVISOR_ID_O in NUMBER
,P_EFFECTIVE_DATE_O in DATE
,P_FULL_NAME_O in VARCHAR2
,P_BRIEF_NAME_O in VARCHAR2
,P_CUSTOM_NAME_O in VARCHAR2
,P_SUPERVISOR_FULL_NAME_O in VARCHAR2
,P_SUPERVISOR_BRIEF_NAME_O in VARCHAR2
,P_SUPERVISOR_CUSTOM_NAME_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_YEARS_EMPLOYED_O in NUMBER
,P_YEARS_IN_JOB_O in NUMBER
,P_YEARS_IN_POSITION_O in NUMBER
,P_YEARS_IN_GRADE_O in NUMBER
,P_EMPLOYEE_NUMBER_O in VARCHAR2
,P_START_DATE_O in DATE
,P_ORIGINAL_START_DATE_O in DATE
,P_ADJUSTED_SVC_DATE_O in DATE
,P_BASE_SALARY_O in NUMBER
,P_BASE_SALARY_CHANGE_DATE_O in DATE
,P_PAYROLL_NAME_O in VARCHAR2
,P_PERFORMANCE_RATING_O in VARCHAR2
,P_PERFORMANCE_RATING_TYPE_O in VARCHAR2
,P_PERFORMANCE_RATING_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ORGANIZATION_ID_O in NUMBER
,P_JOB_ID_O in NUMBER
,P_GRADE_ID_O in NUMBER
,P_POSITION_ID_O in NUMBER
,P_PEOPLE_GROUP_ID_O in NUMBER
,P_SOFT_CODING_KEYFLEX_ID_O in NUMBER
,P_LOCATION_ID_O in NUMBER
,P_PAY_RATE_ID_O in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID_O in NUMBER
,P_FREQUENCY_O in VARCHAR2
,P_GRADE_ANNULIZATION_FACTOR_O in NUMBER
,P_PAY_ANNULIZATION_FACTOR_O in NUMBER
,P_GRD_MIN_VAL_O in NUMBER
,P_GRD_MAX_VAL_O in NUMBER
,P_GRD_MID_POINT_O in NUMBER
,P_GRD_QUARTILE_O in VARCHAR2
,P_GRD_COMPARATIO_O in NUMBER
,P_EMP_CATEGORY_O in VARCHAR2
,P_CHANGE_REASON_O in VARCHAR2
,P_NORMAL_HOURS_O in NUMBER
,P_EMAIL_ADDRESS_O in VARCHAR2
,P_BASE_SALARY_FREQUENCY_O in VARCHAR2
,P_NEW_ASSGN_OVN_O in NUMBER
,P_NEW_PERF_EVENT_ID_O in NUMBER
,P_NEW_PERF_REVIEW_ID_O in NUMBER
,P_POST_PROCESS_STAT_CD_O in VARCHAR2
,P_FEEDBACK_RATING_O in VARCHAR2
,P_FEEDBACK_COMMENTS_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CUSTOM_SEGMENT1_O in VARCHAR2
,P_CUSTOM_SEGMENT2_O in VARCHAR2
,P_CUSTOM_SEGMENT3_O in VARCHAR2
,P_CUSTOM_SEGMENT4_O in VARCHAR2
,P_CUSTOM_SEGMENT5_O in VARCHAR2
,P_CUSTOM_SEGMENT6_O in VARCHAR2
,P_CUSTOM_SEGMENT7_O in VARCHAR2
,P_CUSTOM_SEGMENT8_O in VARCHAR2
,P_CUSTOM_SEGMENT9_O in VARCHAR2
,P_CUSTOM_SEGMENT10_O in VARCHAR2
,P_CUSTOM_SEGMENT11_O in NUMBER
,P_CUSTOM_SEGMENT12_O in NUMBER
,P_CUSTOM_SEGMENT13_O in NUMBER
,P_CUSTOM_SEGMENT14_O in NUMBER
,P_CUSTOM_SEGMENT15_O in NUMBER
,P_CUSTOM_SEGMENT16_O in NUMBER
,P_CUSTOM_SEGMENT17_O in NUMBER
,P_CUSTOM_SEGMENT18_O in NUMBER
,P_CUSTOM_SEGMENT19_O in NUMBER
,P_CUSTOM_SEGMENT20_O in NUMBER
,P_PEOPLE_GROUP_NAME_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT1_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT2_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT3_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT4_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT5_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT6_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT7_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT8_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT9_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT10_O in VARCHAR2
,P_PEOPLE_GROUP_SEGMENT11_O in VARCHAR2
,P_ASS_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ASS_ATTRIBUTE1_O in VARCHAR2
,P_ASS_ATTRIBUTE2_O in VARCHAR2
,P_ASS_ATTRIBUTE3_O in VARCHAR2
,P_ASS_ATTRIBUTE4_O in VARCHAR2
,P_ASS_ATTRIBUTE5_O in VARCHAR2
,P_ASS_ATTRIBUTE6_O in VARCHAR2
,P_ASS_ATTRIBUTE7_O in VARCHAR2
,P_ASS_ATTRIBUTE8_O in VARCHAR2
,P_ASS_ATTRIBUTE9_O in VARCHAR2
,P_ASS_ATTRIBUTE10_O in VARCHAR2
,P_ASS_ATTRIBUTE11_O in VARCHAR2
,P_ASS_ATTRIBUTE12_O in VARCHAR2
,P_ASS_ATTRIBUTE13_O in VARCHAR2
,P_ASS_ATTRIBUTE14_O in VARCHAR2
,P_ASS_ATTRIBUTE15_O in VARCHAR2
,P_ASS_ATTRIBUTE16_O in VARCHAR2
,P_ASS_ATTRIBUTE17_O in VARCHAR2
,P_ASS_ATTRIBUTE18_O in VARCHAR2
,P_ASS_ATTRIBUTE19_O in VARCHAR2
,P_ASS_ATTRIBUTE20_O in VARCHAR2
,P_ASS_ATTRIBUTE21_O in VARCHAR2
,P_ASS_ATTRIBUTE22_O in VARCHAR2
,P_ASS_ATTRIBUTE23_O in VARCHAR2
,P_ASS_ATTRIBUTE24_O in VARCHAR2
,P_ASS_ATTRIBUTE25_O in VARCHAR2
,P_ASS_ATTRIBUTE26_O in VARCHAR2
,P_ASS_ATTRIBUTE27_O in VARCHAR2
,P_ASS_ATTRIBUTE28_O in VARCHAR2
,P_ASS_ATTRIBUTE29_O in VARCHAR2
,P_ASS_ATTRIBUTE30_O in VARCHAR2
,P_WS_COMMENTS_O in VARCHAR2
,P_CPI_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CPI_ATTRIBUTE1_O in VARCHAR2
,P_CPI_ATTRIBUTE2_O in VARCHAR2
,P_CPI_ATTRIBUTE3_O in VARCHAR2
,P_CPI_ATTRIBUTE4_O in VARCHAR2
,P_CPI_ATTRIBUTE5_O in VARCHAR2
,P_CPI_ATTRIBUTE6_O in VARCHAR2
,P_CPI_ATTRIBUTE7_O in VARCHAR2
,P_CPI_ATTRIBUTE8_O in VARCHAR2
,P_CPI_ATTRIBUTE9_O in VARCHAR2
,P_CPI_ATTRIBUTE10_O in VARCHAR2
,P_CPI_ATTRIBUTE11_O in VARCHAR2
,P_CPI_ATTRIBUTE12_O in VARCHAR2
,P_CPI_ATTRIBUTE13_O in VARCHAR2
,P_CPI_ATTRIBUTE14_O in VARCHAR2
,P_CPI_ATTRIBUTE15_O in VARCHAR2
,P_CPI_ATTRIBUTE16_O in VARCHAR2
,P_CPI_ATTRIBUTE17_O in VARCHAR2
,P_CPI_ATTRIBUTE18_O in VARCHAR2
,P_CPI_ATTRIBUTE19_O in VARCHAR2
,P_CPI_ATTRIBUTE20_O in VARCHAR2
,P_CPI_ATTRIBUTE21_O in VARCHAR2
,P_CPI_ATTRIBUTE22_O in VARCHAR2
,P_CPI_ATTRIBUTE23_O in VARCHAR2
,P_CPI_ATTRIBUTE24_O in VARCHAR2
,P_CPI_ATTRIBUTE25_O in VARCHAR2
,P_CPI_ATTRIBUTE26_O in VARCHAR2
,P_CPI_ATTRIBUTE27_O in VARCHAR2
,P_CPI_ATTRIBUTE28_O in VARCHAR2
,P_CPI_ATTRIBUTE29_O in VARCHAR2
,P_CPI_ATTRIBUTE30_O in VARCHAR2
,P_FEEDBACK_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: BEN_CPI_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_CPI_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_CPI_RKU;

/