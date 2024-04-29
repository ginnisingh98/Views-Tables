--------------------------------------------------------
--  DDL for Package Body PQH_CRITERIA_RATE_ELEMENTS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRITERIA_RATE_ELEMENTS_BK1" as
/* $Header: pqcreapi.pkb 120.0 2005/10/06 14:51:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:14 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_CRITERIA_RATE_ELEMENT_A
(P_EFFECTIVE_DATE in DATE
,P_CRITERIA_RATE_ELEMENT_ID in NUMBER
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_CRITERIA_RATE_ELEMENTS_BK1.CREATE_CRITERIA_RATE_ELEMENT_A', 10);
hr_utility.set_location(' Leaving: PQH_CRITERIA_RATE_ELEMENTS_BK1.CREATE_CRITERIA_RATE_ELEMENT_A', 20);
end CREATE_CRITERIA_RATE_ELEMENT_A;
procedure CREATE_CRITERIA_RATE_ELEMENT_B
(P_EFFECTIVE_DATE in DATE
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_CRITERIA_RATE_ELEMENTS_BK1.CREATE_CRITERIA_RATE_ELEMENT_B', 10);
hr_utility.set_location(' Leaving: PQH_CRITERIA_RATE_ELEMENTS_BK1.CREATE_CRITERIA_RATE_ELEMENT_B', 20);
end CREATE_CRITERIA_RATE_ELEMENT_B;
end PQH_CRITERIA_RATE_ELEMENTS_BK1;

/