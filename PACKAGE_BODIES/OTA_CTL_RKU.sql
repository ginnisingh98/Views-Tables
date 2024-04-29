--------------------------------------------------------
--  DDL for Package Body OTA_CTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTL_RKU" as
/* $Header: otctlrhi.pkb 120.2 2005/12/01 16:42 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CERTIFICATION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_OBJECTIVES in VARCHAR2
,P_PURPOSE in VARCHAR2
,P_KEYWORDS in VARCHAR2
,P_END_DATE_COMMENTS in VARCHAR2
,P_INITIAL_PERIOD_COMMENTS in VARCHAR2
,P_RENEWAL_PERIOD_COMMENTS in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_OBJECTIVES_O in VARCHAR2
,P_PURPOSE_O in VARCHAR2
,P_KEYWORDS_O in VARCHAR2
,P_END_DATE_COMMENTS_O in VARCHAR2
,P_INITIAL_PERIOD_COMMENTS_O in VARCHAR2
,P_RENEWAL_PERIOD_COMMENTS_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_CTL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: OTA_CTL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end OTA_CTL_RKU;

/