--------------------------------------------------------
--  DDL for Package Body PAY_ITR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ITR_RKD" as
/* $Header: pyitrrhi.pkb 115.6 2002/12/16 17:48:51 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_ITERATIVE_RULE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ELEMENT_TYPE_ID_O in NUMBER
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_RESULT_NAME_O in VARCHAR2
,P_ITERATIVE_RULE_TYPE_O in VARCHAR2
,P_INPUT_VALUE_ID_O in NUMBER
,P_SEVERITY_LEVEL_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_ITR_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_ITR_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_ITR_RKD;

/