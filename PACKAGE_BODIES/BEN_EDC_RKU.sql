--------------------------------------------------------
--  DDL for Package Body BEN_EDC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EDC_RKU" as
/* $Header: beedcrhi.pkb 120.0 2005/05/28 01:57:04 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:46 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ELIG_DSBLD_STAT_CVG_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_DPNT_CVG_ELIGY_PRFL_ID in NUMBER
,P_CVG_STRT_CD in VARCHAR2
,P_CVG_STRT_RL in NUMBER
,P_CVG_THRU_CD in VARCHAR2
,P_CVG_THRU_RL in NUMBER
,P_DSBLD_CD in VARCHAR2
,P_EDC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_EDC_ATTRIBUTE1 in VARCHAR2
,P_EDC_ATTRIBUTE2 in VARCHAR2
,P_EDC_ATTRIBUTE3 in VARCHAR2
,P_EDC_ATTRIBUTE4 in VARCHAR2
,P_EDC_ATTRIBUTE5 in VARCHAR2
,P_EDC_ATTRIBUTE6 in VARCHAR2
,P_EDC_ATTRIBUTE7 in VARCHAR2
,P_EDC_ATTRIBUTE8 in VARCHAR2
,P_EDC_ATTRIBUTE9 in VARCHAR2
,P_EDC_ATTRIBUTE10 in VARCHAR2
,P_EDC_ATTRIBUTE11 in VARCHAR2
,P_EDC_ATTRIBUTE12 in VARCHAR2
,P_EDC_ATTRIBUTE13 in VARCHAR2
,P_EDC_ATTRIBUTE14 in VARCHAR2
,P_EDC_ATTRIBUTE15 in VARCHAR2
,P_EDC_ATTRIBUTE16 in VARCHAR2
,P_EDC_ATTRIBUTE17 in VARCHAR2
,P_EDC_ATTRIBUTE18 in VARCHAR2
,P_EDC_ATTRIBUTE19 in VARCHAR2
,P_EDC_ATTRIBUTE20 in VARCHAR2
,P_EDC_ATTRIBUTE21 in VARCHAR2
,P_EDC_ATTRIBUTE22 in VARCHAR2
,P_EDC_ATTRIBUTE23 in VARCHAR2
,P_EDC_ATTRIBUTE24 in VARCHAR2
,P_EDC_ATTRIBUTE25 in VARCHAR2
,P_EDC_ATTRIBUTE26 in VARCHAR2
,P_EDC_ATTRIBUTE27 in VARCHAR2
,P_EDC_ATTRIBUTE28 in VARCHAR2
,P_EDC_ATTRIBUTE29 in VARCHAR2
,P_EDC_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DPNT_CVG_ELIGY_PRFL_ID_O in NUMBER
,P_CVG_STRT_CD_O in VARCHAR2
,P_CVG_STRT_RL_O in NUMBER
,P_CVG_THRU_CD_O in VARCHAR2
,P_CVG_THRU_RL_O in NUMBER
,P_DSBLD_CD_O in VARCHAR2
,P_EDC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EDC_ATTRIBUTE1_O in VARCHAR2
,P_EDC_ATTRIBUTE2_O in VARCHAR2
,P_EDC_ATTRIBUTE3_O in VARCHAR2
,P_EDC_ATTRIBUTE4_O in VARCHAR2
,P_EDC_ATTRIBUTE5_O in VARCHAR2
,P_EDC_ATTRIBUTE6_O in VARCHAR2
,P_EDC_ATTRIBUTE7_O in VARCHAR2
,P_EDC_ATTRIBUTE8_O in VARCHAR2
,P_EDC_ATTRIBUTE9_O in VARCHAR2
,P_EDC_ATTRIBUTE10_O in VARCHAR2
,P_EDC_ATTRIBUTE11_O in VARCHAR2
,P_EDC_ATTRIBUTE12_O in VARCHAR2
,P_EDC_ATTRIBUTE13_O in VARCHAR2
,P_EDC_ATTRIBUTE14_O in VARCHAR2
,P_EDC_ATTRIBUTE15_O in VARCHAR2
,P_EDC_ATTRIBUTE16_O in VARCHAR2
,P_EDC_ATTRIBUTE17_O in VARCHAR2
,P_EDC_ATTRIBUTE18_O in VARCHAR2
,P_EDC_ATTRIBUTE19_O in VARCHAR2
,P_EDC_ATTRIBUTE20_O in VARCHAR2
,P_EDC_ATTRIBUTE21_O in VARCHAR2
,P_EDC_ATTRIBUTE22_O in VARCHAR2
,P_EDC_ATTRIBUTE23_O in VARCHAR2
,P_EDC_ATTRIBUTE24_O in VARCHAR2
,P_EDC_ATTRIBUTE25_O in VARCHAR2
,P_EDC_ATTRIBUTE26_O in VARCHAR2
,P_EDC_ATTRIBUTE27_O in VARCHAR2
,P_EDC_ATTRIBUTE28_O in VARCHAR2
,P_EDC_ATTRIBUTE29_O in VARCHAR2
,P_EDC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_edc_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_edc_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_edc_RKU;

/
