--------------------------------------------------------
--  DDL for Package Body PAY_PPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPE_BK2" as
/* $Header: pyppeapi.pkb 120.2.12010000.1 2008/07/27 23:25:01 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:33 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PROCESS_EVENT_A
(P_PROCESS_EVENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CHANGE_TYPE in VARCHAR2
,P_STATUS in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_EVENT_UPDATE_ID in NUMBER
,P_ORG_PROCESS_EVENT_GROUP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SURROGATE_KEY in VARCHAR2
,P_CALCULATION_DATE in DATE
,P_RETROACTIVE_STATUS in VARCHAR2
,P_NOTED_VALUE in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PAY_PPE_BK2.UPDATE_PROCESS_EVENT_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
pay_ppe_be2.UPDATE_PROCESS_EVENT_A
(P_PROCESS_EVENT_ID => P_PROCESS_EVENT_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
,P_ASSIGNMENT_ID => P_ASSIGNMENT_ID
,P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_CHANGE_TYPE => P_CHANGE_TYPE
,P_STATUS => P_STATUS
,P_DESCRIPTION => P_DESCRIPTION
,P_EVENT_UPDATE_ID => P_EVENT_UPDATE_ID
,P_ORG_PROCESS_EVENT_GROUP_ID => P_ORG_PROCESS_EVENT_GROUP_ID
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_SURROGATE_KEY => P_SURROGATE_KEY
,P_CALCULATION_DATE => P_CALCULATION_DATE
,P_RETROACTIVE_STATUS => P_RETROACTIVE_STATUS
,P_NOTED_VALUE => P_NOTED_VALUE
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_PROCESS_EVENT', 'AP');
hr_utility.set_location(' Leaving: PAY_PPE_BK2.UPDATE_PROCESS_EVENT_A', 20);
end UPDATE_PROCESS_EVENT_A;
procedure UPDATE_PROCESS_EVENT_B
(P_PROCESS_EVENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CHANGE_TYPE in VARCHAR2
,P_STATUS in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_EVENT_UPDATE_ID in NUMBER
,P_ORG_PROCESS_EVENT_GROUP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SURROGATE_KEY in VARCHAR2
,P_CALCULATION_DATE in DATE
,P_RETROACTIVE_STATUS in VARCHAR2
,P_NOTED_VALUE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PPE_BK2.UPDATE_PROCESS_EVENT_B', 10);
hr_utility.set_location(' Leaving: PAY_PPE_BK2.UPDATE_PROCESS_EVENT_B', 20);
end UPDATE_PROCESS_EVENT_B;
end PAY_PPE_BK2;

/