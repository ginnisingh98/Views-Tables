--------------------------------------------------------
--  DDL for Package Body BEN_BEI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEI_RKU" as
/* $Header: bebeirhi.pkb 120.0 2005/05/28 00:38:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:39 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_BATCH_ELIG_ID in NUMBER
,P_BENEFIT_ACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_PGM_ID in NUMBER
,P_PL_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_ELIG_FLAG in VARCHAR2
,P_INELIG_TEXT in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_BENEFIT_ACTION_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_PGM_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_OIPL_ID_O in NUMBER
,P_ELIG_FLAG_O in VARCHAR2
,P_INELIG_TEXT_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_bei_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_bei_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_bei_RKU;

/
