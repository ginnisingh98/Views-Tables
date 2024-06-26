--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDLVL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDLVL_BK1" as
/* $Header: pqlvlapi.pkb 115.1 2002/12/03 00:08:32 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:23 (YYYY/MM/DD HH24:MI:SS)
procedure INSERT_VLDTN_LVL_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_WRKPLC_VLDTN_VER_ID in NUMBER
,P_LEVEL_NUMBER_ID in NUMBER
,P_LEVEL_CODE_ID in NUMBER
,P_WRKPLC_VLDTN_LVLNUM_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDLVL_BK1.INSERT_VLDTN_LVL_A', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDLVL_BK1.INSERT_VLDTN_LVL_A', 20);
end INSERT_VLDTN_LVL_A;
procedure INSERT_VLDTN_LVL_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_WRKPLC_VLDTN_VER_ID in NUMBER
,P_LEVEL_NUMBER_ID in NUMBER
,P_LEVEL_CODE_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDLVL_BK1.INSERT_VLDTN_LVL_B', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDLVL_BK1.INSERT_VLDTN_LVL_B', 20);
end INSERT_VLDTN_LVL_B;
end PQH_DE_VLDLVL_BK1;

/
