--------------------------------------------------------
--  DDL for Package Body PQH_FR_GLOBAL_PAYSCALE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_GLOBAL_PAYSCALE_BK3" as
/* $Header: pqginapi.pkb 115.3 2004/02/23 03:22:46 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_INDEMNITY_RATE_A
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_GLOBAL_INDEX_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BASIC_SALARY_RATE in NUMBER
,P_HOUSING_INDEMNITY_RATE in NUMBER
,P_CURRENCY_CODE in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: PQH_FR_GLOBAL_PAYSCALE_BK3.UPDATE_INDEMNITY_RATE_A', 10);
hr_utility.set_location(' Leaving: PQH_FR_GLOBAL_PAYSCALE_BK3.UPDATE_INDEMNITY_RATE_A', 20);
end UPDATE_INDEMNITY_RATE_A;
procedure UPDATE_INDEMNITY_RATE_B
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_GLOBAL_INDEX_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BASIC_SALARY_RATE in NUMBER
,P_HOUSING_INDEMNITY_RATE in NUMBER
,P_CURRENCY_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_FR_GLOBAL_PAYSCALE_BK3.UPDATE_INDEMNITY_RATE_B', 10);
hr_utility.set_location(' Leaving: PQH_FR_GLOBAL_PAYSCALE_BK3.UPDATE_INDEMNITY_RATE_B', 20);
end UPDATE_INDEMNITY_RATE_B;
end PQH_FR_GLOBAL_PAYSCALE_BK3;

/