--------------------------------------------------------
--  DDL for Package Body HR_ACCRUAL_PLAN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ACCRUAL_PLAN_BK2" as
/* $Header: hrpapapi.pkb 120.1.12010000.1 2008/07/28 03:37:25 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:52 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ACCRUAL_PLAN_A
(P_ACCRUAL_PLAN_ID in NUMBER
,P_PTO_INPUT_VALUE_ID in NUMBER
,P_ACCRUAL_CATEGORY in VARCHAR2
,P_ACCRUAL_START in VARCHAR2
,P_INELIGIBLE_PERIOD_LENGTH in NUMBER
,P_INELIGIBLE_PERIOD_TYPE in VARCHAR2
,P_ACCRUAL_FORMULA_ID in NUMBER
,P_CO_FORMULA_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_INELIGIBILITY_FORMULA_ID in NUMBER
,P_PAYROLL_FORMULA_ID in NUMBER
,P_DEFINED_BALANCE_ID in NUMBER
,P_BALANCE_DIMENSION_ID in NUMBER
,P_TAGGING_ELEMENT_TYPE_ID in NUMBER
,P_BALANCE_ELEMENT_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ACCRUAL_PLAN_BK2.UPDATE_ACCRUAL_PLAN_A', 10);
hr_utility.set_location(' Leaving: HR_ACCRUAL_PLAN_BK2.UPDATE_ACCRUAL_PLAN_A', 20);
end UPDATE_ACCRUAL_PLAN_A;
procedure UPDATE_ACCRUAL_PLAN_B
(P_ACCRUAL_PLAN_ID in NUMBER
,P_PTO_INPUT_VALUE_ID in NUMBER
,P_ACCRUAL_CATEGORY in VARCHAR2
,P_ACCRUAL_START in VARCHAR2
,P_INELIGIBLE_PERIOD_LENGTH in NUMBER
,P_INELIGIBLE_PERIOD_TYPE in VARCHAR2
,P_ACCRUAL_FORMULA_ID in NUMBER
,P_CO_FORMULA_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_INELIGIBILITY_FORMULA_ID in NUMBER
,P_BALANCE_DIMENSION_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_INFORMATION_CATEGORY in VARCHAR2
,P_INFORMATION1 in VARCHAR2
,P_INFORMATION2 in VARCHAR2
,P_INFORMATION3 in VARCHAR2
,P_INFORMATION4 in VARCHAR2
,P_INFORMATION5 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_INFORMATION7 in VARCHAR2
,P_INFORMATION8 in VARCHAR2
,P_INFORMATION9 in VARCHAR2
,P_INFORMATION10 in VARCHAR2
,P_INFORMATION11 in VARCHAR2
,P_INFORMATION12 in VARCHAR2
,P_INFORMATION13 in VARCHAR2
,P_INFORMATION14 in VARCHAR2
,P_INFORMATION15 in VARCHAR2
,P_INFORMATION16 in VARCHAR2
,P_INFORMATION17 in VARCHAR2
,P_INFORMATION18 in VARCHAR2
,P_INFORMATION19 in VARCHAR2
,P_INFORMATION20 in VARCHAR2
,P_INFORMATION21 in VARCHAR2
,P_INFORMATION22 in VARCHAR2
,P_INFORMATION23 in VARCHAR2
,P_INFORMATION24 in VARCHAR2
,P_INFORMATION25 in VARCHAR2
,P_INFORMATION26 in VARCHAR2
,P_INFORMATION27 in VARCHAR2
,P_INFORMATION28 in VARCHAR2
,P_INFORMATION29 in VARCHAR2
,P_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_ACCRUAL_PLAN_BK2.UPDATE_ACCRUAL_PLAN_B', 10);
hr_utility.set_location(' Leaving: HR_ACCRUAL_PLAN_BK2.UPDATE_ACCRUAL_PLAN_B', 20);
end UPDATE_ACCRUAL_PLAN_B;
end HR_ACCRUAL_PLAN_BK2;

/