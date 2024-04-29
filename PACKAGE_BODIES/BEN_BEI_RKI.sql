--------------------------------------------------------
--  DDL for Package Body BEN_BEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BEI_RKI" as
/* $Header: bebeirhi.pkb 120.0 2005/05/28 00:38:07 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:38 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
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
)is
begin
hr_utility.set_location('Entering: ben_bei_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_bei_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_bei_RKI;

/
