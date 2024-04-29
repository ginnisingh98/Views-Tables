--------------------------------------------------------
--  DDL for Package Body BEN_HSR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HSR_RKU" as
/* $Header: behsrrhi.pkb 120.2 2006/03/30 23:48:18 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:35 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_HRLY_SLRD_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_VRBL_RT_PRFL_ID in NUMBER
,P_HRLY_SLRD_CD in VARCHAR2
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_HSR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_HSR_ATTRIBUTE1 in VARCHAR2
,P_HSR_ATTRIBUTE2 in VARCHAR2
,P_HSR_ATTRIBUTE3 in VARCHAR2
,P_HSR_ATTRIBUTE4 in VARCHAR2
,P_HSR_ATTRIBUTE5 in VARCHAR2
,P_HSR_ATTRIBUTE6 in VARCHAR2
,P_HSR_ATTRIBUTE7 in VARCHAR2
,P_HSR_ATTRIBUTE8 in VARCHAR2
,P_HSR_ATTRIBUTE9 in VARCHAR2
,P_HSR_ATTRIBUTE10 in VARCHAR2
,P_HSR_ATTRIBUTE11 in VARCHAR2
,P_HSR_ATTRIBUTE12 in VARCHAR2
,P_HSR_ATTRIBUTE13 in VARCHAR2
,P_HSR_ATTRIBUTE14 in VARCHAR2
,P_HSR_ATTRIBUTE15 in VARCHAR2
,P_HSR_ATTRIBUTE16 in VARCHAR2
,P_HSR_ATTRIBUTE17 in VARCHAR2
,P_HSR_ATTRIBUTE18 in VARCHAR2
,P_HSR_ATTRIBUTE19 in VARCHAR2
,P_HSR_ATTRIBUTE20 in VARCHAR2
,P_HSR_ATTRIBUTE21 in VARCHAR2
,P_HSR_ATTRIBUTE22 in VARCHAR2
,P_HSR_ATTRIBUTE23 in VARCHAR2
,P_HSR_ATTRIBUTE24 in VARCHAR2
,P_HSR_ATTRIBUTE25 in VARCHAR2
,P_HSR_ATTRIBUTE26 in VARCHAR2
,P_HSR_ATTRIBUTE27 in VARCHAR2
,P_HSR_ATTRIBUTE28 in VARCHAR2
,P_HSR_ATTRIBUTE29 in VARCHAR2
,P_HSR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_HRLY_SLRD_CD_O in VARCHAR2
,P_EXCLD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_HSR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_HSR_ATTRIBUTE1_O in VARCHAR2
,P_HSR_ATTRIBUTE2_O in VARCHAR2
,P_HSR_ATTRIBUTE3_O in VARCHAR2
,P_HSR_ATTRIBUTE4_O in VARCHAR2
,P_HSR_ATTRIBUTE5_O in VARCHAR2
,P_HSR_ATTRIBUTE6_O in VARCHAR2
,P_HSR_ATTRIBUTE7_O in VARCHAR2
,P_HSR_ATTRIBUTE8_O in VARCHAR2
,P_HSR_ATTRIBUTE9_O in VARCHAR2
,P_HSR_ATTRIBUTE10_O in VARCHAR2
,P_HSR_ATTRIBUTE11_O in VARCHAR2
,P_HSR_ATTRIBUTE12_O in VARCHAR2
,P_HSR_ATTRIBUTE13_O in VARCHAR2
,P_HSR_ATTRIBUTE14_O in VARCHAR2
,P_HSR_ATTRIBUTE15_O in VARCHAR2
,P_HSR_ATTRIBUTE16_O in VARCHAR2
,P_HSR_ATTRIBUTE17_O in VARCHAR2
,P_HSR_ATTRIBUTE18_O in VARCHAR2
,P_HSR_ATTRIBUTE19_O in VARCHAR2
,P_HSR_ATTRIBUTE20_O in VARCHAR2
,P_HSR_ATTRIBUTE21_O in VARCHAR2
,P_HSR_ATTRIBUTE22_O in VARCHAR2
,P_HSR_ATTRIBUTE23_O in VARCHAR2
,P_HSR_ATTRIBUTE24_O in VARCHAR2
,P_HSR_ATTRIBUTE25_O in VARCHAR2
,P_HSR_ATTRIBUTE26_O in VARCHAR2
,P_HSR_ATTRIBUTE27_O in VARCHAR2
,P_HSR_ATTRIBUTE28_O in VARCHAR2
,P_HSR_ATTRIBUTE29_O in VARCHAR2
,P_HSR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_hsr_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_hsr_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_hsr_RKU;

/