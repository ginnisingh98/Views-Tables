--------------------------------------------------------
--  DDL for Package Body GHR_PAR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PAR_RKI" as
/* $Header: ghparrhi.pkb 120.5.12010000.3 2008/10/22 07:10:55 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:16 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PA_REQUEST_ID in NUMBER
,P_PA_NOTIFICATION_ID in NUMBER
,P_NOA_FAMILY_CODE in VARCHAR2
,P_ROUTING_GROUP_ID in NUMBER
,P_PROPOSED_EFFECTIVE_ASAP_FLAG in VARCHAR2
,P_ACADEMIC_DISCIPLINE in VARCHAR2
,P_ADDITIONAL_INFO_PERSON_ID in NUMBER
,P_ADDITIONAL_INFO_TEL_NUMBER in VARCHAR2
,P_AGENCY_CODE in VARCHAR2
,P_ALTERED_PA_REQUEST_ID in NUMBER
,P_ANNUITANT_INDICATOR in VARCHAR2
,P_ANNUITANT_INDICATOR_DESC in VARCHAR2
,P_APPROPRIATION_CODE1 in VARCHAR2
,P_APPROPRIATION_CODE2 in VARCHAR2
,P_APPROVAL_DATE in DATE
,P_APPROVING_OFFICIAL_FULL_NAME in VARCHAR2
,P_APPROVING_OFFICIAL_WORK_TITL in VARCHAR2
,P_SF50_APPROVAL_DATE in DATE
,P_SF50_APPROVING_OFCL_FULL_NAM in VARCHAR2
,P_SF50_APPROVING_OFCL_WORK_TIT in VARCHAR2
,P_AUTHORIZED_BY_PERSON_ID in NUMBER
,P_AUTHORIZED_BY_TITLE in VARCHAR2
,P_AWARD_AMOUNT in NUMBER
,P_AWARD_UOM in VARCHAR2
,P_BARGAINING_UNIT_STATUS in VARCHAR2
,P_CITIZENSHIP in VARCHAR2
,P_CONCURRENCE_DATE in DATE
,P_CUSTOM_PAY_CALC_FLAG in VARCHAR2
,P_DUTY_STATION_CODE in VARCHAR2
,P_DUTY_STATION_DESC in VARCHAR2
,P_DUTY_STATION_ID in NUMBER
,P_DUTY_STATION_LOCATION_ID in NUMBER
,P_EDUCATION_LEVEL in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_EMPLOYEE_ASSIGNMENT_ID in NUMBER
,P_EMPLOYEE_DATE_OF_BIRTH in DATE
,P_EMPLOYEE_DEPT_OR_AGENCY in VARCHAR2
,P_EMPLOYEE_FIRST_NAME in VARCHAR2
,P_EMPLOYEE_LAST_NAME in VARCHAR2
,P_EMPLOYEE_MIDDLE_NAMES in VARCHAR2
,P_EMPLOYEE_NATIONAL_IDENTIFIER in VARCHAR2
,P_FEGLI in VARCHAR2
,P_FEGLI_DESC in VARCHAR2
,P_FIRST_ACTION_LA_CODE1 in VARCHAR2
,P_FIRST_ACTION_LA_CODE2 in VARCHAR2
,P_FIRST_ACTION_LA_DESC1 in VARCHAR2
,P_FIRST_ACTION_LA_DESC2 in VARCHAR2
,P_FIRST_NOA_CANCEL_OR_CORRECT in VARCHAR2
,P_FIRST_NOA_CODE in VARCHAR2
,P_FIRST_NOA_DESC in VARCHAR2
,P_FIRST_NOA_ID in NUMBER
,P_FIRST_NOA_PA_REQUEST_ID in NUMBER
,P_FLSA_CATEGORY in VARCHAR2
,P_FORWARDING_ADDRESS_LINE1 in VARCHAR2
,P_FORWARDING_ADDRESS_LINE2 in VARCHAR2
,P_FORWARDING_ADDRESS_LINE3 in VARCHAR2
,P_FORWARDING_COUNTRY in VARCHAR2
,P_FORWARDING_COUNTRY_SHORT_NAM in VARCHAR2
,P_FORWARDING_POSTAL_CODE in VARCHAR2
,P_FORWARDING_REGION_2 in VARCHAR2
,P_FORWARDING_TOWN_OR_CITY in VARCHAR2
,P_FROM_ADJ_BASIC_PAY in NUMBER
,P_FROM_AGENCY_CODE in VARCHAR2
,P_FROM_AGENCY_DESC in VARCHAR2
,P_FROM_BASIC_PAY in NUMBER
,P_FROM_GRADE_OR_LEVEL in VARCHAR2
,P_FROM_LOCALITY_ADJ in NUMBER
,P_FROM_OCC_CODE in VARCHAR2
,P_FROM_OFFICE_SYMBOL in VARCHAR2
,P_FROM_OTHER_PAY_AMOUNT in NUMBER
,P_FROM_PAY_BASIS in VARCHAR2
,P_FROM_PAY_PLAN in VARCHAR2
,P_FROM_POSITION_ID in NUMBER
,P_FROM_POSITION_ORG_LINE1 in VARCHAR2
,P_FROM_POSITION_ORG_LINE2 in VARCHAR2
,P_FROM_POSITION_ORG_LINE3 in VARCHAR2
,P_FROM_POSITION_ORG_LINE4 in VARCHAR2
,P_FROM_POSITION_ORG_LINE5 in VARCHAR2
,P_FROM_POSITION_ORG_LINE6 in VARCHAR2
,P_FROM_POSITION_NUMBER in VARCHAR2
,P_FROM_POSITION_SEQ_NO in NUMBER
,P_FROM_POSITION_TITLE in VARCHAR2
,P_FROM_STEP_OR_RATE in VARCHAR2
,P_FROM_TOTAL_SALARY in NUMBER
,P_FUNCTIONAL_CLASS in VARCHAR2
,P_NOTEPAD in VARCHAR2
,P_PART_TIME_HOURS in NUMBER
,P_PAY_RATE_DETERMINANT in VARCHAR2
,P_PERSONNEL_OFFICE_ID in VARCHAR2
,P_PERSON_ID in NUMBER
,P_POSITION_OCCUPIED in VARCHAR2
,P_PROPOSED_EFFECTIVE_DATE in DATE
,P_REQUESTED_BY_PERSON_ID in NUMBER
,P_REQUESTED_BY_TITLE in VARCHAR2
,P_REQUESTED_DATE in DATE
,P_REQUESTING_OFFICE_REMARKS_DE in VARCHAR2
,P_REQUESTING_OFFICE_REMARKS_FL in VARCHAR2
,P_REQUEST_NUMBER in VARCHAR2
,P_RESIGN_AND_RETIRE_REASON_DES in VARCHAR2
,P_RETIREMENT_PLAN in VARCHAR2
,P_RETIREMENT_PLAN_DESC in VARCHAR2
,P_SECOND_ACTION_LA_CODE1 in VARCHAR2
,P_SECOND_ACTION_LA_CODE2 in VARCHAR2
,P_SECOND_ACTION_LA_DESC1 in VARCHAR2
,P_SECOND_ACTION_LA_DESC2 in VARCHAR2
,P_SECOND_NOA_CANCEL_OR_CORRECT in VARCHAR2
,P_SECOND_NOA_CODE in VARCHAR2
,P_SECOND_NOA_DESC in VARCHAR2
,P_SECOND_NOA_ID in NUMBER
,P_SECOND_NOA_PA_REQUEST_ID in NUMBER
,P_SERVICE_COMP_DATE in DATE
,P_STATUS in VARCHAR2
,P_SUPERVISORY_STATUS in VARCHAR2
,P_TENURE in VARCHAR2
,P_TO_ADJ_BASIC_PAY in NUMBER
,P_TO_BASIC_PAY in NUMBER
,P_TO_GRADE_ID in NUMBER
,P_TO_GRADE_OR_LEVEL in VARCHAR2
,P_TO_JOB_ID in NUMBER
,P_TO_LOCALITY_ADJ in NUMBER
,P_TO_OCC_CODE in VARCHAR2
,P_TO_OFFICE_SYMBOL in VARCHAR2
,P_TO_ORGANIZATION_ID in NUMBER
,P_TO_OTHER_PAY_AMOUNT in NUMBER
,P_TO_AU_OVERTIME in NUMBER
,P_TO_AUO_PREMIUM_PAY_INDICATOR in VARCHAR2
,P_TO_AVAILABILITY_PAY in NUMBER
,P_TO_AP_PREMIUM_PAY_INDICATOR in VARCHAR2
,P_TO_RETENTION_ALLOWANCE in NUMBER
,P_TO_SUPERVISORY_DIFFERENTIAL in NUMBER
,P_TO_STAFFING_DIFFERENTIAL in NUMBER
,P_TO_PAY_BASIS in VARCHAR2
,P_TO_PAY_PLAN in VARCHAR2
,P_TO_POSITION_ID in NUMBER
,P_TO_POSITION_ORG_LINE1 in VARCHAR2
,P_TO_POSITION_ORG_LINE2 in VARCHAR2
,P_TO_POSITION_ORG_LINE3 in VARCHAR2
,P_TO_POSITION_ORG_LINE4 in VARCHAR2
,P_TO_POSITION_ORG_LINE5 in VARCHAR2
,P_TO_POSITION_ORG_LINE6 in VARCHAR2
,P_TO_POSITION_NUMBER in VARCHAR2
,P_TO_POSITION_SEQ_NO in NUMBER
,P_TO_POSITION_TITLE in VARCHAR2
,P_TO_STEP_OR_RATE in VARCHAR2
,P_TO_TOTAL_SALARY in NUMBER
,P_VETERANS_PREFERENCE in VARCHAR2
,P_VETERANS_PREF_FOR_RIF in VARCHAR2
,P_VETERANS_STATUS in VARCHAR2
,P_WORK_SCHEDULE in VARCHAR2
,P_WORK_SCHEDULE_DESC in VARCHAR2
,P_YEAR_DEGREE_ATTAINED in NUMBER
,P_FIRST_NOA_INFORMATION1 in VARCHAR2
,P_FIRST_NOA_INFORMATION2 in VARCHAR2
,P_FIRST_NOA_INFORMATION3 in VARCHAR2
,P_FIRST_NOA_INFORMATION4 in VARCHAR2
,P_FIRST_NOA_INFORMATION5 in VARCHAR2
,P_SECOND_LAC1_INFORMATION1 in VARCHAR2
,P_SECOND_LAC1_INFORMATION2 in VARCHAR2
,P_SECOND_LAC1_INFORMATION3 in VARCHAR2
,P_SECOND_LAC1_INFORMATION4 in VARCHAR2
,P_SECOND_LAC1_INFORMATION5 in VARCHAR2
,P_SECOND_LAC2_INFORMATION1 in VARCHAR2
,P_SECOND_LAC2_INFORMATION2 in VARCHAR2
,P_SECOND_LAC2_INFORMATION3 in VARCHAR2
,P_SECOND_LAC2_INFORMATION4 in VARCHAR2
,P_SECOND_LAC2_INFORMATION5 in VARCHAR2
,P_SECOND_NOA_INFORMATION1 in VARCHAR2
,P_SECOND_NOA_INFORMATION2 in VARCHAR2
,P_SECOND_NOA_INFORMATION3 in VARCHAR2
,P_SECOND_NOA_INFORMATION4 in VARCHAR2
,P_SECOND_NOA_INFORMATION5 in VARCHAR2
,P_FIRST_LAC1_INFORMATION1 in VARCHAR2
,P_FIRST_LAC1_INFORMATION2 in VARCHAR2
,P_FIRST_LAC1_INFORMATION3 in VARCHAR2
,P_FIRST_LAC1_INFORMATION4 in VARCHAR2
,P_FIRST_LAC1_INFORMATION5 in VARCHAR2
,P_FIRST_LAC2_INFORMATION1 in VARCHAR2
,P_FIRST_LAC2_INFORMATION2 in VARCHAR2
,P_FIRST_LAC2_INFORMATION3 in VARCHAR2
,P_FIRST_LAC2_INFORMATION4 in VARCHAR2
,P_FIRST_LAC2_INFORMATION5 in VARCHAR2
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
,P_FIRST_NOA_CANC_PA_REQUEST_ID in NUMBER
,P_SECOND_NOA_CANC_PA_REQUEST_I in NUMBER
,P_TO_RETENTION_ALLOW_PERCENTAG in NUMBER
,P_TO_SUPERVISORY_DIFF_PERCENTA in NUMBER
,P_TO_STAFFING_DIFF_PERCENTAGE in NUMBER
,P_AWARD_PERCENTAGE in NUMBER
,P_RPA_TYPE in VARCHAR2
,P_MASS_ACTION_ID in NUMBER
,P_MASS_ACTION_ELIGIBLE_FLAG in VARCHAR2
,P_MASS_ACTION_SELECT_FLAG in VARCHAR2
,P_MASS_ACTION_COMMENTS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: GHR_PAR_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: GHR_PAR_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end GHR_PAR_RKI;

/
