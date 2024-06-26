--------------------------------------------------------
--  DDL for Package Body OTA_FORUM_MESSAGE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FORUM_MESSAGE_BK2" as
/* $Header: otfmsapi.pkb 120.4 2005/09/26 02:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:13 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_FORUM_MESSAGE_A
(P_EFFECTIVE_DATE in DATE
,P_FORUM_ID in NUMBER
,P_FORUM_THREAD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_MESSAGE_SCOPE in VARCHAR2
,P_MESSAGE_BODY in VARCHAR2
,P_PARENT_MESSAGE_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_CONTACT_ID in NUMBER
,P_TARGET_PERSON_ID in NUMBER
,P_TARGET_CONTACT_ID in NUMBER
,P_FORUM_MESSAGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_FORUM_MESSAGE_BK2.UPDATE_FORUM_MESSAGE_A', 10);
hr_utility.set_location(' Leaving: OTA_FORUM_MESSAGE_BK2.UPDATE_FORUM_MESSAGE_A', 20);
end UPDATE_FORUM_MESSAGE_A;
procedure UPDATE_FORUM_MESSAGE_B
(P_EFFECTIVE_DATE in DATE
,P_FORUM_ID in NUMBER
,P_FORUM_THREAD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_MESSAGE_SCOPE in VARCHAR2
,P_MESSAGE_BODY in VARCHAR2
,P_PARENT_MESSAGE_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_CONTACT_ID in NUMBER
,P_TARGET_PERSON_ID in NUMBER
,P_TARGET_CONTACT_ID in NUMBER
,P_FORUM_MESSAGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_FORUM_MESSAGE_BK2.UPDATE_FORUM_MESSAGE_B', 10);
hr_utility.set_location(' Leaving: OTA_FORUM_MESSAGE_BK2.UPDATE_FORUM_MESSAGE_B', 20);
end UPDATE_FORUM_MESSAGE_B;
end OTA_FORUM_MESSAGE_BK2;

/
