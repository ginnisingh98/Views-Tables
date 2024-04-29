--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_GROUPS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_GROUPS_BK1" as
/* $Header: pyevgapi.pkb 120.2 2005/10/04 00:23:34 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:56 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_EVENT_GROUP_A
(P_EFFECTIVE_DATE in DATE
,P_EVENT_GROUP_NAME in VARCHAR2
,P_EVENT_GROUP_TYPE in VARCHAR2
,P_PRORATION_TYPE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_EVENT_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TIME_DEFINITION_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_EVENT_GROUPS_BK1.CREATE_EVENT_GROUP_A', 10);
hr_utility.set_location(' Leaving: PAY_EVENT_GROUPS_BK1.CREATE_EVENT_GROUP_A', 20);
end CREATE_EVENT_GROUP_A;
procedure CREATE_EVENT_GROUP_B
(P_EFFECTIVE_DATE in DATE
,P_EVENT_GROUP_NAME in VARCHAR2
,P_EVENT_GROUP_TYPE in VARCHAR2
,P_PRORATION_TYPE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_TIME_DEFINITION_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_EVENT_GROUPS_BK1.CREATE_EVENT_GROUP_B', 10);
hr_utility.set_location(' Leaving: PAY_EVENT_GROUPS_BK1.CREATE_EVENT_GROUP_B', 20);
end CREATE_EVENT_GROUP_B;
end PAY_EVENT_GROUPS_BK1;

/