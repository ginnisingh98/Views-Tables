--------------------------------------------------------
--  DDL for Package Body PAY_CNT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNT_BK1" as
/* $Header: pycntapi.pkb 120.0 2007/05/01 22:37:03 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:33 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_COUNTY_TAX_RULE_A
(P_EMP_COUNTY_TAX_RULE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ASSIGNMENT_ID in NUMBER
,P_STATE_CODE in VARCHAR2
,P_COUNTY_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_ADDITIONAL_WA_RATE in NUMBER
,P_FILING_STATUS_CODE in VARCHAR2
,P_JURISDICTION_CODE in VARCHAR2
,P_LIT_ADDITIONAL_TAX in NUMBER
,P_LIT_OVERRIDE_AMOUNT in NUMBER
,P_LIT_OVERRIDE_RATE in NUMBER
,P_WITHHOLDING_ALLOWANCES in NUMBER
,P_LIT_EXEMPT in VARCHAR2
,P_SD_EXEMPT in VARCHAR2
,P_HT_EXEMPT in VARCHAR2
,P_WAGE_EXEMPT in VARCHAR2
,P_SCHOOL_DISTRICT_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_CNT_INFORMATION_CATEGORY in VARCHAR2
,P_CNT_INFORMATION1 in VARCHAR2
,P_CNT_INFORMATION2 in VARCHAR2
,P_CNT_INFORMATION3 in VARCHAR2
,P_CNT_INFORMATION4 in VARCHAR2
,P_CNT_INFORMATION5 in VARCHAR2
,P_CNT_INFORMATION6 in VARCHAR2
,P_CNT_INFORMATION7 in VARCHAR2
,P_CNT_INFORMATION8 in VARCHAR2
,P_CNT_INFORMATION9 in VARCHAR2
,P_CNT_INFORMATION10 in VARCHAR2
,P_CNT_INFORMATION11 in VARCHAR2
,P_CNT_INFORMATION12 in VARCHAR2
,P_CNT_INFORMATION13 in VARCHAR2
,P_CNT_INFORMATION14 in VARCHAR2
,P_CNT_INFORMATION15 in VARCHAR2
,P_CNT_INFORMATION16 in VARCHAR2
,P_CNT_INFORMATION17 in VARCHAR2
,P_CNT_INFORMATION18 in VARCHAR2
,P_CNT_INFORMATION19 in VARCHAR2
,P_CNT_INFORMATION20 in VARCHAR2
,P_CNT_INFORMATION21 in VARCHAR2
,P_CNT_INFORMATION22 in VARCHAR2
,P_CNT_INFORMATION23 in VARCHAR2
,P_CNT_INFORMATION24 in VARCHAR2
,P_CNT_INFORMATION25 in VARCHAR2
,P_CNT_INFORMATION26 in VARCHAR2
,P_CNT_INFORMATION27 in VARCHAR2
,P_CNT_INFORMATION28 in VARCHAR2
,P_CNT_INFORMATION29 in VARCHAR2
,P_CNT_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_CNT_BK1.CREATE_COUNTY_TAX_RULE_A', 10);
hr_utility.set_location(' Leaving: PAY_CNT_BK1.CREATE_COUNTY_TAX_RULE_A', 20);
end CREATE_COUNTY_TAX_RULE_A;
procedure CREATE_COUNTY_TAX_RULE_B
(P_ASSIGNMENT_ID in NUMBER
,P_STATE_CODE in VARCHAR2
,P_COUNTY_CODE in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_ADDITIONAL_WA_RATE in NUMBER
,P_FILING_STATUS_CODE in VARCHAR2
,P_JURISDICTION_CODE in VARCHAR2
,P_LIT_ADDITIONAL_TAX in NUMBER
,P_LIT_OVERRIDE_AMOUNT in NUMBER
,P_LIT_OVERRIDE_RATE in NUMBER
,P_WITHHOLDING_ALLOWANCES in NUMBER
,P_LIT_EXEMPT in VARCHAR2
,P_SD_EXEMPT in VARCHAR2
,P_HT_EXEMPT in VARCHAR2
,P_WAGE_EXEMPT in VARCHAR2
,P_SCHOOL_DISTRICT_CODE in VARCHAR2
,P_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ATTRIBUTE1 in VARCHAR2
,P_ATTRIBUTE2 in VARCHAR2
,P_ATTRIBUTE3 in VARCHAR2
,P_ATTRIBUTE4 in VARCHAR2
,P_ATTRIBUTE5 in VARCHAR2
,P_ATTRIBUTE6 in VARCHAR2
,P_ATTRIBUTE7 in VARCHAR2
,P_ATTRIBUTE8 in VARCHAR2
,P_ATTRIBUTE9 in VARCHAR2
,P_ATTRIBUTE10 in VARCHAR2
,P_ATTRIBUTE11 in VARCHAR2
,P_ATTRIBUTE12 in VARCHAR2
,P_ATTRIBUTE13 in VARCHAR2
,P_ATTRIBUTE14 in VARCHAR2
,P_ATTRIBUTE15 in VARCHAR2
,P_ATTRIBUTE16 in VARCHAR2
,P_ATTRIBUTE17 in VARCHAR2
,P_ATTRIBUTE18 in VARCHAR2
,P_ATTRIBUTE19 in VARCHAR2
,P_ATTRIBUTE20 in VARCHAR2
,P_ATTRIBUTE21 in VARCHAR2
,P_ATTRIBUTE22 in VARCHAR2
,P_ATTRIBUTE23 in VARCHAR2
,P_ATTRIBUTE24 in VARCHAR2
,P_ATTRIBUTE25 in VARCHAR2
,P_ATTRIBUTE26 in VARCHAR2
,P_ATTRIBUTE27 in VARCHAR2
,P_ATTRIBUTE28 in VARCHAR2
,P_ATTRIBUTE29 in VARCHAR2
,P_ATTRIBUTE30 in VARCHAR2
,P_CNT_INFORMATION_CATEGORY in VARCHAR2
,P_CNT_INFORMATION1 in VARCHAR2
,P_CNT_INFORMATION2 in VARCHAR2
,P_CNT_INFORMATION3 in VARCHAR2
,P_CNT_INFORMATION4 in VARCHAR2
,P_CNT_INFORMATION5 in VARCHAR2
,P_CNT_INFORMATION6 in VARCHAR2
,P_CNT_INFORMATION7 in VARCHAR2
,P_CNT_INFORMATION8 in VARCHAR2
,P_CNT_INFORMATION9 in VARCHAR2
,P_CNT_INFORMATION10 in VARCHAR2
,P_CNT_INFORMATION11 in VARCHAR2
,P_CNT_INFORMATION12 in VARCHAR2
,P_CNT_INFORMATION13 in VARCHAR2
,P_CNT_INFORMATION14 in VARCHAR2
,P_CNT_INFORMATION15 in VARCHAR2
,P_CNT_INFORMATION16 in VARCHAR2
,P_CNT_INFORMATION17 in VARCHAR2
,P_CNT_INFORMATION18 in VARCHAR2
,P_CNT_INFORMATION19 in VARCHAR2
,P_CNT_INFORMATION20 in VARCHAR2
,P_CNT_INFORMATION21 in VARCHAR2
,P_CNT_INFORMATION22 in VARCHAR2
,P_CNT_INFORMATION23 in VARCHAR2
,P_CNT_INFORMATION24 in VARCHAR2
,P_CNT_INFORMATION25 in VARCHAR2
,P_CNT_INFORMATION26 in VARCHAR2
,P_CNT_INFORMATION27 in VARCHAR2
,P_CNT_INFORMATION28 in VARCHAR2
,P_CNT_INFORMATION29 in VARCHAR2
,P_CNT_INFORMATION30 in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_CNT_BK1.CREATE_COUNTY_TAX_RULE_B', 10);
hr_utility.set_location(' Leaving: PAY_CNT_BK1.CREATE_COUNTY_TAX_RULE_B', 20);
end CREATE_COUNTY_TAX_RULE_B;
end PAY_CNT_BK1;

/
