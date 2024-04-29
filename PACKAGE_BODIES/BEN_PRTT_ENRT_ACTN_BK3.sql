--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_ENRT_ACTN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_ENRT_ACTN_BK3" as
/* $Header: bepeaapi.pkb 120.2.12000000.2 2007/01/29 16:31:09 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2008/10/18 16:31:46 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PRTT_ENRT_ACTN_A
(P_PRTT_ENRT_ACTN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_ENRT_ACTN_BK3.DELETE_PRTT_ENRT_ACTN_A', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_ENRT_ACTN_BK3.DELETE_PRTT_ENRT_ACTN_A', 20);
end DELETE_PRTT_ENRT_ACTN_A;
procedure DELETE_PRTT_ENRT_ACTN_B
(P_PRTT_ENRT_ACTN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_ENRT_ACTN_BK3.DELETE_PRTT_ENRT_ACTN_B', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_ENRT_ACTN_BK3.DELETE_PRTT_ENRT_ACTN_B', 20);
end DELETE_PRTT_ENRT_ACTN_B;
end BEN_PRTT_ENRT_ACTN_BK3;

/