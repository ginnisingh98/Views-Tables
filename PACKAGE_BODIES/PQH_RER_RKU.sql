--------------------------------------------------------
--  DDL for Package Body PQH_RER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RER_RKU" as
/* $Header: pqrerrhi.pkb 120.0 2005/10/06 14:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_RATE_ELEMENT_RELATION_ID in NUMBER
,P_CRITERIA_RATE_ELEMENT_ID in NUMBER
,P_RELATION_TYPE_CD in VARCHAR2
,P_REL_ELEMENT_TYPE_ID in NUMBER
,P_REL_INPUT_VALUE_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CRITERIA_RATE_ELEMENT_ID_O in NUMBER
,P_RELATION_TYPE_CD_O in VARCHAR2
,P_REL_ELEMENT_TYPE_ID_O in NUMBER
,P_REL_INPUT_VALUE_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RER_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_RER_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_RER_RKU;

/
