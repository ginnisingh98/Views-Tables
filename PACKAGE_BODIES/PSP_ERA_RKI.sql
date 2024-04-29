--------------------------------------------------------
--  DDL for Package Body PSP_ERA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERA_RKI" as
/* $Header: PSPEARHB.pls 120.2 2006/03/26 01:08 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:37:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
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
,P_NOTIFICATION_ID in NUMBER
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
begin
hr_utility.set_location('Entering: PSP_ERA_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PSP_ERA_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PSP_ERA_RKI;

/