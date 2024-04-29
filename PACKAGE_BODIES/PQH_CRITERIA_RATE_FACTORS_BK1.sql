--------------------------------------------------------
--  DDL for Package Body PQH_CRITERIA_RATE_FACTORS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRITERIA_RATE_FACTORS_BK1" as
/* $Header: pqcrfapi.pkb 120.0 2005/10/06 14:52:22 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:17 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_CRITERIA_RATE_FACTOR_A
(P_EFFECTIVE_DATE in DATE
,P_CRITERIA_RATE_FACTOR_ID in NUMBER
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_PARENT_CRITERIA_RATE_DEFN_ID in NUMBER
,P_PARENT_RATE_MATRIX_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_CRITERIA_RATE_FACTORS_BK1.CREATE_CRITERIA_RATE_FACTOR_A', 10);
hr_utility.set_location(' Leaving: PQH_CRITERIA_RATE_FACTORS_BK1.CREATE_CRITERIA_RATE_FACTOR_A', 20);
end CREATE_CRITERIA_RATE_FACTOR_A;
procedure CREATE_CRITERIA_RATE_FACTOR_B
(P_EFFECTIVE_DATE in DATE
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_PARENT_CRITERIA_RATE_DEFN_ID in NUMBER
,P_PARENT_RATE_MATRIX_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_CRITERIA_RATE_FACTORS_BK1.CREATE_CRITERIA_RATE_FACTOR_B', 10);
hr_utility.set_location(' Leaving: PQH_CRITERIA_RATE_FACTORS_BK1.CREATE_CRITERIA_RATE_FACTOR_B', 20);
end CREATE_CRITERIA_RATE_FACTOR_B;
end PQH_CRITERIA_RATE_FACTORS_BK1;

/
