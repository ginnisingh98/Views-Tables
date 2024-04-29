--------------------------------------------------------
--  DDL for Package Body OTA_FMS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FMS_RKI" as
/* $Header: otfmsrhi.pkb 120.0 2005/06/24 07:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:13 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_FORUM_MESSAGE_ID in NUMBER
,P_FORUM_ID in NUMBER
,P_FORUM_THREAD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_MESSAGE_BODY in VARCHAR2
,P_PARENT_MESSAGE_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_CONTACT_ID in NUMBER
,P_TARGET_PERSON_ID in NUMBER
,P_TARGET_CONTACT_ID in NUMBER
,P_MESSAGE_SCOPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_FMS_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: OTA_FMS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end OTA_FMS_RKI;

/