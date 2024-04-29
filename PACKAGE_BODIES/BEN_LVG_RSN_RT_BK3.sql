--------------------------------------------------------
--  DDL for Package Body BEN_LVG_RSN_RT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LVG_RSN_RT_BK3" as
/* $Header: belrnapi.pkb 115.2 2002/12/16 07:03:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:53 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_LVG_RSN_RT_A
(P_LVG_RSN_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LVG_RSN_RT_BK3.DELETE_LVG_RSN_RT_A', 10);
hr_utility.set_location(' Leaving: BEN_LVG_RSN_RT_BK3.DELETE_LVG_RSN_RT_A', 20);
end DELETE_LVG_RSN_RT_A;
procedure DELETE_LVG_RSN_RT_B
(P_LVG_RSN_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_LVG_RSN_RT_BK3.DELETE_LVG_RSN_RT_B', 10);
hr_utility.set_location(' Leaving: BEN_LVG_RSN_RT_BK3.DELETE_LVG_RSN_RT_B', 20);
end DELETE_LVG_RSN_RT_B;
end BEN_LVG_RSN_RT_BK3;

/