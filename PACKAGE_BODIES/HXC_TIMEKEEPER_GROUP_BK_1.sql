--------------------------------------------------------
--  DDL for Package Body HXC_TIMEKEEPER_GROUP_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMEKEEPER_GROUP_BK_1" as
/* $Header: hxctkgapi.pkb 120.0 2005/05/29 06:01:34 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:04 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_TIMEKEEPER_GROUP_A
(P_TK_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TK_GROUP_NAME in VARCHAR2
,P_TK_RESOURCE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_TIMEKEEPER_GROUP_BK_1.CREATE_TIMEKEEPER_GROUP_A', 10);
hr_utility.set_location(' Leaving: HXC_TIMEKEEPER_GROUP_BK_1.CREATE_TIMEKEEPER_GROUP_A', 20);
end CREATE_TIMEKEEPER_GROUP_A;
procedure CREATE_TIMEKEEPER_GROUP_B
(P_TK_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TK_GROUP_NAME in VARCHAR2
,P_TK_RESOURCE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_TIMEKEEPER_GROUP_BK_1.CREATE_TIMEKEEPER_GROUP_B', 10);
hr_utility.set_location(' Leaving: HXC_TIMEKEEPER_GROUP_BK_1.CREATE_TIMEKEEPER_GROUP_B', 20);
end CREATE_TIMEKEEPER_GROUP_B;
end HXC_TIMEKEEPER_GROUP_BK_1;

/