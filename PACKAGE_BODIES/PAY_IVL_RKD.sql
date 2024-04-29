--------------------------------------------------------
--  DDL for Package Body PAY_IVL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IVL_RKD" as
/* $Header: pyivlrhi.pkb 120.0 2005/05/29 06:04:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_INPUT_VALUE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_LOOKUP_TYPE_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_FORMULA_ID_O in NUMBER
,P_VALUE_SET_ID_O in NUMBER
,P_DISPLAY_SEQUENCE_O in NUMBER
,P_GENERATE_DB_ITEMS_FLAG_O in VARCHAR2
,P_HOT_DEFAULT_FLAG_O in VARCHAR2
,P_MANDATORY_FLAG_O in VARCHAR2
,P_NAME_O in VARCHAR2
,P_UOM_O in VARCHAR2
,P_DEFAULT_VALUE_O in VARCHAR2
,P_LEGISLATION_SUBGROUP_O in VARCHAR2
,P_MAX_VALUE_O in VARCHAR2
,P_MIN_VALUE_O in VARCHAR2
,P_WARNING_OR_ERROR_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_IVL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_IVL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_IVL_RKD;

/