--------------------------------------------------------
--  DDL for Package Body BEN_PERIOD_LIMIT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERIOD_LIMIT_BK3" as
/* $Header: bepdlapi.pkb 120.0 2005/05/28 10:26:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:15 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PERIOD_LIMIT_A
(P_PTD_LMT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERIOD_LIMIT_BK3.DELETE_PERIOD_LIMIT_A', 10);
hr_utility.set_location(' Leaving: BEN_PERIOD_LIMIT_BK3.DELETE_PERIOD_LIMIT_A', 20);
end DELETE_PERIOD_LIMIT_A;
procedure DELETE_PERIOD_LIMIT_B
(P_PTD_LMT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERIOD_LIMIT_BK3.DELETE_PERIOD_LIMIT_B', 10);
hr_utility.set_location(' Leaving: BEN_PERIOD_LIMIT_BK3.DELETE_PERIOD_LIMIT_B', 20);
end DELETE_PERIOD_LIMIT_B;
end BEN_PERIOD_LIMIT_BK3;

/