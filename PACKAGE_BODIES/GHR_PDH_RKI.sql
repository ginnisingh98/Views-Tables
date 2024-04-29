--------------------------------------------------------
--  DDL for Package Body GHR_PDH_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDH_RKI" as
/* $Header: ghpdhrhi.pkb 120.1 2006/01/17 06:21:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:53:08 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PD_ROUTING_HISTORY_ID in NUMBER
,P_POSITION_DESCRIPTION_ID in NUMBER
,P_INITIATOR_FLAG in VARCHAR2
,P_REQUESTER_FLAG in VARCHAR2
,P_APPROVER_FLAG in VARCHAR2
,P_REVIEWER_FLAG in VARCHAR2
,P_AUTHORIZER_FLAG in VARCHAR2
,P_PERSONNELIST_FLAG in VARCHAR2
,P_APPROVED_FLAG in VARCHAR2
,P_USER_NAME in VARCHAR2
,P_USER_NAME_EMPLOYEE_ID in NUMBER
,P_USER_NAME_EMP_FIRST_NAME in VARCHAR2
,P_USER_NAME_EMP_LAST_NAME in VARCHAR2
,P_USER_NAME_EMP_MIDDLE_NAMES in VARCHAR2
,P_ACTION_TAKEN in VARCHAR2
,P_GROUPBOX_ID in NUMBER
,P_ROUTING_LIST_ID in NUMBER
,P_ROUTING_SEQ_NUMBER in NUMBER
,P_DATE_NOTIFICATION_SENT in DATE
,P_ITEM_KEY in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_PDH_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: GHR_PDH_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end GHR_PDH_RKI;

/
