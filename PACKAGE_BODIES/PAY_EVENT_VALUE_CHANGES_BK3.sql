--------------------------------------------------------
--  DDL for Package Body PAY_EVENT_VALUE_CHANGES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVENT_VALUE_CHANGES_BK3" as
/* $Header: pyevcapi.pkb 120.0 2005/05/29 04:46:18 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:55 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_EVENT_VALUE_CHANGE_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_EVENT_VALUE_CHANGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PAY_EVENT_VALUE_CHANGES_BK3.DELETE_EVENT_VALUE_CHANGE_A', 10);
hr_utility.set_location(' Leaving: PAY_EVENT_VALUE_CHANGES_BK3.DELETE_EVENT_VALUE_CHANGE_A', 20);
end DELETE_EVENT_VALUE_CHANGE_A;
procedure DELETE_EVENT_VALUE_CHANGE_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_EVENT_VALUE_CHANGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_EVENT_VALUE_CHANGES_BK3.DELETE_EVENT_VALUE_CHANGE_B', 10);
hr_utility.set_location(' Leaving: PAY_EVENT_VALUE_CHANGES_BK3.DELETE_EVENT_VALUE_CHANGE_B', 20);
end DELETE_EVENT_VALUE_CHANGE_B;
end PAY_EVENT_VALUE_CHANGES_BK3;

/