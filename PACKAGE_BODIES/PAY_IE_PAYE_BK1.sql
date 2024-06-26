--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYE_BK1" as
/* $Header: pyipdapi.pkb 120.4 2007/11/27 07:42:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:32 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_IE_PAYE_DETAILS_A
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_INFO_SOURCE in VARCHAR2
,P_TAX_BASIS in VARCHAR2
,P_CERTIFICATE_START_DATE in DATE
,P_TAX_ASSESS_BASIS in VARCHAR2
,P_CERTIFICATE_ISSUE_DATE in DATE
,P_CERTIFICATE_END_DATE in DATE
,P_WEEKLY_TAX_CREDIT in NUMBER
,P_WEEKLY_STD_RATE_CUT_OFF in NUMBER
,P_MONTHLY_TAX_CREDIT in NUMBER
,P_MONTHLY_STD_RATE_CUT_OFF in NUMBER
,P_TAX_DEDUCTED_TO_DATE in NUMBER
,P_PAY_TO_DATE in NUMBER
,P_DISABILITY_BENEFIT in NUMBER
,P_LUMP_SUM_PAYMENT in NUMBER
,P_PAYE_DETAILS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_TAX_THIS_EMPLOYMENT in NUMBER
,P_PREVIOUS_EMPLOYMENT_START_DT in DATE
,P_PREVIOUS_EMPLOYMENT_END_DATE in DATE
,P_PAY_THIS_EMPLOYMENT in NUMBER
,P_PAYE_PREVIOUS_EMPLOYER in VARCHAR2
,P_P45P3_OR_P46 in VARCHAR2
,P_ALREADY_SUBMITTED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_IE_PAYE_BK1.CREATE_IE_PAYE_DETAILS_A', 10);
hr_utility.set_location(' Leaving: PAY_IE_PAYE_BK1.CREATE_IE_PAYE_DETAILS_A', 20);
end CREATE_IE_PAYE_DETAILS_A;
procedure CREATE_IE_PAYE_DETAILS_B
(P_EFFECTIVE_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ASSIGNMENT_ID in NUMBER
,P_INFO_SOURCE in VARCHAR2
,P_TAX_BASIS in VARCHAR2
,P_CERTIFICATE_START_DATE in DATE
,P_TAX_ASSESS_BASIS in VARCHAR2
,P_CERTIFICATE_ISSUE_DATE in DATE
,P_CERTIFICATE_END_DATE in DATE
,P_WEEKLY_TAX_CREDIT in NUMBER
,P_WEEKLY_STD_RATE_CUT_OFF in NUMBER
,P_MONTHLY_TAX_CREDIT in NUMBER
,P_MONTHLY_STD_RATE_CUT_OFF in NUMBER
,P_TAX_DEDUCTED_TO_DATE in NUMBER
,P_PAY_TO_DATE in NUMBER
,P_DISABILITY_BENEFIT in NUMBER
,P_LUMP_SUM_PAYMENT in NUMBER
,P_TAX_THIS_EMPLOYMENT in NUMBER
,P_PREVIOUS_EMPLOYMENT_START_DT in DATE
,P_PREVIOUS_EMPLOYMENT_END_DATE in DATE
,P_PAY_THIS_EMPLOYMENT in NUMBER
,P_PAYE_PREVIOUS_EMPLOYER in VARCHAR2
,P_P45P3_OR_P46 in VARCHAR2
,P_ALREADY_SUBMITTED in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_IE_PAYE_BK1.CREATE_IE_PAYE_DETAILS_B', 10);
hr_utility.set_location(' Leaving: PAY_IE_PAYE_BK1.CREATE_IE_PAYE_DETAILS_B', 20);
end CREATE_IE_PAYE_DETAILS_B;
end PAY_IE_PAYE_BK1;

/
