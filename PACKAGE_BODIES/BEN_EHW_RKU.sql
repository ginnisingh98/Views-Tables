--------------------------------------------------------
--  DDL for Package Body BEN_EHW_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EHW_RKU" as
/* $Header: beehwrhi.pkb 120.1 2006/02/27 02:22:38 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:56 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ELIG_HRS_WKD_PRTE_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_HRS_WKD_IN_PERD_FCTR_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_EHW_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EHW_ATTRIBUTE1 in VARCHAR2
,P_EHW_ATTRIBUTE2 in VARCHAR2
,P_EHW_ATTRIBUTE3 in VARCHAR2
,P_EHW_ATTRIBUTE4 in VARCHAR2
,P_EHW_ATTRIBUTE5 in VARCHAR2
,P_EHW_ATTRIBUTE6 in VARCHAR2
,P_EHW_ATTRIBUTE7 in VARCHAR2
,P_EHW_ATTRIBUTE8 in VARCHAR2
,P_EHW_ATTRIBUTE9 in VARCHAR2
,P_EHW_ATTRIBUTE10 in VARCHAR2
,P_EHW_ATTRIBUTE11 in VARCHAR2
,P_EHW_ATTRIBUTE12 in VARCHAR2
,P_EHW_ATTRIBUTE13 in VARCHAR2
,P_EHW_ATTRIBUTE14 in VARCHAR2
,P_EHW_ATTRIBUTE15 in VARCHAR2
,P_EHW_ATTRIBUTE16 in VARCHAR2
,P_EHW_ATTRIBUTE17 in VARCHAR2
,P_EHW_ATTRIBUTE18 in VARCHAR2
,P_EHW_ATTRIBUTE19 in VARCHAR2
,P_EHW_ATTRIBUTE20 in VARCHAR2
,P_EHW_ATTRIBUTE21 in VARCHAR2
,P_EHW_ATTRIBUTE22 in VARCHAR2
,P_EHW_ATTRIBUTE23 in VARCHAR2
,P_EHW_ATTRIBUTE24 in VARCHAR2
,P_EHW_ATTRIBUTE25 in VARCHAR2
,P_EHW_ATTRIBUTE26 in VARCHAR2
,P_EHW_ATTRIBUTE27 in VARCHAR2
,P_EHW_ATTRIBUTE28 in VARCHAR2
,P_EHW_ATTRIBUTE29 in VARCHAR2
,P_EHW_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_HRS_WKD_IN_PERD_FCTR_ID_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_EHW_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EHW_ATTRIBUTE1_O in VARCHAR2
,P_EHW_ATTRIBUTE2_O in VARCHAR2
,P_EHW_ATTRIBUTE3_O in VARCHAR2
,P_EHW_ATTRIBUTE4_O in VARCHAR2
,P_EHW_ATTRIBUTE5_O in VARCHAR2
,P_EHW_ATTRIBUTE6_O in VARCHAR2
,P_EHW_ATTRIBUTE7_O in VARCHAR2
,P_EHW_ATTRIBUTE8_O in VARCHAR2
,P_EHW_ATTRIBUTE9_O in VARCHAR2
,P_EHW_ATTRIBUTE10_O in VARCHAR2
,P_EHW_ATTRIBUTE11_O in VARCHAR2
,P_EHW_ATTRIBUTE12_O in VARCHAR2
,P_EHW_ATTRIBUTE13_O in VARCHAR2
,P_EHW_ATTRIBUTE14_O in VARCHAR2
,P_EHW_ATTRIBUTE15_O in VARCHAR2
,P_EHW_ATTRIBUTE16_O in VARCHAR2
,P_EHW_ATTRIBUTE17_O in VARCHAR2
,P_EHW_ATTRIBUTE18_O in VARCHAR2
,P_EHW_ATTRIBUTE19_O in VARCHAR2
,P_EHW_ATTRIBUTE20_O in VARCHAR2
,P_EHW_ATTRIBUTE21_O in VARCHAR2
,P_EHW_ATTRIBUTE22_O in VARCHAR2
,P_EHW_ATTRIBUTE23_O in VARCHAR2
,P_EHW_ATTRIBUTE24_O in VARCHAR2
,P_EHW_ATTRIBUTE25_O in VARCHAR2
,P_EHW_ATTRIBUTE26_O in VARCHAR2
,P_EHW_ATTRIBUTE27_O in VARCHAR2
,P_EHW_ATTRIBUTE28_O in VARCHAR2
,P_EHW_ATTRIBUTE29_O in VARCHAR2
,P_EHW_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
,P_CRITERIA_SCORE_O in NUMBER
,P_CRITERIA_WEIGHT_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ehw_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_ehw_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_ehw_RKU;

/
