--------------------------------------------------------
--  DDL for Package Body OTA_CHA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHA_RKI" as
/* $Header: otcharhi.pkb 120.3 2006/03/06 02:27 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:05 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CHAT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PUBLIC_FLAG in VARCHAR2
,P_START_DATE_ACTIVE in DATE
,P_END_DATE_ACTIVE in DATE
,P_START_TIME_ACTIVE in VARCHAR2
,P_END_TIME_ACTIVE in VARCHAR2
,P_TIMEZONE_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CHA_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: OTA_CHA_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end OTA_CHA_RKI;

/
