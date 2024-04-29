--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_CVRD_DPNT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_CVRD_DPNT_BK3" as
/* $Header: bepdpapi.pkb 120.7.12000000.2 2007/01/29 16:20:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2008/10/18 16:31:44 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ELIG_CVRD_DPNT_A
(P_ELIG_CVRD_DPNT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_CVRD_DPNT_BK3.DELETE_ELIG_CVRD_DPNT_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_CVRD_DPNT_BK3.DELETE_ELIG_CVRD_DPNT_A', 20);
end DELETE_ELIG_CVRD_DPNT_A;
procedure DELETE_ELIG_CVRD_DPNT_B
(P_ELIG_CVRD_DPNT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_CVRD_DPNT_BK3.DELETE_ELIG_CVRD_DPNT_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_CVRD_DPNT_BK3.DELETE_ELIG_CVRD_DPNT_B', 20);
end DELETE_ELIG_CVRD_DPNT_B;
end BEN_ELIG_CVRD_DPNT_BK3;

/
