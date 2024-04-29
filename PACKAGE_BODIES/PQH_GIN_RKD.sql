--------------------------------------------------------
--  DDL for Package Body PQH_GIN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GIN_RKD" as
/* $Header: pqginrhi.pkb 115.7 2004/03/15 03:05 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_GLOBAL_INDEX_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_TYPE_OF_RECORD_O in VARCHAR2
,P_GROSS_INDEX_O in NUMBER
,P_INCREASED_INDEX_O in NUMBER
,P_BASIC_SALARY_RATE_O in NUMBER
,P_HOUSING_INDEMNITY_RATE_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CURRENCY_CODE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_GIN_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_GIN_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_GIN_RKD;

/