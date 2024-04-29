--------------------------------------------------------
--  DDL for Package Body BEN_EQG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EQG_RKU" as
/* $Header: beeqgrhi.pkb 120.1 2006/02/27 02:00:27 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:21 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ELIG_QUA_IN_GR_PRTE_ID in NUMBER
,P_QUAR_IN_GRADE_CD in VARCHAR2
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_NUM in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EQG_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EQG_ATTRIBUTE1 in VARCHAR2
,P_EQG_ATTRIBUTE2 in VARCHAR2
,P_EQG_ATTRIBUTE3 in VARCHAR2
,P_EQG_ATTRIBUTE4 in VARCHAR2
,P_EQG_ATTRIBUTE5 in VARCHAR2
,P_EQG_ATTRIBUTE6 in VARCHAR2
,P_EQG_ATTRIBUTE7 in VARCHAR2
,P_EQG_ATTRIBUTE8 in VARCHAR2
,P_EQG_ATTRIBUTE9 in VARCHAR2
,P_EQG_ATTRIBUTE10 in VARCHAR2
,P_EQG_ATTRIBUTE11 in VARCHAR2
,P_EQG_ATTRIBUTE12 in VARCHAR2
,P_EQG_ATTRIBUTE13 in VARCHAR2
,P_EQG_ATTRIBUTE14 in VARCHAR2
,P_EQG_ATTRIBUTE15 in VARCHAR2
,P_EQG_ATTRIBUTE16 in VARCHAR2
,P_EQG_ATTRIBUTE17 in VARCHAR2
,P_EQG_ATTRIBUTE18 in VARCHAR2
,P_EQG_ATTRIBUTE19 in VARCHAR2
,P_EQG_ATTRIBUTE20 in VARCHAR2
,P_EQG_ATTRIBUTE21 in VARCHAR2
,P_EQG_ATTRIBUTE22 in VARCHAR2
,P_EQG_ATTRIBUTE23 in VARCHAR2
,P_EQG_ATTRIBUTE24 in VARCHAR2
,P_EQG_ATTRIBUTE25 in VARCHAR2
,P_EQG_ATTRIBUTE26 in VARCHAR2
,P_EQG_ATTRIBUTE27 in VARCHAR2
,P_EQG_ATTRIBUTE28 in VARCHAR2
,P_EQG_ATTRIBUTE29 in VARCHAR2
,P_EQG_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_QUAR_IN_GRADE_CD_O in VARCHAR2
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_ORDR_NUM_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_ELIGY_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EQG_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EQG_ATTRIBUTE1_O in VARCHAR2
,P_EQG_ATTRIBUTE2_O in VARCHAR2
,P_EQG_ATTRIBUTE3_O in VARCHAR2
,P_EQG_ATTRIBUTE4_O in VARCHAR2
,P_EQG_ATTRIBUTE5_O in VARCHAR2
,P_EQG_ATTRIBUTE6_O in VARCHAR2
,P_EQG_ATTRIBUTE7_O in VARCHAR2
,P_EQG_ATTRIBUTE8_O in VARCHAR2
,P_EQG_ATTRIBUTE9_O in VARCHAR2
,P_EQG_ATTRIBUTE10_O in VARCHAR2
,P_EQG_ATTRIBUTE11_O in VARCHAR2
,P_EQG_ATTRIBUTE12_O in VARCHAR2
,P_EQG_ATTRIBUTE13_O in VARCHAR2
,P_EQG_ATTRIBUTE14_O in VARCHAR2
,P_EQG_ATTRIBUTE15_O in VARCHAR2
,P_EQG_ATTRIBUTE16_O in VARCHAR2
,P_EQG_ATTRIBUTE17_O in VARCHAR2
,P_EQG_ATTRIBUTE18_O in VARCHAR2
,P_EQG_ATTRIBUTE19_O in VARCHAR2
,P_EQG_ATTRIBUTE20_O in VARCHAR2
,P_EQG_ATTRIBUTE21_O in VARCHAR2
,P_EQG_ATTRIBUTE22_O in VARCHAR2
,P_EQG_ATTRIBUTE23_O in VARCHAR2
,P_EQG_ATTRIBUTE24_O in VARCHAR2
,P_EQG_ATTRIBUTE25_O in VARCHAR2
,P_EQG_ATTRIBUTE26_O in VARCHAR2
,P_EQG_ATTRIBUTE27_O in VARCHAR2
,P_EQG_ATTRIBUTE28_O in VARCHAR2
,P_EQG_ATTRIBUTE29_O in VARCHAR2
,P_EQG_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CRITERIA_SCORE in NUMBER
,P_CRITERIA_WEIGHT in NUMBER
,P_CRITERIA_SCORE_O in NUMBER
,P_CRITERIA_WEIGHT_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_EQG_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_EQG_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_EQG_RKU;

/