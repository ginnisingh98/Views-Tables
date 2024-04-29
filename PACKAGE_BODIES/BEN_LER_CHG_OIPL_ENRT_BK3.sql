--------------------------------------------------------
--  DDL for Package Body BEN_LER_CHG_OIPL_ENRT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_CHG_OIPL_ENRT_BK3" as
/* $Header: belopapi.pkb 115.5 2002/12/13 06:56:08 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:47 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_LER_CHG_OIPL_ENRT_A
(P_LER_CHG_OIPL_ENRT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LER_CHG_OIPL_ENRT_BK3.DELETE_LER_CHG_OIPL_ENRT_A', 10);
hr_utility.set_location(' Leaving: BEN_LER_CHG_OIPL_ENRT_BK3.DELETE_LER_CHG_OIPL_ENRT_A', 20);
end DELETE_LER_CHG_OIPL_ENRT_A;
procedure DELETE_LER_CHG_OIPL_ENRT_B
(P_LER_CHG_OIPL_ENRT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LER_CHG_OIPL_ENRT_BK3.DELETE_LER_CHG_OIPL_ENRT_B', 10);
hr_utility.set_location(' Leaving: BEN_LER_CHG_OIPL_ENRT_BK3.DELETE_LER_CHG_OIPL_ENRT_B', 20);
end DELETE_LER_CHG_OIPL_ENRT_B;
end BEN_LER_CHG_OIPL_ENRT_BK3;

/
