--------------------------------------------------------
--  DDL for Package Body BEN_ECV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECV_RKU" as
/* $Header: beecvrhi.pkb 120.1 2005/07/29 09:50:17 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:44 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ELIGY_CRIT_VALUES_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_ELIGY_CRITERIA_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_NUM in NUMBER
,P_NUMBER_VALUE1 in NUMBER
,P_NUMBER_VALUE2 in NUMBER
,P_CHAR_VALUE1 in VARCHAR2
,P_CHAR_VALUE2 in VARCHAR2
,P_DATE_VALUE1 in DATE
,P_DATE_VALUE2 in DATE
,P_EXCLD_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_ECV_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ECV_ATTRIBUTE1 in VARCHAR2
,P_ECV_ATTRIBUTE2 in VARCHAR2
,P_ECV_ATTRIBUTE3 in VARCHAR2
,P_ECV_ATTRIBUTE4 in VARCHAR2
,P_ECV_ATTRIBUTE5 in VARCHAR2
,P_ECV_ATTRIBUTE6 in VARCHAR2
,P_ECV_ATTRIBUTE7 in VARCHAR2
,P_ECV_ATTRIBUTE8 in VARCHAR2
,P_ECV_ATTRIBUTE9 in VARCHAR2
,P_ECV_ATTRIBUTE10 in VARCHAR2
,P_ECV_ATTRIBUTE11 in VARCHAR2
,P_ECV_ATTRIBUTE12 in VARCHAR2
,P_ECV_ATTRIBUTE13 in VARCHAR2
,P_ECV_ATTRIBUTE14 in VARCHAR2
,P_ECV_ATTRIBUTE15 in VARCHAR2
,P_ECV_ATTRIBUTE16 in VARCHAR2
,P_ECV_ATTRIBUTE17 in VARCHAR2
,P_ECV_ATTRIBUTE18 in VARCHAR2
,P_ECV_ATTRIBUTE19 in VARCHAR2
,P_ECV_ATTRIBUTE20 in VARCHAR2
,P_ECV_ATTRIBUTE21 in VARCHAR2
,P_ECV_ATTRIBUTE22 in VARCHAR2
,P_ECV_ATTRIBUTE23 in VARCHAR2
,P_ECV_ATTRIBUTE24 in VARCHAR2
,P_ECV_ATTRIBUTE25 in VARCHAR2
,P_ECV_ATTRIBUTE26 in VARCHAR2
,P_ECV_ATTRIBUTE27 in VARCHAR2
,P_ECV_ATTRIBUTE28 in VARCHAR2
,P_ECV_ATTRIBUTE29 in VARCHAR2
,P_ECV_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
,P_CHAR_VALUE3 in VARCHAR2
,P_CHAR_VALUE4 in VARCHAR2
,P_NUMBER_VALUE3 in NUMBER
,P_NUMBER_VALUE4 in NUMBER
,P_DATE_VALUE3 in DATE
,P_DATE_VALUE4 in DATE
,P_ELIGY_PRFL_ID_O in NUMBER
,P_ELIGY_CRITERIA_ID_O in NUMBER
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ORDR_NUM_O in NUMBER
,P_NUMBER_VALUE1_O in NUMBER
,P_NUMBER_VALUE2_O in NUMBER
,P_CHAR_VALUE1_O in VARCHAR2
,P_CHAR_VALUE2_O in VARCHAR2
,P_DATE_VALUE1_O in DATE
,P_DATE_VALUE2_O in DATE
,P_EXCLD_FLAG_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_ECV_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ECV_ATTRIBUTE1_O in VARCHAR2
,P_ECV_ATTRIBUTE2_O in VARCHAR2
,P_ECV_ATTRIBUTE3_O in VARCHAR2
,P_ECV_ATTRIBUTE4_O in VARCHAR2
,P_ECV_ATTRIBUTE5_O in VARCHAR2
,P_ECV_ATTRIBUTE6_O in VARCHAR2
,P_ECV_ATTRIBUTE7_O in VARCHAR2
,P_ECV_ATTRIBUTE8_O in VARCHAR2
,P_ECV_ATTRIBUTE9_O in VARCHAR2
,P_ECV_ATTRIBUTE10_O in VARCHAR2
,P_ECV_ATTRIBUTE11_O in VARCHAR2
,P_ECV_ATTRIBUTE12_O in VARCHAR2
,P_ECV_ATTRIBUTE13_O in VARCHAR2
,P_ECV_ATTRIBUTE14_O in VARCHAR2
,P_ECV_ATTRIBUTE15_O in VARCHAR2
,P_ECV_ATTRIBUTE16_O in VARCHAR2
,P_ECV_ATTRIBUTE17_O in VARCHAR2
,P_ECV_ATTRIBUTE18_O in VARCHAR2
,P_ECV_ATTRIBUTE19_O in VARCHAR2
,P_ECV_ATTRIBUTE20_O in VARCHAR2
,P_ECV_ATTRIBUTE21_O in VARCHAR2
,P_ECV_ATTRIBUTE22_O in VARCHAR2
,P_ECV_ATTRIBUTE23_O in VARCHAR2
,P_ECV_ATTRIBUTE24_O in VARCHAR2
,P_ECV_ATTRIBUTE25_O in VARCHAR2
,P_ECV_ATTRIBUTE26_O in VARCHAR2
,P_ECV_ATTRIBUTE27_O in VARCHAR2
,P_ECV_ATTRIBUTE28_O in VARCHAR2
,P_ECV_ATTRIBUTE29_O in VARCHAR2
,P_ECV_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CRITERIA_SCORE_O in NUMBER
,P_CRITERIA_WEIGHT_O in NUMBER
,P_CHAR_VALUE3_O in VARCHAR2
,P_CHAR_VALUE4_O in VARCHAR2
,P_NUMBER_VALUE3_O in NUMBER
,P_NUMBER_VALUE4_O in NUMBER
,P_DATE_VALUE3_O in DATE
,P_DATE_VALUE4_O in DATE
)is
begin
hr_utility.set_location('Entering: ben_ecv_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_ecv_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_ecv_RKU;

/
