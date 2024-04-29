--------------------------------------------------------
--  DDL for Package Body IRC_IRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRT_RKD" as
/* $Header: irirtrhi.pkb 120.0 2005/07/26 15:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:06:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_RECRUITING_SITE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_SITE_NAME_O in VARCHAR2
,P_REDIRECTION_URL_O in VARCHAR2
,P_POSTING_URL_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_IRT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: IRC_IRT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end IRC_IRT_RKD;

/