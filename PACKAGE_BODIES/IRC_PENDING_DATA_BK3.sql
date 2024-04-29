--------------------------------------------------------
--  DDL for Package Body IRC_PENDING_DATA_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PENDING_DATA_BK3" as
/* $Header: iripdapi.pkb 120.15 2008/01/21 14:58:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:21 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PENDING_DATA_A
(P_PENDING_DATA_ID in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_pending_data_be3.DELETE_PENDING_DATA_A
(P_PENDING_DATA_ID => P_PENDING_DATA_ID
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'DELETE_PENDING_DATA', 'AP');
hr_utility.set_location(' Leaving: IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_A', 20);
end DELETE_PENDING_DATA_A;
procedure DELETE_PENDING_DATA_B
(P_PENDING_DATA_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_B', 10);
hr_utility.set_location(' Leaving: IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_B', 20);
end DELETE_PENDING_DATA_B;
end IRC_PENDING_DATA_BK3;

/
