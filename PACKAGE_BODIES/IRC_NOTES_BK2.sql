--------------------------------------------------------
--  DDL for Package Body IRC_NOTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTES_BK2" as
/* $Header: irinoapi.pkb 120.0 2005/09/27 09:08:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:20 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_NOTE_A
(P_NOTE_ID in NUMBER
,P_OFFER_STATUS_HISTORY_ID in NUMBER
,P_NOTE_TEXT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_NOTES_BK2.UPDATE_NOTE_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_notes_be2.UPDATE_NOTE_A
(P_NOTE_ID => P_NOTE_ID
,P_OFFER_STATUS_HISTORY_ID => P_OFFER_STATUS_HISTORY_ID
,P_NOTE_TEXT => P_NOTE_TEXT
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_NOTE', 'AP');
hr_utility.set_location(' Leaving: IRC_NOTES_BK2.UPDATE_NOTE_A', 20);
end UPDATE_NOTE_A;
procedure UPDATE_NOTE_B
(P_NOTE_ID in NUMBER
,P_OFFER_STATUS_HISTORY_ID in NUMBER
,P_NOTE_TEXT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_NOTES_BK2.UPDATE_NOTE_B', 10);
hr_utility.set_location(' Leaving: IRC_NOTES_BK2.UPDATE_NOTE_B', 20);
end UPDATE_NOTE_B;
end IRC_NOTES_BK2;

/
