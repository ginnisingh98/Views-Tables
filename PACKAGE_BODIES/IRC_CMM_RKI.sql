--------------------------------------------------------
--  DDL for Package Body IRC_CMM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMM_RKI" as
/* $Header: ircmmrhi.pkb 120.2 2008/04/14 14:50:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_COMMUNICATION_MESSAGE_ID in NUMBER
,P_PARENT_ID in NUMBER
,P_COMMUNICATION_TOPIC_ID in NUMBER
,P_MESSAGE_SUBJECT in VARCHAR2
,P_MESSAGE_BODY in VARCHAR2
,P_MESSAGE_POST_DATE in DATE
,P_SENDER_TYPE in VARCHAR2
,P_SENDER_ID in NUMBER
,P_DOCUMENT_TYPE in VARCHAR2
,P_DOCUMENT_ID in NUMBER
,P_DELETED_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_CMM_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: IRC_CMM_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end IRC_CMM_RKI;

/