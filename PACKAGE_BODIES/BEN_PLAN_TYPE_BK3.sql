--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_TYPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_TYPE_BK3" as
/* $Header: beptpapi.pkb 115.11 2003/09/25 00:34:48 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:43 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PLAN_TYPE_A
(P_PL_TYP_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_TYPE_BK3.DELETE_PLAN_TYPE_A', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_TYPE_BK3.DELETE_PLAN_TYPE_A', 20);
end DELETE_PLAN_TYPE_A;
procedure DELETE_PLAN_TYPE_B
(P_PL_TYP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_TYPE_BK3.DELETE_PLAN_TYPE_B', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_TYPE_BK3.DELETE_PLAN_TYPE_B', 20);
end DELETE_PLAN_TYPE_B;
end BEN_PLAN_TYPE_BK3;

/