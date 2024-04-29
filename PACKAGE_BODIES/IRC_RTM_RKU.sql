--------------------------------------------------------
--  DDL for Package Body IRC_RTM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RTM_RKU" as
/* $Header: irrtmrhi.pkb 120.3 2008/01/22 10:17:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:58:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_REC_TEAM_MEMBER_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_PARTY_ID in NUMBER
,P_VACANCY_ID in NUMBER
,P_JOB_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_UPDATE_ALLOWED in VARCHAR2
,P_DELETE_ALLOWED in VARCHAR2
,P_INTERVIEW_SECURITY in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_JOB_ID_O in NUMBER
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_UPDATE_ALLOWED_O in VARCHAR2
,P_DELETE_ALLOWED_O in VARCHAR2
,P_INTERVIEW_SECURITY_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_PARTY_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_RTM_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: IRC_RTM_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end IRC_RTM_RKU;

/
