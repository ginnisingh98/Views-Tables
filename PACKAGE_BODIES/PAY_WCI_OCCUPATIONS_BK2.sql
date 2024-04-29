--------------------------------------------------------
--  DDL for Package Body PAY_WCI_OCCUPATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WCI_OCCUPATIONS_BK2" as
/* $Header: pypwoapi.pkb 115.2 2002/12/05 14:58:06 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:20 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_WCI_OCCUPATION_A
(P_EFFECTIVE_DATE in DATE
,P_OCCUPATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_JOB_ID in NUMBER
,P_COMMENTS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_WCI_OCCUPATIONS_BK2.UPDATE_WCI_OCCUPATION_A', 10);
hr_utility.set_location(' Leaving: PAY_WCI_OCCUPATIONS_BK2.UPDATE_WCI_OCCUPATION_A', 20);
end UPDATE_WCI_OCCUPATION_A;
procedure UPDATE_WCI_OCCUPATION_B
(P_EFFECTIVE_DATE in DATE
,P_OCCUPATION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_RATE_ID in NUMBER
,P_JOB_ID in NUMBER
,P_COMMENTS in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_WCI_OCCUPATIONS_BK2.UPDATE_WCI_OCCUPATION_B', 10);
hr_utility.set_location(' Leaving: PAY_WCI_OCCUPATIONS_BK2.UPDATE_WCI_OCCUPATION_B', 20);
end UPDATE_WCI_OCCUPATION_B;
end PAY_WCI_OCCUPATIONS_BK2;

/