--------------------------------------------------------
--  DDL for Package Body BEN_PEI_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEI_RKI" as
/* $Header: bepeirhi.pkb 120.0 2005/05/28 10:33:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_PL_EXTRACT_IDENTIFIER_ID in NUMBER
,P_PL_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_THIRD_PARTY_IDENTIFIER in VARCHAR2
,P_ORGANIZATION_ID in NUMBER
,P_JOB_ID in NUMBER
,P_POSITION_ID in NUMBER
,P_PEOPLE_GROUP_ID in NUMBER
,P_GRADE_ID in NUMBER
,P_PAYROLL_ID in NUMBER
,P_HOME_STATE in VARCHAR2
,P_HOME_ZIP in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_pei_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_pei_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_pei_RKI;

/