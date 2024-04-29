--------------------------------------------------------
--  DDL for Package Body BEN_LIFE_EVENT_ENROLL_RSN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LIFE_EVENT_ENROLL_RSN_BK3" as
/* $Header: belenapi.pkb 120.0.12000000.2 2007/05/13 22:56:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_LIFE_EVENT_ENROLL_RSN_A
(P_LEE_RSN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LIFE_EVENT_ENROLL_RSN_BK3.DELETE_LIFE_EVENT_ENROLL_RSN_A', 10);
hr_utility.set_location(' Leaving: BEN_LIFE_EVENT_ENROLL_RSN_BK3.DELETE_LIFE_EVENT_ENROLL_RSN_A', 20);
end DELETE_LIFE_EVENT_ENROLL_RSN_A;
procedure DELETE_LIFE_EVENT_ENROLL_RSN_B
(P_LEE_RSN_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LIFE_EVENT_ENROLL_RSN_BK3.DELETE_LIFE_EVENT_ENROLL_RSN_B', 10);
hr_utility.set_location(' Leaving: BEN_LIFE_EVENT_ENROLL_RSN_BK3.DELETE_LIFE_EVENT_ENROLL_RSN_B', 20);
end DELETE_LIFE_EVENT_ENROLL_RSN_B;
end BEN_LIFE_EVENT_ENROLL_RSN_BK3;

/