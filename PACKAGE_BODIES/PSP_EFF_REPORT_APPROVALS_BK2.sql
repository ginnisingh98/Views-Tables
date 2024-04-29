--------------------------------------------------------
--  DDL for Package Body PSP_EFF_REPORT_APPROVALS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_EFF_REPORT_APPROVALS_BK2" as
/* $Header: PSPEAAIB.pls 120.3 2006/03/26 01:09:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:01:29 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_EFF_REPORT_APPROVALS_A
(P_EFFORT_REPORT_APPROVAL_ID in NUMBER
,P_EFFORT_REPORT_DETAIL_ID in NUMBER
,P_WF_ROLE_NAME in VARCHAR2
,P_WF_ORIG_SYSTEM_ID in NUMBER
,P_WF_ORIG_SYSTEM in VARCHAR2
,P_APPROVER_ORDER_NUM in NUMBER
,P_APPROVAL_STATUS in VARCHAR2
,P_RESPONSE_DATE in DATE
,P_ACTUAL_COST_SHARE in NUMBER
,P_OVERWRITTEN_EFFORT_PERCENT in NUMBER
,P_WF_ITEM_KEY in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_PERA_INFORMATION_CATEGORY in VARCHAR2
,P_PERA_INFORMATION1 in VARCHAR2
,P_PERA_INFORMATION2 in VARCHAR2
,P_PERA_INFORMATION3 in VARCHAR2
,P_PERA_INFORMATION4 in VARCHAR2
,P_PERA_INFORMATION5 in VARCHAR2
,P_PERA_INFORMATION6 in VARCHAR2
,P_PERA_INFORMATION7 in VARCHAR2
,P_PERA_INFORMATION8 in VARCHAR2
,P_PERA_INFORMATION9 in VARCHAR2
,P_PERA_INFORMATION10 in VARCHAR2
,P_PERA_INFORMATION11 in VARCHAR2
,P_PERA_INFORMATION12 in VARCHAR2
,P_PERA_INFORMATION13 in VARCHAR2
,P_PERA_INFORMATION14 in VARCHAR2
,P_PERA_INFORMATION15 in VARCHAR2
,P_PERA_INFORMATION16 in VARCHAR2
,P_PERA_INFORMATION17 in VARCHAR2
,P_PERA_INFORMATION18 in VARCHAR2
,P_PERA_INFORMATION19 in VARCHAR2
,P_PERA_INFORMATION20 in VARCHAR2
,P_WF_ROLE_DISPLAY_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFF_INFORMATION_CATEGORY in VARCHAR2
,P_EFF_INFORMATION1 in VARCHAR2
,P_EFF_INFORMATION2 in VARCHAR2
,P_EFF_INFORMATION3 in VARCHAR2
,P_EFF_INFORMATION4 in VARCHAR2
,P_EFF_INFORMATION5 in VARCHAR2
,P_EFF_INFORMATION6 in VARCHAR2
,P_EFF_INFORMATION7 in VARCHAR2
,P_EFF_INFORMATION8 in VARCHAR2
,P_EFF_INFORMATION9 in VARCHAR2
,P_EFF_INFORMATION10 in VARCHAR2
,P_EFF_INFORMATION11 in VARCHAR2
,P_EFF_INFORMATION12 in VARCHAR2
,P_EFF_INFORMATION13 in VARCHAR2
,P_EFF_INFORMATION14 in VARCHAR2
,P_EFF_INFORMATION15 in VARCHAR2
,P_RETURN_STATUS in BOOLEAN
)is
begin
hr_utility.set_location('Entering: PSP_EFF_REPORT_APPROVALS_BK2.UPDATE_EFF_REPORT_APPROVALS_A', 10);
hr_utility.set_location(' Leaving: PSP_EFF_REPORT_APPROVALS_BK2.UPDATE_EFF_REPORT_APPROVALS_A', 20);
end UPDATE_EFF_REPORT_APPROVALS_A;
procedure UPDATE_EFF_REPORT_APPROVALS_B
(P_EFFORT_REPORT_APPROVAL_ID in NUMBER
,P_EFFORT_REPORT_DETAIL_ID in NUMBER
,P_WF_ROLE_NAME in VARCHAR2
,P_WF_ORIG_SYSTEM_ID in NUMBER
,P_WF_ORIG_SYSTEM in VARCHAR2
,P_APPROVER_ORDER_NUM in NUMBER
,P_APPROVAL_STATUS in VARCHAR2
,P_RESPONSE_DATE in DATE
,P_ACTUAL_COST_SHARE in NUMBER
,P_OVERWRITTEN_EFFORT_PERCENT in NUMBER
,P_WF_ITEM_KEY in VARCHAR2
,P_COMMENTS in VARCHAR2
,P_PERA_INFORMATION_CATEGORY in VARCHAR2
,P_PERA_INFORMATION1 in VARCHAR2
,P_PERA_INFORMATION2 in VARCHAR2
,P_PERA_INFORMATION3 in VARCHAR2
,P_PERA_INFORMATION4 in VARCHAR2
,P_PERA_INFORMATION5 in VARCHAR2
,P_PERA_INFORMATION6 in VARCHAR2
,P_PERA_INFORMATION7 in VARCHAR2
,P_PERA_INFORMATION8 in VARCHAR2
,P_PERA_INFORMATION9 in VARCHAR2
,P_PERA_INFORMATION10 in VARCHAR2
,P_PERA_INFORMATION11 in VARCHAR2
,P_PERA_INFORMATION12 in VARCHAR2
,P_PERA_INFORMATION13 in VARCHAR2
,P_PERA_INFORMATION14 in VARCHAR2
,P_PERA_INFORMATION15 in VARCHAR2
,P_PERA_INFORMATION16 in VARCHAR2
,P_PERA_INFORMATION17 in VARCHAR2
,P_PERA_INFORMATION18 in VARCHAR2
,P_PERA_INFORMATION19 in VARCHAR2
,P_PERA_INFORMATION20 in VARCHAR2
,P_WF_ROLE_DISPLAY_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFF_INFORMATION_CATEGORY in VARCHAR2
,P_EFF_INFORMATION1 in VARCHAR2
,P_EFF_INFORMATION2 in VARCHAR2
,P_EFF_INFORMATION3 in VARCHAR2
,P_EFF_INFORMATION4 in VARCHAR2
,P_EFF_INFORMATION5 in VARCHAR2
,P_EFF_INFORMATION6 in VARCHAR2
,P_EFF_INFORMATION7 in VARCHAR2
,P_EFF_INFORMATION8 in VARCHAR2
,P_EFF_INFORMATION9 in VARCHAR2
,P_EFF_INFORMATION10 in VARCHAR2
,P_EFF_INFORMATION11 in VARCHAR2
,P_EFF_INFORMATION12 in VARCHAR2
,P_EFF_INFORMATION13 in VARCHAR2
,P_EFF_INFORMATION14 in VARCHAR2
,P_EFF_INFORMATION15 in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PSP_EFF_REPORT_APPROVALS_BK2.UPDATE_EFF_REPORT_APPROVALS_B', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
PSP_ERA_EXT.UPDATE_EFF_REPORT_APPROVAL_EXT
(P_EFFORT_REPORT_APPROVAL_ID => P_EFFORT_REPORT_APPROVAL_ID
,P_EFFORT_REPORT_DETAIL_ID => P_EFFORT_REPORT_DETAIL_ID
,P_WF_ROLE_NAME => P_WF_ROLE_NAME
,P_WF_ORIG_SYSTEM_ID => P_WF_ORIG_SYSTEM_ID
,P_WF_ORIG_SYSTEM => P_WF_ORIG_SYSTEM
,P_APPROVER_ORDER_NUM => P_APPROVER_ORDER_NUM
,P_APPROVAL_STATUS => P_APPROVAL_STATUS
,P_RESPONSE_DATE => P_RESPONSE_DATE
,P_ACTUAL_COST_SHARE => P_ACTUAL_COST_SHARE
,P_OVERWRITTEN_EFFORT_PERCENT => P_OVERWRITTEN_EFFORT_PERCENT
,P_WF_ITEM_KEY => P_WF_ITEM_KEY
,P_COMMENTS => P_COMMENTS
,P_PERA_INFORMATION_CATEGORY => P_PERA_INFORMATION_CATEGORY
,P_PERA_INFORMATION1 => P_PERA_INFORMATION1
,P_PERA_INFORMATION2 => P_PERA_INFORMATION2
,P_PERA_INFORMATION3 => P_PERA_INFORMATION3
,P_PERA_INFORMATION4 => P_PERA_INFORMATION4
,P_PERA_INFORMATION5 => P_PERA_INFORMATION5
,P_PERA_INFORMATION6 => P_PERA_INFORMATION6
,P_PERA_INFORMATION7 => P_PERA_INFORMATION7
,P_PERA_INFORMATION8 => P_PERA_INFORMATION8
,P_PERA_INFORMATION9 => P_PERA_INFORMATION9
,P_PERA_INFORMATION10 => P_PERA_INFORMATION10
,P_PERA_INFORMATION11 => P_PERA_INFORMATION11
,P_PERA_INFORMATION12 => P_PERA_INFORMATION12
,P_PERA_INFORMATION13 => P_PERA_INFORMATION13
,P_PERA_INFORMATION14 => P_PERA_INFORMATION14
,P_PERA_INFORMATION15 => P_PERA_INFORMATION15
,P_PERA_INFORMATION16 => P_PERA_INFORMATION16
,P_PERA_INFORMATION17 => P_PERA_INFORMATION17
,P_PERA_INFORMATION18 => P_PERA_INFORMATION18
,P_PERA_INFORMATION19 => P_PERA_INFORMATION19
,P_PERA_INFORMATION20 => P_PERA_INFORMATION20
,P_WF_ROLE_DISPLAY_NAME => P_WF_ROLE_DISPLAY_NAME
,P_EFF_INFORMATION_CATEGORY => P_EFF_INFORMATION_CATEGORY
,P_EFF_INFORMATION1 => P_EFF_INFORMATION1
,P_EFF_INFORMATION2 => P_EFF_INFORMATION2
,P_EFF_INFORMATION3 => P_EFF_INFORMATION3
,P_EFF_INFORMATION4 => P_EFF_INFORMATION4
,P_EFF_INFORMATION5 => P_EFF_INFORMATION5
,P_EFF_INFORMATION6 => P_EFF_INFORMATION6
,P_EFF_INFORMATION7 => P_EFF_INFORMATION7
,P_EFF_INFORMATION8 => P_EFF_INFORMATION8
,P_EFF_INFORMATION9 => P_EFF_INFORMATION9
,P_EFF_INFORMATION10 => P_EFF_INFORMATION10
,P_EFF_INFORMATION11 => P_EFF_INFORMATION11
,P_EFF_INFORMATION12 => P_EFF_INFORMATION12
,P_EFF_INFORMATION13 => P_EFF_INFORMATION13
,P_EFF_INFORMATION14 => P_EFF_INFORMATION14
,P_EFF_INFORMATION15 => P_EFF_INFORMATION15
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_EFF_REPORT_APPROVALS', 'BP');
hr_utility.set_location(' Leaving: PSP_EFF_REPORT_APPROVALS_BK2.UPDATE_EFF_REPORT_APPROVALS_B', 20);
end UPDATE_EFF_REPORT_APPROVALS_B;
end PSP_EFF_REPORT_APPROVALS_BK2;

/
