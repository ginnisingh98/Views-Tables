--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_PEOPLE_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_PEOPLE_BK_2" as
/* $Header: ghcplapi.pkb 120.0 2005/10/02 01:57:40 generated $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:52:58 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_COMPL_PERSON_A
(P_EFFECTIVE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_COMPLAINT_ID in NUMBER
,P_ROLE_CODE in VARCHAR2
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_COMPL_PERSON_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINT_PEOPLE_BK_2.UPDATE_COMPL_PERSON_A', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINT_PEOPLE_BK_2.UPDATE_COMPL_PERSON_A', 20);
end UPDATE_COMPL_PERSON_A;
procedure UPDATE_COMPL_PERSON_B
(P_EFFECTIVE_DATE in DATE
,P_PERSON_ID in NUMBER
,P_COMPLAINT_ID in NUMBER
,P_ROLE_CODE in VARCHAR2
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_COMPL_PERSON_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_COMPLAINT_PEOPLE_BK_2.UPDATE_COMPL_PERSON_B', 10);
hr_utility.set_location(' Leaving: GHR_COMPLAINT_PEOPLE_BK_2.UPDATE_COMPL_PERSON_B', 20);
end UPDATE_COMPL_PERSON_B;
end GHR_COMPLAINT_PEOPLE_BK_2;

/