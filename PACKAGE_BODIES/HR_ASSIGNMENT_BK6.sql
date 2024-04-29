--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_BK6" as
/* $Header: peasgapi.pkb 120.20.12010000.16 2010/04/29 12:29:11 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:36:18 (YYYY/MM/DD HH24:MI:SS)
procedure ACTIVATE_EMP_ASG_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_CHANGE_REASON in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: HR_ASSIGNMENT_BK6.ACTIVATE_EMP_ASG_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
hr_assignment_be6.ACTIVATE_EMP_ASG_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DATETRACK_UPDATE_MODE => P_DATETRACK_UPDATE_MODE
,P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_CHANGE_REASON => P_CHANGE_REASON
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID => P_ASSIGNMENT_STATUS_TYPE_ID
,P_EFFECTIVE_START_DATE => P_EFFECTIVE_START_DATE
,P_EFFECTIVE_END_DATE => P_EFFECTIVE_END_DATE
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'ACTIVATE_EMP_ASG', 'AP');
hr_utility.set_location(' Leaving: HR_ASSIGNMENT_BK6.ACTIVATE_EMP_ASG_A', 20);
end ACTIVATE_EMP_ASG_A;
procedure ACTIVATE_EMP_ASG_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_CHANGE_REASON in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ASSIGNMENT_BK6.ACTIVATE_EMP_ASG_B', 10);
hr_utility.set_location(' Leaving: HR_ASSIGNMENT_BK6.ACTIVATE_EMP_ASG_B', 20);
end ACTIVATE_EMP_ASG_B;
end HR_ASSIGNMENT_BK6;

/
