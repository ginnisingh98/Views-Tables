--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_REGULATION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_REGULATION_BK3" as
/* $Header: beprgapi.pkb 115.3 2002/12/16 07:24:07 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:36 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PLAN_REGULATION_A
(P_PL_REGN_ID in NUMBER
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_REGULATION_BK3.DELETE_PLAN_REGULATION_A', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_REGULATION_BK3.DELETE_PLAN_REGULATION_A', 20);
end DELETE_PLAN_REGULATION_A;
procedure DELETE_PLAN_REGULATION_B
(P_PL_REGN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_REGULATION_BK3.DELETE_PLAN_REGULATION_B', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_REGULATION_BK3.DELETE_PLAN_REGULATION_B', 20);
end DELETE_PLAN_REGULATION_B;
end BEN_PLAN_REGULATION_BK3;

/
