--------------------------------------------------------
--  DDL for Package Body PER_SOLUTION_TYPE_CMPT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SOLUTION_TYPE_CMPT_BK2" as
/* $Header: pestcapi.pkb 120.0 2005/05/31 21:56:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:22 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_SOLUTION_TYPE_CMPT_A
(P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_COMPONENT_NAME in VARCHAR2
,P_SOLUTION_TYPE_NAME in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_API_NAME in VARCHAR2
,P_PARENT_COMPONENT_NAME in VARCHAR2
,P_UPDATEABLE in VARCHAR2
,P_EXTENSIBLE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_A', 10);
hr_utility.set_location(' Leaving: PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_A', 20);
end UPDATE_SOLUTION_TYPE_CMPT_A;
procedure UPDATE_SOLUTION_TYPE_CMPT_B
(P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_COMPONENT_NAME in VARCHAR2
,P_SOLUTION_TYPE_NAME in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_API_NAME in VARCHAR2
,P_PARENT_COMPONENT_NAME in VARCHAR2
,P_UPDATEABLE in VARCHAR2
,P_EXTENSIBLE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_B', 10);
hr_utility.set_location(' Leaving: PER_SOLUTION_TYPE_CMPT_BK2.UPDATE_SOLUTION_TYPE_CMPT_B', 20);
end UPDATE_SOLUTION_TYPE_CMPT_B;
end PER_SOLUTION_TYPE_CMPT_BK2;

/
