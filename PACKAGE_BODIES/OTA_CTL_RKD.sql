--------------------------------------------------------
--  DDL for Package Body OTA_CTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CTL_RKD" as
/* $Header: otctlrhi.pkb 120.2 2005/12/01 16:42 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CERTIFICATION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
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
hr_utility.set_location('Entering: OTA_CTL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_CTL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_CTL_RKD;

/