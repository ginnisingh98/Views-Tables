--------------------------------------------------------
--  DDL for Package Body IRC_ASG_STATUS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ASG_STATUS_BK1" as
/* $Header: iriasapi.pkb 120.3.12010000.6 2010/05/14 10:56:29 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:52 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_IRC_ASG_STATUS_A
(P_ASSIGNMENT_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_STATUS_CHANGE_REASON in VARCHAR2
,P_ASSIGNMENT_STATUS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_STATUS_CHANGE_DATE in DATE
,P_STATUS_CHANGE_COMMENTS in VARCHAR2
,P_STATUS_CHANGE_BY in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_ASG_STATUS_BK1.CREATE_IRC_ASG_STATUS_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_asg_status_be1.CREATE_IRC_ASG_STATUS_A
(P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_ASSIGNMENT_STATUS_TYPE_ID => P_ASSIGNMENT_STATUS_TYPE_ID
,P_STATUS_CHANGE_REASON => P_STATUS_CHANGE_REASON
,P_ASSIGNMENT_STATUS_ID => P_ASSIGNMENT_STATUS_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_STATUS_CHANGE_DATE => P_STATUS_CHANGE_DATE
,P_STATUS_CHANGE_COMMENTS => P_STATUS_CHANGE_COMMENTS
,P_STATUS_CHANGE_BY => P_STATUS_CHANGE_BY
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_IRC_ASG_STATUS', 'AP');
hr_utility.set_location(' Leaving: IRC_ASG_STATUS_BK1.CREATE_IRC_ASG_STATUS_A', 20);
end CREATE_IRC_ASG_STATUS_A;
procedure CREATE_IRC_ASG_STATUS_B
(P_ASSIGNMENT_ID in NUMBER
,P_ASSIGNMENT_STATUS_TYPE_ID in NUMBER
,P_STATUS_CHANGE_REASON in VARCHAR2
,P_STATUS_CHANGE_DATE in DATE
,P_STATUS_CHANGE_COMMENTS in VARCHAR2
,P_STATUS_CHANGE_BY in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_ASG_STATUS_BK1.CREATE_IRC_ASG_STATUS_B', 10);
hr_utility.set_location(' Leaving: IRC_ASG_STATUS_BK1.CREATE_IRC_ASG_STATUS_B', 20);
end CREATE_IRC_ASG_STATUS_B;
end IRC_ASG_STATUS_BK1;

/