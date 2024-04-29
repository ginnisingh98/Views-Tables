--------------------------------------------------------
--  DDL for Package Body HR_EMPLOYEE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EMPLOYEE_BK2" as
/* $Header: peempapi.pkb 120.8.12010000.6 2009/09/29 13:25:02 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:17 (YYYY/MM/DD HH24:MI:SS)
procedure RE_HIRE_EX_EMPLOYEE_A
(P_BUSINESS_GROUP_ID in NUMBER
,P_HIRE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_PER_OBJECT_VERSION_NUMBER in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_REHIRE_REASON in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_ASG_OBJECT_VERSION_NUMBER in NUMBER
,P_PER_EFFECTIVE_START_DATE in DATE
,P_PER_EFFECTIVE_END_DATE in DATE
,P_ASSIGNMENT_SEQUENCE in NUMBER
,P_ASSIGNMENT_NUMBER in VARCHAR2
,P_ASSIGN_PAYROLL_WARNING in BOOLEAN
)is
begin
hr_utility.set_location('Entering: HR_EMPLOYEE_BK2.RE_HIRE_EX_EMPLOYEE_A', 10);
hr_utility.set_location(' Leaving: HR_EMPLOYEE_BK2.RE_HIRE_EX_EMPLOYEE_A', 20);
end RE_HIRE_EX_EMPLOYEE_A;
procedure RE_HIRE_EX_EMPLOYEE_B
(P_BUSINESS_GROUP_ID in NUMBER
,P_HIRE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_PER_OBJECT_VERSION_NUMBER in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_REHIRE_REASON in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_EMPLOYEE_BK2.RE_HIRE_EX_EMPLOYEE_B', 10);
hr_utility.set_location(' Leaving: HR_EMPLOYEE_BK2.RE_HIRE_EX_EMPLOYEE_B', 20);
end RE_HIRE_EX_EMPLOYEE_B;
end HR_EMPLOYEE_BK2;

/