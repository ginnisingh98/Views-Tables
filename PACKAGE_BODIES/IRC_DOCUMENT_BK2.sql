--------------------------------------------------------
--  DDL for Package Body IRC_DOCUMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DOCUMENT_BK2" as
/* $Header: iridoapi.pkb 120.3.12010000.3 2009/04/21 10:41:50 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:52 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_DOCUMENT_A
(P_EFFECTIVE_DATE in DATE
,P_DOCUMENT_ID in NUMBER
,P_TYPE in VARCHAR2
,P_MIME_TYPE in VARCHAR2
,P_FILE_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_document_be2.UPDATE_DOCUMENT_A
(P_EFFECTIVE_DATE => P_EFFECTIVE_DATE
,P_DOCUMENT_ID => P_DOCUMENT_ID
,P_TYPE => P_TYPE
,P_MIME_TYPE => P_MIME_TYPE
,P_FILE_NAME => P_FILE_NAME
,P_DESCRIPTION => P_DESCRIPTION
,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'UPDATE_DOCUMENT', 'AP');
hr_utility.set_location(' Leaving: IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_A', 20);
end UPDATE_DOCUMENT_A;
procedure UPDATE_DOCUMENT_B
(P_EFFECTIVE_DATE in DATE
,P_DOCUMENT_ID in NUMBER
,P_TYPE in VARCHAR2
,P_MIME_TYPE in VARCHAR2
,P_FILE_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_B', 10);
hr_utility.set_location(' Leaving: IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_B', 20);
end UPDATE_DOCUMENT_B;
end IRC_DOCUMENT_BK2;

/
