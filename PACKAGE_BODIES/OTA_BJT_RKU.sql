--------------------------------------------------------
--  DDL for Package Body OTA_BJT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BJT_RKU" as
/* $Header: otbjtrhi.pkb 120.0 2005/05/29 07:03:39 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:03 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_BOOKING_JUSTIFICATION_ID in NUMBER
,P_JUSTIFICATION_TEXT in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_LANGUAGE in VARCHAR2
,P_JUSTIFICATION_TEXT_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_BJT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_BJT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_BJT_RKU;

/