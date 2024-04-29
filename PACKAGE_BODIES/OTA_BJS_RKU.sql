--------------------------------------------------------
--  DDL for Package Body OTA_BJS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BJS_RKU" as
/* $Header: otbjsrhi.pkb 120.0 2005/05/29 07:02:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:02 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_BOOKING_JUSTIFICATION_ID in NUMBER
,P_PRIORITY_LEVEL in VARCHAR2
,P_START_DATE_ACTIVE in DATE
,P_END_DATE_ACTIVE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PRIORITY_LEVEL_O in VARCHAR2
,P_START_DATE_ACTIVE_O in DATE
,P_END_DATE_ACTIVE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_BJS_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_BJS_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_BJS_RKU;

/