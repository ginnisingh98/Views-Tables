--------------------------------------------------------
--  DDL for Package Body BEN_CMBN_PTIP_OPT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMBN_PTIP_OPT_BK3" as
/* $Header: becptapi.pkb 115.3 2002/12/13 06:54:44 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:19 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_CMBN_PTIP_OPT_A
(P_CMBN_PTIP_OPT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CMBN_PTIP_OPT_BK3.DELETE_CMBN_PTIP_OPT_A', 10);
hr_utility.set_location(' Leaving: BEN_CMBN_PTIP_OPT_BK3.DELETE_CMBN_PTIP_OPT_A', 20);
end DELETE_CMBN_PTIP_OPT_A;
procedure DELETE_CMBN_PTIP_OPT_B
(P_CMBN_PTIP_OPT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_CMBN_PTIP_OPT_BK3.DELETE_CMBN_PTIP_OPT_B', 10);
hr_utility.set_location(' Leaving: BEN_CMBN_PTIP_OPT_BK3.DELETE_CMBN_PTIP_OPT_B', 20);
end DELETE_CMBN_PTIP_OPT_B;
end BEN_CMBN_PTIP_OPT_BK3;

/
