--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_BK2" as
/* $Header: peappapi.pkb 120.18.12010000.13 2009/08/24 15:11:41 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:17 (YYYY/MM/DD HH24:MI:SS)
procedure  HIRE_APPLICANT_A
(P_HIRE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_NATIONAL_IDENTIFIER in VARCHAR2
,P_PER_OBJECT_VERSION_NUMBER in NUMBER
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_PER_EFFECTIVE_START_DATE in DATE
,P_PER_EFFECTIVE_END_DATE in DATE
,P_UNACCEPTED_ASG_DEL_WARNING in BOOLEAN
,P_ASSIGN_PAYROLL_WARNING in BOOLEAN
,P_OVERSUBSCRIBED_VACANCY_ID in NUMBER
,P_ORIGINAL_DATE_OF_HIRE in DATE
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_APPLICANT_BK2. HIRE_APPLICANT_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_applicant_be2. HIRE_APPLICANT_A
(P_HIRE_DATE => P_HIRE_DATE
,P_PERSON_ID => P_PERSON_ID
,P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_PERSON_TYPE_ID => P_PERSON_TYPE_ID
,P_NATIONAL_IDENTIFIER => P_NATIONAL_IDENTIFIER
,P_PER_OBJECT_VERSION_NUMBER => P_PER_OBJECT_VERSION_NUMBER
,P_EMPLOYEE_NUMBER => P_EMPLOYEE_NUMBER
,P_PER_EFFECTIVE_START_DATE => P_PER_EFFECTIVE_START_DATE
,P_PER_EFFECTIVE_END_DATE => P_PER_EFFECTIVE_END_DATE
,P_UNACCEPTED_ASG_DEL_WARNING => P_UNACCEPTED_ASG_DEL_WARNING
,P_ASSIGN_PAYROLL_WARNING => P_ASSIGN_PAYROLL_WARNING
,P_OVERSUBSCRIBED_VACANCY_ID => P_OVERSUBSCRIBED_VACANCY_ID
,P_ORIGINAL_DATE_OF_HIRE => P_ORIGINAL_DATE_OF_HIRE
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'HIRE_APPLICANT', 'AP');
hr_utility.set_location(' Leaving: HR_APPLICANT_BK2. HIRE_APPLICANT_A', 20);
end  HIRE_APPLICANT_A;
procedure HIRE_APPLICANT_B
(P_HIRE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_NATIONAL_IDENTIFIER in VARCHAR2
,P_PER_OBJECT_VERSION_NUMBER in NUMBER
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_ORIGINAL_DATE_OF_HIRE in DATE
)is
begin
hr_utility.set_location('Entering: HR_APPLICANT_BK2.HIRE_APPLICANT_B', 10);
hr_utility.set_location(' Leaving: HR_APPLICANT_BK2.HIRE_APPLICANT_B', 20);
end HIRE_APPLICANT_B;
end HR_APPLICANT_BK2;

/