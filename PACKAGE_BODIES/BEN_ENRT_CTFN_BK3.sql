--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_CTFN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_CTFN_BK3" as
/* $Header: beecfapi.pkb 120.0 2005/05/28 01:49:40 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:41 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ENRT_CTFN_A
(P_ENRT_CTFN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRT_CTFN_BK3.DELETE_ENRT_CTFN_A', 10);
hr_utility.set_location(' Leaving: BEN_ENRT_CTFN_BK3.DELETE_ENRT_CTFN_A', 20);
end DELETE_ENRT_CTFN_A;
procedure DELETE_ENRT_CTFN_B
(P_ENRT_CTFN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ENRT_CTFN_BK3.DELETE_ENRT_CTFN_B', 10);
hr_utility.set_location(' Leaving: BEN_ENRT_CTFN_BK3.DELETE_ENRT_CTFN_B', 20);
end DELETE_ENRT_CTFN_B;
end BEN_ENRT_CTFN_BK3;

/