--------------------------------------------------------
--  DDL for Package Body BEN_TOBACCO_USE_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TOBACCO_USE_RATE_BK3" as
/* $Header: beturapi.pkb 120.0 2005/05/28 11:58:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:58 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_TOBACCO_USE_RATE_A
(P_TBCO_USE_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_TOBACCO_USE_RATE_BK3.DELETE_TOBACCO_USE_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_TOBACCO_USE_RATE_BK3.DELETE_TOBACCO_USE_RATE_A', 20);
end DELETE_TOBACCO_USE_RATE_A;
procedure DELETE_TOBACCO_USE_RATE_B
(P_TBCO_USE_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_TOBACCO_USE_RATE_BK3.DELETE_TOBACCO_USE_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_TOBACCO_USE_RATE_BK3.DELETE_TOBACCO_USE_RATE_B', 20);
end DELETE_TOBACCO_USE_RATE_B;
end BEN_TOBACCO_USE_RATE_BK3;

/