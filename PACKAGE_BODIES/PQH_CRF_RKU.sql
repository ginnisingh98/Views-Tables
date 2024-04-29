--------------------------------------------------------
--  DDL for Package Body PQH_CRF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CRF_RKU" as
/* $Header: pqcrfrhi.pkb 120.0 2005/10/06 14:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CRITERIA_RATE_FACTOR_ID in NUMBER
,P_CRITERIA_RATE_DEFN_ID in NUMBER
,P_PARENT_RATE_MATRIX_ID in NUMBER
,P_PARENT_CRITERIA_RATE_DEFN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CRITERIA_RATE_DEFN_ID_O in NUMBER
,P_PARENT_RATE_MATRIX_ID_O in NUMBER
,P_PARENT_CRITERIA_RATE_DEFN__O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_CRF_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_CRF_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_CRF_RKU;

/