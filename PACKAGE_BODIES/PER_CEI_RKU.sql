--------------------------------------------------------
--  DDL for Package Body PER_CEI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEI_RKU" as
/* $Header: peceirhi.pkb 120.1 2006/10/18 08:58:46 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:54 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CAGR_ENTITLEMENT_ITEM_ID in NUMBER
,P_ITEM_NAME in VARCHAR2
,P_ELEMENT_TYPE_ID in NUMBER
,P_INPUT_VALUE_ID in VARCHAR2
,P_COLUMN_TYPE in VARCHAR2
,P_COLUMN_SIZE in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_CAGR_API_ID in NUMBER
,P_CAGR_API_PARAM_ID in NUMBER
,P_BENEFICIAL_FORMULA_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_BENEFICIAL_RULE in VARCHAR2
,P_CATEGORY_NAME in VARCHAR2
,P_UOM in VARCHAR2
,P_FLEX_VALUE_SET_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BEN_RULE_VALUE_SET_ID in NUMBER
,P_MULT_ENTRIES_ALLOWED_FLAG in VARCHAR2
,P_AUTO_CREATE_ENTRIES_FLAG in VARCHAR2
,P_OPT_ID in NUMBER
,P_ITEM_NAME_O in VARCHAR2
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_INPUT_VALUE_ID_O in VARCHAR2
,P_COLUMN_TYPE_O in VARCHAR2
,P_COLUMN_SIZE_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_CAGR_API_ID_O in NUMBER
,P_CAGR_API_PARAM_ID_O in NUMBER
,P_BENEFICIAL_FORMULA_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_BENEFICIAL_RULE_O in VARCHAR2
,P_CATEGORY_NAME_O in VARCHAR2
,P_UOM_O in VARCHAR2
,P_FLEX_VALUE_SET_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BEN_RULE_VALUE_SET_ID_O in NUMBER
,P_MULT_ENTRIES_ALLOWED_FLAG_O in VARCHAR2
,P_AUTO_CREATE_ENTRIES_FLAG_O in VARCHAR2
,P_OPT_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_CEI_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_CEI_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_CEI_RKU;

/