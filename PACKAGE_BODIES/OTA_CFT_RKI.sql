--------------------------------------------------------
--  DDL for Package Body OTA_CFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CFT_RKI" as
/* $Header: otcftrhi.pkb 120.0 2005/05/29 07:06 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:04 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CONFERENCE_SERVER_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CFT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: OTA_CFT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end OTA_CFT_RKI;

/
