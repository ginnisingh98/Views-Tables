--------------------------------------------------------
--  DDL for Package Body IRC_SAVED_SEARCH_CRITERIA_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SAVED_SEARCH_CRITERIA_BK2" as
/* $Header: irissapi.pkb 120.0.12000000.1 2007/03/23 11:17:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:20 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_SEARCH_CRITERIA_A
(P_VACANCY_ID in NUMBER
,P_SAVED_SEARCH_CRITERIA_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_SAVED_SEARCH_CRITERIA_BK2.UPDATE_SEARCH_CRITERIA_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_saved_search_criteria_be2.UPDATE_SEARCH_CRITERIA_A
(P_VACANCY_ID => P_VACANCY_ID
,P_SAVED_SEARCH_CRITERIA_ID => P_SAVED_SEARCH_CRITERIA_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_SEARCH_CRITERIA', 'AP');
hr_utility.set_location(' Leaving: IRC_SAVED_SEARCH_CRITERIA_BK2.UPDATE_SEARCH_CRITERIA_A', 20);
end UPDATE_SEARCH_CRITERIA_A;
procedure UPDATE_SEARCH_CRITERIA_B
(P_VACANCY_ID in NUMBER
,P_SAVED_SEARCH_CRITERIA_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_SAVED_SEARCH_CRITERIA_BK2.UPDATE_SEARCH_CRITERIA_B', 10);
hr_utility.set_location(' Leaving: IRC_SAVED_SEARCH_CRITERIA_BK2.UPDATE_SEARCH_CRITERIA_B', 20);
end UPDATE_SEARCH_CRITERIA_B;
end IRC_SAVED_SEARCH_CRITERIA_BK2;

/
