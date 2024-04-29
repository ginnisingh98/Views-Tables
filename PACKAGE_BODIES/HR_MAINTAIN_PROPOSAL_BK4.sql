--------------------------------------------------------
--  DDL for Package Body HR_MAINTAIN_PROPOSAL_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MAINTAIN_PROPOSAL_BK4" as
/* $Header: hrpypapi.pkb 120.30.12010000.13 2009/01/16 09:51:09 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_SALARY_PROPOSAL_A
(P_PAY_PROPOSAL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_SALARY_WARNING in BOOLEAN
)is
begin
hr_utility.set_location('Entering: HR_MAINTAIN_PROPOSAL_BK4.DELETE_SALARY_PROPOSAL_A', 10);
hr_utility.set_location(' Leaving: HR_MAINTAIN_PROPOSAL_BK4.DELETE_SALARY_PROPOSAL_A', 20);
end DELETE_SALARY_PROPOSAL_A;
procedure DELETE_SALARY_PROPOSAL_B
(P_PAY_PROPOSAL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_MAINTAIN_PROPOSAL_BK4.DELETE_SALARY_PROPOSAL_B', 10);
hr_utility.set_location(' Leaving: HR_MAINTAIN_PROPOSAL_BK4.DELETE_SALARY_PROPOSAL_B', 20);
end DELETE_SALARY_PROPOSAL_B;
end HR_MAINTAIN_PROPOSAL_BK4;

/
