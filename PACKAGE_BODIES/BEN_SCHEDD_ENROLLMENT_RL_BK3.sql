--------------------------------------------------------
--  DDL for Package Body BEN_SCHEDD_ENROLLMENT_RL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SCHEDD_ENROLLMENT_RL_BK3" as
/* $Header: beserapi.pkb 115.4 2003/01/16 14:36:05 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:56 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_SCHEDD_ENROLLMENT_RL_A
(P_SCHEDD_ENRT_RL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_ENROLLMENT_RL_BK3.DELETE_SCHEDD_ENROLLMENT_RL_A', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_ENROLLMENT_RL_BK3.DELETE_SCHEDD_ENROLLMENT_RL_A', 20);
end DELETE_SCHEDD_ENROLLMENT_RL_A;
procedure DELETE_SCHEDD_ENROLLMENT_RL_B
(P_SCHEDD_ENRT_RL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_ENROLLMENT_RL_BK3.DELETE_SCHEDD_ENROLLMENT_RL_B', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_ENROLLMENT_RL_BK3.DELETE_SCHEDD_ENROLLMENT_RL_B', 20);
end DELETE_SCHEDD_ENROLLMENT_RL_B;
end BEN_SCHEDD_ENROLLMENT_RL_BK3;

/
