--------------------------------------------------------
--  DDL for Package Body PAY_CFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CFT_RKU" as
/* $Header: pycatrhi.pkb 120.1 2005/10/05 06:44:36 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:27:48 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EMP_FED_TAX_INF_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_LEGISLATION_CODE in VARCHAR2
,P_ASSIGNMENT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EMPLOYMENT_PROVINCE in VARCHAR2
,P_TAX_CREDIT_AMOUNT in NUMBER
,P_CLAIM_CODE in VARCHAR2
,P_BASIC_EXEMPTION_FLAG in VARCHAR2
,P_ADDITIONAL_TAX in NUMBER
,P_ANNUAL_DEDN in NUMBER
,P_TOTAL_EXPENSE_BY_COMMISSION in NUMBER
,P_TOTAL_REMNRTN_BY_COMMISSION in NUMBER
,P_PRESCRIBED_ZONE_DEDN_AMT in NUMBER
,P_OTHER_FEDTAX_CREDITS in VARCHAR2
,P_CPP_QPP_EXEMPT_FLAG in VARCHAR2
,P_FED_EXEMPT_FLAG in VARCHAR2
,P_EI_EXEMPT_FLAG in VARCHAR2
,P_TAX_CALC_METHOD in VARCHAR2
,P_FED_OVERRIDE_AMOUNT in NUMBER
,P_FED_OVERRIDE_RATE in NUMBER
,P_CA_TAX_INFORMATION_CATEGORY in VARCHAR2
,P_CA_TAX_INFORMATION1 in VARCHAR2
,P_CA_TAX_INFORMATION2 in VARCHAR2
,P_CA_TAX_INFORMATION3 in VARCHAR2
,P_CA_TAX_INFORMATION4 in VARCHAR2
,P_CA_TAX_INFORMATION5 in VARCHAR2
,P_CA_TAX_INFORMATION6 in VARCHAR2
,P_CA_TAX_INFORMATION7 in VARCHAR2
,P_CA_TAX_INFORMATION8 in VARCHAR2
,P_CA_TAX_INFORMATION9 in VARCHAR2
,P_CA_TAX_INFORMATION10 in VARCHAR2
,P_CA_TAX_INFORMATION11 in VARCHAR2
,P_CA_TAX_INFORMATION12 in VARCHAR2
,P_CA_TAX_INFORMATION13 in VARCHAR2
,P_CA_TAX_INFORMATION14 in VARCHAR2
,P_CA_TAX_INFORMATION15 in VARCHAR2
,P_CA_TAX_INFORMATION16 in VARCHAR2
,P_CA_TAX_INFORMATION17 in VARCHAR2
,P_CA_TAX_INFORMATION18 in VARCHAR2
,P_CA_TAX_INFORMATION19 in VARCHAR2
,P_CA_TAX_INFORMATION20 in VARCHAR2
,P_CA_TAX_INFORMATION21 in VARCHAR2
,P_CA_TAX_INFORMATION22 in VARCHAR2
,P_CA_TAX_INFORMATION23 in VARCHAR2
,P_CA_TAX_INFORMATION24 in VARCHAR2
,P_CA_TAX_INFORMATION25 in VARCHAR2
,P_CA_TAX_INFORMATION26 in VARCHAR2
,P_CA_TAX_INFORMATION27 in VARCHAR2
,P_CA_TAX_INFORMATION28 in VARCHAR2
,P_CA_TAX_INFORMATION29 in VARCHAR2
,P_CA_TAX_INFORMATION30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_FED_LSF_AMOUNT in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_LEGISLATION_CODE_O in VARCHAR2
,P_ASSIGNMENT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EMPLOYMENT_PROVINCE_O in VARCHAR2
,P_TAX_CREDIT_AMOUNT_O in NUMBER
,P_CLAIM_CODE_O in VARCHAR2
,P_BASIC_EXEMPTION_FLAG_O in VARCHAR2
,P_ADDITIONAL_TAX_O in NUMBER
,P_ANNUAL_DEDN_O in NUMBER
,P_TOTAL_EXPENSE_BY_COMMISSIO_O in NUMBER
,P_TOTAL_REMNRTN_BY_COMMISSIO_O in NUMBER
,P_PRESCRIBED_ZONE_DEDN_AMT_O in NUMBER
,P_OTHER_FEDTAX_CREDITS_O in VARCHAR2
,P_CPP_QPP_EXEMPT_FLAG_O in VARCHAR2
,P_FED_EXEMPT_FLAG_O in VARCHAR2
,P_EI_EXEMPT_FLAG_O in VARCHAR2
,P_TAX_CALC_METHOD_O in VARCHAR2
,P_FED_OVERRIDE_AMOUNT_O in NUMBER
,P_FED_OVERRIDE_RATE_O in NUMBER
,P_CA_TAX_INFORMATION_CATEGOR_O in VARCHAR2
,P_CA_TAX_INFORMATION1_O in VARCHAR2
,P_CA_TAX_INFORMATION2_O in VARCHAR2
,P_CA_TAX_INFORMATION3_O in VARCHAR2
,P_CA_TAX_INFORMATION4_O in VARCHAR2
,P_CA_TAX_INFORMATION5_O in VARCHAR2
,P_CA_TAX_INFORMATION6_O in VARCHAR2
,P_CA_TAX_INFORMATION7_O in VARCHAR2
,P_CA_TAX_INFORMATION8_O in VARCHAR2
,P_CA_TAX_INFORMATION9_O in VARCHAR2
,P_CA_TAX_INFORMATION10_O in VARCHAR2
,P_CA_TAX_INFORMATION11_O in VARCHAR2
,P_CA_TAX_INFORMATION12_O in VARCHAR2
,P_CA_TAX_INFORMATION13_O in VARCHAR2
,P_CA_TAX_INFORMATION14_O in VARCHAR2
,P_CA_TAX_INFORMATION15_O in VARCHAR2
,P_CA_TAX_INFORMATION16_O in VARCHAR2
,P_CA_TAX_INFORMATION17_O in VARCHAR2
,P_CA_TAX_INFORMATION18_O in VARCHAR2
,P_CA_TAX_INFORMATION19_O in VARCHAR2
,P_CA_TAX_INFORMATION20_O in VARCHAR2
,P_CA_TAX_INFORMATION21_O in VARCHAR2
,P_CA_TAX_INFORMATION22_O in VARCHAR2
,P_CA_TAX_INFORMATION23_O in VARCHAR2
,P_CA_TAX_INFORMATION24_O in VARCHAR2
,P_CA_TAX_INFORMATION25_O in VARCHAR2
,P_CA_TAX_INFORMATION26_O in VARCHAR2
,P_CA_TAX_INFORMATION27_O in VARCHAR2
,P_CA_TAX_INFORMATION28_O in VARCHAR2
,P_CA_TAX_INFORMATION29_O in VARCHAR2
,P_CA_TAX_INFORMATION30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FED_LSF_AMOUNT_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_CFT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PAY_CFT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PAY_CFT_RKU;

/