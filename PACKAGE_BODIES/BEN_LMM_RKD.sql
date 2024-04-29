--------------------------------------------------------
--  DDL for Package Body BEN_LMM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LMM_RKD" as
/* $Header: belmmrhi.pkb 120.0 2005/05/28 03:24:48 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:44 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LBR_MMBR_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_LBR_MMBR_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LMM_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LMM_ATTRIBUTE1_O in VARCHAR2
,P_LMM_ATTRIBUTE2_O in VARCHAR2
,P_LMM_ATTRIBUTE3_O in VARCHAR2
,P_LMM_ATTRIBUTE4_O in VARCHAR2
,P_LMM_ATTRIBUTE5_O in VARCHAR2
,P_LMM_ATTRIBUTE6_O in VARCHAR2
,P_LMM_ATTRIBUTE7_O in VARCHAR2
,P_LMM_ATTRIBUTE8_O in VARCHAR2
,P_LMM_ATTRIBUTE9_O in VARCHAR2
,P_LMM_ATTRIBUTE10_O in VARCHAR2
,P_LMM_ATTRIBUTE11_O in VARCHAR2
,P_LMM_ATTRIBUTE12_O in VARCHAR2
,P_LMM_ATTRIBUTE13_O in VARCHAR2
,P_LMM_ATTRIBUTE14_O in VARCHAR2
,P_LMM_ATTRIBUTE15_O in VARCHAR2
,P_LMM_ATTRIBUTE16_O in VARCHAR2
,P_LMM_ATTRIBUTE17_O in VARCHAR2
,P_LMM_ATTRIBUTE18_O in VARCHAR2
,P_LMM_ATTRIBUTE19_O in VARCHAR2
,P_LMM_ATTRIBUTE20_O in VARCHAR2
,P_LMM_ATTRIBUTE21_O in VARCHAR2
,P_LMM_ATTRIBUTE22_O in VARCHAR2
,P_LMM_ATTRIBUTE23_O in VARCHAR2
,P_LMM_ATTRIBUTE24_O in VARCHAR2
,P_LMM_ATTRIBUTE25_O in VARCHAR2
,P_LMM_ATTRIBUTE26_O in VARCHAR2
,P_LMM_ATTRIBUTE27_O in VARCHAR2
,P_LMM_ATTRIBUTE28_O in VARCHAR2
,P_LMM_ATTRIBUTE29_O in VARCHAR2
,P_LMM_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_lmm_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_lmm_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_lmm_RKD;

/
