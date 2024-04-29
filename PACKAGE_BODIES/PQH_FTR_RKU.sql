--------------------------------------------------------
--  DDL for Package Body PQH_FTR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FTR_RKU" as
/* $Header: pqftrrhi.pkb 115.4 2002/11/27 23:43:38 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_WRKPLC_VLDTN_JOBFTR_ID in NUMBER
,P_WRKPLC_VLDTN_OPR_JOB_ID in NUMBER
,P_JOB_FEATURE_CODE in VARCHAR2
,P_WRKPLC_VLDTN_OPR_JOB_TYPE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_WRKPLC_VLDTN_OPR_JOB_ID_O in NUMBER
,P_JOB_FEATURE_CODE_O in VARCHAR2
,P_WRKPLC_VLDTN_OPR_JOB_TYPE_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_FTR_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_FTR_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_FTR_RKU;

/