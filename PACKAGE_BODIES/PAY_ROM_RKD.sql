--------------------------------------------------------
--  DDL for Package Body PAY_ROM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ROM_RKD" as
/* $Header: pyromrhi.pkb 115.3 2002/12/09 15:04:01 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_RUN_TYPE_ORG_METHOD_ID in NUMBER
,P_RUN_TYPE_ID_O in NUMBER
,P_ORG_PAYMENT_METHOD_ID_O in NUMBER
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_PRIORITY_O in NUMBER
,P_PERCENTAGE_O in NUMBER
,P_AMOUNT_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_ROM_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_ROM_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_ROM_RKD;

/