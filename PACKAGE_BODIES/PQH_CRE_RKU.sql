--------------------------------------------------------
--  DDL for Package Body PQH_CRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRE_RKU" as
/* $Header: pqcrerhi.pkb 120.0 2005/10/06 14:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:15 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CRITERIA_RATE_ELEMENT_ID in NUMBER
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_ELEMENT_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CRITERIA_RATE_DEFN_ID_O in NUMBER
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_INPUT_VALUE_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_CRE_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_CRE_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_CRE_RKU;

/
