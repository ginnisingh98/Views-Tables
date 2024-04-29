--------------------------------------------------------
--  DDL for Package Body BEN_ASSIGNMENT_SET_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ASSIGNMENT_SET_RATE_BK3" as
/* $Header: beasrapi.pkb 120.0 2005/05/28 00:30:04 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:30 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ASSIGNMENT_SET_RATE_A
(P_ASNT_SET_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ASSIGNMENT_SET_RATE_BK3.DELETE_ASSIGNMENT_SET_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_ASSIGNMENT_SET_RATE_BK3.DELETE_ASSIGNMENT_SET_RATE_A', 20);
end DELETE_ASSIGNMENT_SET_RATE_A;
procedure DELETE_ASSIGNMENT_SET_RATE_B
(P_ASNT_SET_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ASSIGNMENT_SET_RATE_BK3.DELETE_ASSIGNMENT_SET_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_ASSIGNMENT_SET_RATE_BK3.DELETE_ASSIGNMENT_SET_RATE_B', 20);
end DELETE_ASSIGNMENT_SET_RATE_B;
end BEN_ASSIGNMENT_SET_RATE_BK3;

/