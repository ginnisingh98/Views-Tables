--------------------------------------------------------
--  DDL for Package Body BEN_COMP_LEVEL_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_LEVEL_RATE_BK3" as
/* $Header: beclrapi.pkb 115.4 2002/12/31 23:56:50 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:06 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_COMP_LEVEL_RATE_A
(P_COMP_LVL_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_COMP_LEVEL_RATE_BK3.DELETE_COMP_LEVEL_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_COMP_LEVEL_RATE_BK3.DELETE_COMP_LEVEL_RATE_A', 20);
end DELETE_COMP_LEVEL_RATE_A;
procedure DELETE_COMP_LEVEL_RATE_B
(P_COMP_LVL_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_COMP_LEVEL_RATE_BK3.DELETE_COMP_LEVEL_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_COMP_LEVEL_RATE_BK3.DELETE_COMP_LEVEL_RATE_B', 20);
end DELETE_COMP_LEVEL_RATE_B;
end BEN_COMP_LEVEL_RATE_BK3;

/
