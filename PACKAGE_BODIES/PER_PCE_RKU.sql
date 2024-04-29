--------------------------------------------------------
--  DDL for Package Body PER_PCE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_RKU" as
/* $Header: pepcerhi.pkb 115.6 2002/12/09 10:49:42 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:32:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CAGR_ENTITLEMENT_ID in NUMBER
,P_CAGR_ENTITLEMENT_ITEM_ID in NUMBER
,P_COLLECTIVE_AGREEMENT_ID in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
,P_STATUS in VARCHAR2
,P_FORMULA_CRITERIA in VARCHAR2
,P_FORMULA_ID in NUMBER
,P_UNITS_OF_MEASURE in VARCHAR2
,P_MESSAGE_LEVEL in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CAGR_ENTITLEMENT_ITEM_ID_O in NUMBER
,P_COLLECTIVE_AGREEMENT_ID_O in NUMBER
,P_START_DATE_O in DATE
,P_END_DATE_O in DATE
,P_STATUS_O in VARCHAR2
,P_FORMULA_CRITERIA_O in VARCHAR2
,P_FORMULA_ID_O in NUMBER
,P_UNITS_OF_MEASURE_O in VARCHAR2
,P_MESSAGE_LEVEL_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_PCE_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_PCE_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_PCE_RKU;

/