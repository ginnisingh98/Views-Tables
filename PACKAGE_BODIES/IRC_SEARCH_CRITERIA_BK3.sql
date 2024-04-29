--------------------------------------------------------
--  DDL for Package Body IRC_SEARCH_CRITERIA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SEARCH_CRITERIA_BK3" as
/* $Header: iriscapi.pkb 120.0 2005/07/26 15:10:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:21 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_SAVED_SEARCH_A
(P_SEARCH_CRITERIA_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_search_criteria_be3.DELETE_SAVED_SEARCH_A
(P_SEARCH_CRITERIA_ID => P_SEARCH_CRITERIA_ID
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'DELETE_SAVED_SEARCH', 'AP');
hr_utility.set_location(' Leaving: IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_A', 20);
end DELETE_SAVED_SEARCH_A;
procedure DELETE_SAVED_SEARCH_B
(P_SEARCH_CRITERIA_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_B', 10);
hr_utility.set_location(' Leaving: IRC_SEARCH_CRITERIA_BK3.DELETE_SAVED_SEARCH_B', 20);
end DELETE_SAVED_SEARCH_B;
end IRC_SEARCH_CRITERIA_BK3;

/
