--------------------------------------------------------
--  DDL for Package Body BEN_PRTL_MO_RT_PRTN_VAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTL_MO_RT_PRTN_VAL_BK3" as
/* $Header: beppvapi.pkb 120.0 2005/05/28 11:01:32 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:34 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PRTL_MO_RT_PRTN_VAL_A
(P_PRTL_MO_RT_PRTN_VAL_ID in NUMBER
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTL_MO_RT_PRTN_VAL_BK3.DELETE_PRTL_MO_RT_PRTN_VAL_A', 10);
hr_utility.set_location(' Leaving: BEN_PRTL_MO_RT_PRTN_VAL_BK3.DELETE_PRTL_MO_RT_PRTN_VAL_A', 20);
end DELETE_PRTL_MO_RT_PRTN_VAL_A;
procedure DELETE_PRTL_MO_RT_PRTN_VAL_B
(P_PRTL_MO_RT_PRTN_VAL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTL_MO_RT_PRTN_VAL_BK3.DELETE_PRTL_MO_RT_PRTN_VAL_B', 10);
hr_utility.set_location(' Leaving: BEN_PRTL_MO_RT_PRTN_VAL_BK3.DELETE_PRTL_MO_RT_PRTN_VAL_B', 20);
end DELETE_PRTL_MO_RT_PRTN_VAL_B;
end BEN_PRTL_MO_RT_PRTN_VAL_BK3;

/