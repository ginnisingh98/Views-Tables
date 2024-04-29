--------------------------------------------------------
--  DDL for Package Body BEN_ENRLD_ANTHR_PLIP_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRLD_ANTHR_PLIP_RT_BK3" as
/* $Header: beearapi.pkb 115.1 2002/12/16 09:36:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:37 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ENRLD_ANTHR_PLIP_RT_A
(P_ENRLD_ANTHR_PLIP_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRLD_ANTHR_PLIP_RT_BK3.DELETE_ENRLD_ANTHR_PLIP_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_ENRLD_ANTHR_PLIP_RT_BK3.DELETE_ENRLD_ANTHR_PLIP_RT_A', 20);
end DELETE_ENRLD_ANTHR_PLIP_RT_A;
procedure DELETE_ENRLD_ANTHR_PLIP_RT_B
(P_ENRLD_ANTHR_PLIP_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRLD_ANTHR_PLIP_RT_BK3.DELETE_ENRLD_ANTHR_PLIP_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_ENRLD_ANTHR_PLIP_RT_BK3.DELETE_ENRLD_ANTHR_PLIP_RT_B', 20);
end DELETE_ENRLD_ANTHR_PLIP_RT_B;
end BEN_ENRLD_ANTHR_PLIP_RT_BK3;

/
