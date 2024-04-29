--------------------------------------------------------
--  DDL for Package Body BEN_ELG_PRT_ANTHR_PL_PT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELG_PRT_ANTHR_PL_PT_BK3" as
/* $Header: beeppapi.pkb 115.3 2002/12/11 10:42:19 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:17 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ELG_PRT_ANTHR_PL_PT_A
(P_ELIG_PRTT_ANTHR_PL_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELG_PRT_ANTHR_PL_PT_BK3.DELETE_ELG_PRT_ANTHR_PL_PT_A', 10);
hr_utility.set_location(' Leaving: BEN_ELG_PRT_ANTHR_PL_PT_BK3.DELETE_ELG_PRT_ANTHR_PL_PT_A', 20);
end DELETE_ELG_PRT_ANTHR_PL_PT_A;
procedure DELETE_ELG_PRT_ANTHR_PL_PT_B
(P_ELIG_PRTT_ANTHR_PL_PRTE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELG_PRT_ANTHR_PL_PT_BK3.DELETE_ELG_PRT_ANTHR_PL_PT_B', 10);
hr_utility.set_location(' Leaving: BEN_ELG_PRT_ANTHR_PL_PT_BK3.DELETE_ELG_PRT_ANTHR_PL_PT_B', 20);
end DELETE_ELG_PRT_ANTHR_PL_PT_B;
end BEN_ELG_PRT_ANTHR_PL_PT_BK3;

/