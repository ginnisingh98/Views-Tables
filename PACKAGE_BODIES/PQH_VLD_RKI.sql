--------------------------------------------------------
--  DDL for Package Body PQH_VLD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VLD_RKI" as
/* $Header: pqvldrhi.pkb 115.2 2002/12/13 00:33:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:49 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_VALIDATION_ID in NUMBER
,P_PENSION_FUND_TYPE_CODE in VARCHAR2
,P_PENSION_FUND_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_REQUEST_DATE in DATE
,P_COMPLETION_DATE in DATE
,P_PREVIOUS_EMPLOYER_ID in NUMBER
,P_PREVIOUSLY_VALIDATED_FLAG in VARCHAR2
,P_STATUS in VARCHAR2
,P_EMPLOYER_AMOUNT in NUMBER
,P_EMPLOYER_CURRENCY_CODE in VARCHAR2
,P_EMPLOYEE_AMOUNT in NUMBER
,P_EMPLOYEE_CURRENCY_CODE in VARCHAR2
,P_DEDUCTION_PER_PERIOD in NUMBER
,P_DEDUCTION_CURRENCY_CODE in VARCHAR2
,P_PERCENT_OF_SALARY in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_VLD_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PQH_VLD_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PQH_VLD_RKI;

/