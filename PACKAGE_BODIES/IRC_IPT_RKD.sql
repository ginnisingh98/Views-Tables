--------------------------------------------------------
--  DDL for Package Body IRC_IPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IPT_RKD" as
/* $Header: iriptrhi.pkb 120.0 2005/07/26 15:10:09 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:06:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_POSTING_CONTENT_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANGUAGE_O in VARCHAR2
,P_NAME_O in VARCHAR2
,P_ORG_NAME_O in VARCHAR2
,P_ORG_DESCRIPTION_O in VARCHAR2
,P_JOB_TITLE_O in VARCHAR2
,P_BRIEF_DESCRIPTION_O in VARCHAR2
,P_DETAILED_DESCRIPTION_O in VARCHAR2
,P_JOB_REQUIREMENTS_O in VARCHAR2
,P_ADDITIONAL_DETAILS_O in VARCHAR2
,P_HOW_TO_APPLY_O in VARCHAR2
,P_BENEFIT_INFO_O in VARCHAR2
,P_IMAGE_URL_O in VARCHAR2
,P_IMAGE_URL_ALT_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_IPT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: IRC_IPT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end IRC_IPT_RKD;

/
