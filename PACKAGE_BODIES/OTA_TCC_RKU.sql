--------------------------------------------------------
--  DDL for Package Body OTA_TCC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TCC_RKU" as
/* $Header: ottccrhi.pkb 120.1 2005/09/01 07:26:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CROSS_CHARGE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_GL_SET_OF_BOOKS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TYPE in VARCHAR2
,P_FROM_TO in VARCHAR2
,P_START_DATE_ACTIVE in DATE
,P_END_DATE_ACTIVE in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_GL_SET_OF_BOOKS_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_TYPE_O in VARCHAR2
,P_FROM_TO_O in VARCHAR2
,P_START_DATE_ACTIVE_O in DATE
,P_END_DATE_ACTIVE_O in DATE
)is
begin
hr_utility.set_location('Entering: OTA_TCC_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_TCC_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_TCC_RKU;

/
