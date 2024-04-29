--------------------------------------------------------
--  DDL for Package Body HR_PERSON_DEPLOYMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_DEPLOYMENT_BK2" as
/* $Header: hrpdtapi.pkb 120.23 2007/11/22 08:30:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PERSON_DEPLOYMENT_A
(P_PERSON_DEPLOYMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TO_PERSON_ID in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_DEPLOYMENT_REASON in VARCHAR2
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_LEAVING_REASON in VARCHAR2
,P_LEAVING_PERSON_TYPE_ID in NUMBER
,P_STATUS in VARCHAR2
,P_STATUS_CHANGE_REASON in VARCHAR2
,P_DEPLYMT_POLICY_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_JOB_ID in NUMBER
,P_POSITION_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_SUPERVISOR_ID in NUMBER
,P_SUPERVISOR_ASSIGNMENT_ID in NUMBER
,P_RETAIN_DIRECT_REPORTS in VARCHAR2
,P_PAYROLL_ID in NUMBER
,P_PAY_BASIS_ID in NUMBER
,P_PROPOSED_SALARY in VARCHAR2
,P_PEOPLE_GROUP_ID in NUMBER
,P_SOFT_CODING_KEYFLEX_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_ASS_STATUS_CHANGE_REASON in VARCHAR2
,P_ASSIGNMENT_CATEGORY in VARCHAR2
,P_PER_INFORMATION1 in VARCHAR2
,P_PER_INFORMATION2 in VARCHAR2
,P_PER_INFORMATION3 in VARCHAR2
,P_PER_INFORMATION4 in VARCHAR2
,P_PER_INFORMATION5 in VARCHAR2
,P_PER_INFORMATION6 in VARCHAR2
,P_PER_INFORMATION7 in VARCHAR2
,P_PER_INFORMATION8 in VARCHAR2
,P_PER_INFORMATION9 in VARCHAR2
,P_PER_INFORMATION10 in VARCHAR2
,P_PER_INFORMATION11 in VARCHAR2
,P_PER_INFORMATION12 in VARCHAR2
,P_PER_INFORMATION13 in VARCHAR2
,P_PER_INFORMATION14 in VARCHAR2
,P_PER_INFORMATION15 in VARCHAR2
,P_PER_INFORMATION16 in VARCHAR2
,P_PER_INFORMATION17 in VARCHAR2
,P_PER_INFORMATION18 in VARCHAR2
,P_PER_INFORMATION19 in VARCHAR2
,P_PER_INFORMATION20 in VARCHAR2
,P_PER_INFORMATION21 in VARCHAR2
,P_PER_INFORMATION22 in VARCHAR2
,P_PER_INFORMATION23 in VARCHAR2
,P_PER_INFORMATION24 in VARCHAR2
,P_PER_INFORMATION25 in VARCHAR2
,P_PER_INFORMATION26 in VARCHAR2
,P_PER_INFORMATION27 in VARCHAR2
,P_PER_INFORMATION28 in VARCHAR2
,P_PER_INFORMATION29 in VARCHAR2
,P_PER_INFORMATION30 in VARCHAR2
,P_POLICY_DURATION_WARNING in BOOLEAN
)is
begin
hr_utility.set_location('Entering: HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_A', 10);
hr_utility.set_location(' Leaving: HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_A', 20);
end UPDATE_PERSON_DEPLOYMENT_A;
procedure UPDATE_PERSON_DEPLOYMENT_B
(P_PERSON_DEPLOYMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TO_PERSON_ID in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_DEPLOYMENT_REASON in VARCHAR2
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_LEAVING_REASON in VARCHAR2
,P_LEAVING_PERSON_TYPE_ID in NUMBER
,P_STATUS in VARCHAR2
,P_STATUS_CHANGE_REASON in VARCHAR2
,P_DEPLYMT_POLICY_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_JOB_ID in NUMBER
,P_POSITION_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_SUPERVISOR_ID in NUMBER
,P_SUPERVISOR_ASSIGNMENT_ID in NUMBER
,P_RETAIN_DIRECT_REPORTS in VARCHAR2
,P_PAYROLL_ID in NUMBER
,P_PAY_BASIS_ID in NUMBER
,P_PROPOSED_SALARY in VARCHAR2
,P_PEOPLE_GROUP_ID in NUMBER
,P_SOFT_CODING_KEYFLEX_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_ASS_STATUS_CHANGE_REASON in VARCHAR2
,P_ASSIGNMENT_CATEGORY in VARCHAR2
,P_PER_INFORMATION1 in VARCHAR2
,P_PER_INFORMATION2 in VARCHAR2
,P_PER_INFORMATION3 in VARCHAR2
,P_PER_INFORMATION4 in VARCHAR2
,P_PER_INFORMATION5 in VARCHAR2
,P_PER_INFORMATION6 in VARCHAR2
,P_PER_INFORMATION7 in VARCHAR2
,P_PER_INFORMATION8 in VARCHAR2
,P_PER_INFORMATION9 in VARCHAR2
,P_PER_INFORMATION10 in VARCHAR2
,P_PER_INFORMATION11 in VARCHAR2
,P_PER_INFORMATION12 in VARCHAR2
,P_PER_INFORMATION13 in VARCHAR2
,P_PER_INFORMATION14 in VARCHAR2
,P_PER_INFORMATION15 in VARCHAR2
,P_PER_INFORMATION16 in VARCHAR2
,P_PER_INFORMATION17 in VARCHAR2
,P_PER_INFORMATION18 in VARCHAR2
,P_PER_INFORMATION19 in VARCHAR2
,P_PER_INFORMATION20 in VARCHAR2
,P_PER_INFORMATION21 in VARCHAR2
,P_PER_INFORMATION22 in VARCHAR2
,P_PER_INFORMATION23 in VARCHAR2
,P_PER_INFORMATION24 in VARCHAR2
,P_PER_INFORMATION25 in VARCHAR2
,P_PER_INFORMATION26 in VARCHAR2
,P_PER_INFORMATION27 in VARCHAR2
,P_PER_INFORMATION28 in VARCHAR2
,P_PER_INFORMATION29 in VARCHAR2
,P_PER_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_B', 10);
hr_utility.set_location(' Leaving: HR_PERSON_DEPLOYMENT_BK2.UPDATE_PERSON_DEPLOYMENT_B', 20);
end UPDATE_PERSON_DEPLOYMENT_B;
end HR_PERSON_DEPLOYMENT_BK2;

/