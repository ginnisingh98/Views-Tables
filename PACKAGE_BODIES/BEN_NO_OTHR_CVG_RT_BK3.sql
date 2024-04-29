--------------------------------------------------------
--  DDL for Package Body BEN_NO_OTHR_CVG_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_NO_OTHR_CVG_RT_BK3" as
/* $Header: benocapi.pkb 120.0 2005/05/28 09:09:57 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:56 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_NO_OTHR_CVG_RT_A
(P_NO_OTHR_CVG_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_NO_OTHR_CVG_RT_BK3.DELETE_NO_OTHR_CVG_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_NO_OTHR_CVG_RT_BK3.DELETE_NO_OTHR_CVG_RT_A', 20);
end DELETE_NO_OTHR_CVG_RT_A;
procedure DELETE_NO_OTHR_CVG_RT_B
(P_NO_OTHR_CVG_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_NO_OTHR_CVG_RT_BK3.DELETE_NO_OTHR_CVG_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_NO_OTHR_CVG_RT_BK3.DELETE_NO_OTHR_CVG_RT_B', 20);
end DELETE_NO_OTHR_CVG_RT_B;
end BEN_NO_OTHR_CVG_RT_BK3;

/
