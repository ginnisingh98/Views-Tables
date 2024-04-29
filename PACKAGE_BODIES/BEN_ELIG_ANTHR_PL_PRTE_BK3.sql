--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_ANTHR_PL_PRTE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_ANTHR_PL_PRTE_BK3" as
/* $Header: beeopapi.pkb 115.1 2002/12/16 17:36:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:11 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ELIG_ANTHR_PL_PRTE_A
(P_ELIG_ANTHR_PL_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_ANTHR_PL_PRTE_BK3.DELETE_ELIG_ANTHR_PL_PRTE_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_ANTHR_PL_PRTE_BK3.DELETE_ELIG_ANTHR_PL_PRTE_A', 20);
end DELETE_ELIG_ANTHR_PL_PRTE_A;
procedure DELETE_ELIG_ANTHR_PL_PRTE_B
(P_ELIG_ANTHR_PL_PRTE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_ANTHR_PL_PRTE_BK3.DELETE_ELIG_ANTHR_PL_PRTE_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_ANTHR_PL_PRTE_BK3.DELETE_ELIG_ANTHR_PL_PRTE_B', 20);
end DELETE_ELIG_ANTHR_PL_PRTE_B;
end BEN_ELIG_ANTHR_PL_PRTE_BK3;

/
