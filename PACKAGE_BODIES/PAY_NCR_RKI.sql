--------------------------------------------------------
--  DDL for Package Body PAY_NCR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NCR_RKI" as
/* $Header: pyncrrhi.pkb 120.0 2005/05/29 06:52:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:02 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_NET_CALCULATION_RULE_ID in NUMBER
,P_ACCRUAL_PLAN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_INPUT_VALUE_ID in NUMBER
,P_ADD_OR_SUBTRACT in VARCHAR2
,P_DATE_INPUT_VALUE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_NCR_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_NCR_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_NCR_RKI;

/
