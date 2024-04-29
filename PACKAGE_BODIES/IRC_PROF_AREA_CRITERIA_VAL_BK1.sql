--------------------------------------------------------
--  DDL for Package Body IRC_PROF_AREA_CRITERIA_VAL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PROF_AREA_CRITERIA_VAL_BK1" as
/* $Header: irpcvapi.pkb 120.0 2005/10/03 14:58:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:20 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_PROF_AREA_CRITERIA_A
(P_EFFECTIVE_DATE in DATE
,P_PROF_AREA_CRITERIA_VALUE_ID in NUMBER
,P_SEARCH_CRITERIA_ID in NUMBER
,P_PROFESSIONAL_AREA in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_prof_area_criteria_val_be1.CREATE_PROF_AREA_CRITERIA_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_PROF_AREA_CRITERIA_VALUE_ID => P_PROF_AREA_CRITERIA_VALUE_ID
,P_SEARCH_CRITERIA_ID => P_SEARCH_CRITERIA_ID
,P_PROFESSIONAL_AREA => P_PROFESSIONAL_AREA
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'CREATE_PROF_AREA_CRITERIA', 'AP');
hr_utility.set_location(' Leaving: IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_A', 20);
end CREATE_PROF_AREA_CRITERIA_A;
procedure CREATE_PROF_AREA_CRITERIA_B
(P_EFFECTIVE_DATE in DATE
,P_SEARCH_CRITERIA_ID in NUMBER
,P_PROFESSIONAL_AREA in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_B', 10);
hr_utility.set_location(' Leaving: IRC_PROF_AREA_CRITERIA_VAL_BK1.CREATE_PROF_AREA_CRITERIA_B', 20);
end CREATE_PROF_AREA_CRITERIA_B;
end IRC_PROF_AREA_CRITERIA_VAL_BK1;

/