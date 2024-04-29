--------------------------------------------------------
--  DDL for Package Body HR_MAINTAIN_PROPOSAL_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MAINTAIN_PROPOSAL_BK7" as
/* $Header: hrpypapi.pkb 120.30.12010000.13 2009/01/16 09:51:09 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PROPOSAL_COMPONENT_A
(P_COMPONENT_ID in NUMBER
,P_VALIDATION_STRENGTH in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_MAINTAIN_PROPOSAL_BK7.DELETE_PROPOSAL_COMPONENT_A', 10);
hr_utility.set_location(' Leaving: HR_MAINTAIN_PROPOSAL_BK7.DELETE_PROPOSAL_COMPONENT_A', 20);
end DELETE_PROPOSAL_COMPONENT_A;
procedure DELETE_PROPOSAL_COMPONENT_B
(P_COMPONENT_ID in NUMBER
,P_VALIDATION_STRENGTH in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_MAINTAIN_PROPOSAL_BK7.DELETE_PROPOSAL_COMPONENT_B', 10);
hr_utility.set_location(' Leaving: HR_MAINTAIN_PROPOSAL_BK7.DELETE_PROPOSAL_COMPONENT_B', 20);
end DELETE_PROPOSAL_COMPONENT_B;
end HR_MAINTAIN_PROPOSAL_BK7;

/