--------------------------------------------------------
--  DDL for Package Body HR_ACCRUAL_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ACCRUAL_PLAN_BK3" as
/* $Header: hrpapapi.pkb 120.1.12010000.1 2008/07/28 03:37:25 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ACCRUAL_PLAN_A
(P_EFFECTIVE_DATE in DATE
,P_ACCRUAL_PLAN_ID in NUMBER
,P_ACCRUAL_PLAN_ELEMENT_TYPE_ID in NUMBER
,P_CO_ELEMENT_TYPE_ID in NUMBER
,P_RESIDUAL_ELEMENT_TYPE_ID in NUMBER
,P_BALANCE_ELEMENT_TYPE_ID in NUMBER
,P_TAGGING_ELEMENT_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ACCRUAL_PLAN_BK3.DELETE_ACCRUAL_PLAN_A', 10);
hr_utility.set_location(' Leaving: HR_ACCRUAL_PLAN_BK3.DELETE_ACCRUAL_PLAN_A', 20);
end DELETE_ACCRUAL_PLAN_A;
procedure DELETE_ACCRUAL_PLAN_B
(P_EFFECTIVE_DATE in DATE
,P_ACCRUAL_PLAN_ID in NUMBER
,P_ACCRUAL_PLAN_ELEMENT_TYPE_ID in NUMBER
,P_CO_ELEMENT_TYPE_ID in NUMBER
,P_RESIDUAL_ELEMENT_TYPE_ID in NUMBER
,P_BALANCE_ELEMENT_TYPE_ID in NUMBER
,P_TAGGING_ELEMENT_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_ACCRUAL_PLAN_BK3.DELETE_ACCRUAL_PLAN_B', 10);
hr_utility.set_location(' Leaving: HR_ACCRUAL_PLAN_BK3.DELETE_ACCRUAL_PLAN_B', 20);
end DELETE_ACCRUAL_PLAN_B;
end HR_ACCRUAL_PLAN_BK3;

/