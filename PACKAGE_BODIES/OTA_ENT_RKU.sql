--------------------------------------------------------
--  DDL for Package Body OTA_ENT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ENT_RKU" as
/* $Header: otentrhi.pkb 115.1 2003/04/24 17:25:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:12 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_EVENT_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_TITLE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_TITLE_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_ENT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_ENT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_ENT_RKU;

/