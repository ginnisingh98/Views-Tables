--------------------------------------------------------
--  DDL for Package Body PAY_PBF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBF_RKI" as
/* $Header: pypbfrhi.pkb 120.1 2005/08/02 12:12:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:50:28 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_BALANCE_FEED_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_BALANCE_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_SCALE in NUMBER
,P_LEGISLATION_SUBGROUP in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: PAY_PBF_RKI.AFTER_INSERT', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_leg_hooks then
l_legislation_code := PAY_PBF_BUS.RETURN_LEGISLATION_CODE(P_BALANCE_FEED_ID => P_BALANCE_FEED_ID
);
if l_legislation_code = 'US' then
PAY_US_BALANCE_FEEDS_HOOK.INSERT_USER_HOOK
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_BALANCE_TYPE_ID => P_BALANCE_TYPE_ID
,P_INPUT_VALUE_ID => P_INPUT_VALUE_ID
,P_SCALE => P_SCALE
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LEGISLATION_CODE => P_LEGISLATION_CODE
);
end if;
end if;
hr_api.validate_commit_unit(l_commit_unit_number, 'PAY_BALANCE_FEEDS_F', 'AI');
hr_utility.set_location(' Leaving: PAY_PBF_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_PBF_RKI;

/