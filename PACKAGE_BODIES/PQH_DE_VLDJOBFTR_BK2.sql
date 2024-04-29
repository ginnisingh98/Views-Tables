--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLDJOBFTR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLDJOBFTR_BK2" as
/* $Header: pqftrapi.pkb 115.1 2002/11/27 23:43:34 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_VLDTN_JOBFTR_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_WRKPLC_VLDTN_OPR_JOB_ID in NUMBER
,P_JOB_FEATURE_CODE in VARCHAR2
,P_WRKPLC_VLDTN_OPR_JOB_TYPE in VARCHAR2
,P_WRKPLC_VLDTN_JOBFTR_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDJOBFTR_BK2.UPDATE_VLDTN_JOBFTR_A', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDJOBFTR_BK2.UPDATE_VLDTN_JOBFTR_A', 20);
end UPDATE_VLDTN_JOBFTR_A;
procedure UPDATE_VLDTN_JOBFTR_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_WRKPLC_VLDTN_OPR_JOB_ID in NUMBER
,P_JOB_FEATURE_CODE in VARCHAR2
,P_WRKPLC_VLDTN_OPR_JOB_TYPE in VARCHAR2
,P_WRKPLC_VLDTN_JOBFTR_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_DE_VLDJOBFTR_BK2.UPDATE_VLDTN_JOBFTR_B', 10);
hr_utility.set_location(' Leaving: PQH_DE_VLDJOBFTR_BK2.UPDATE_VLDTN_JOBFTR_B', 20);
end UPDATE_VLDTN_JOBFTR_B;
end PQH_DE_VLDJOBFTR_BK2;

/