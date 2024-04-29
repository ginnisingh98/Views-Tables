--------------------------------------------------------
--  DDL for Package Body BEN_EAC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EAC_RKD" as
/* $Header: beeacrhi.pkb 115.8 2002/12/09 12:51:17 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELIG_AGE_CVG_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DPNT_CVG_ELIGY_PRFL_ID_O in NUMBER
,P_AGE_FCTR_ID_O in NUMBER
,P_CVG_STRT_CD_O in VARCHAR2
,P_CVG_STRT_RL_O in NUMBER
,P_CVG_THRU_CD_O in VARCHAR2
,P_CVG_THRU_RL_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_EAC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EAC_ATTRIBUTE1_O in VARCHAR2
,P_EAC_ATTRIBUTE2_O in VARCHAR2
,P_EAC_ATTRIBUTE3_O in VARCHAR2
,P_EAC_ATTRIBUTE4_O in VARCHAR2
,P_EAC_ATTRIBUTE5_O in VARCHAR2
,P_EAC_ATTRIBUTE6_O in VARCHAR2
,P_EAC_ATTRIBUTE7_O in VARCHAR2
,P_EAC_ATTRIBUTE8_O in VARCHAR2
,P_EAC_ATTRIBUTE9_O in VARCHAR2
,P_EAC_ATTRIBUTE10_O in VARCHAR2
,P_EAC_ATTRIBUTE11_O in VARCHAR2
,P_EAC_ATTRIBUTE12_O in VARCHAR2
,P_EAC_ATTRIBUTE13_O in VARCHAR2
,P_EAC_ATTRIBUTE14_O in VARCHAR2
,P_EAC_ATTRIBUTE15_O in VARCHAR2
,P_EAC_ATTRIBUTE16_O in VARCHAR2
,P_EAC_ATTRIBUTE17_O in VARCHAR2
,P_EAC_ATTRIBUTE18_O in VARCHAR2
,P_EAC_ATTRIBUTE19_O in VARCHAR2
,P_EAC_ATTRIBUTE20_O in VARCHAR2
,P_EAC_ATTRIBUTE21_O in VARCHAR2
,P_EAC_ATTRIBUTE22_O in VARCHAR2
,P_EAC_ATTRIBUTE23_O in VARCHAR2
,P_EAC_ATTRIBUTE24_O in VARCHAR2
,P_EAC_ATTRIBUTE25_O in VARCHAR2
,P_EAC_ATTRIBUTE26_O in VARCHAR2
,P_EAC_ATTRIBUTE27_O in VARCHAR2
,P_EAC_ATTRIBUTE28_O in VARCHAR2
,P_EAC_ATTRIBUTE29_O in VARCHAR2
,P_EAC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_eac_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_eac_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_eac_RKD;

/
