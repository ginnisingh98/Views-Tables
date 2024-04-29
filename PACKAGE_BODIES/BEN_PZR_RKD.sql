--------------------------------------------------------
--  DDL for Package Body BEN_PZR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PZR_RKD" as
/* $Header: bepzrrhi.pkb 120.0.12010000.2 2008/08/05 15:24:44 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PSTL_ZIP_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_EXCLD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_PSTL_ZIP_RNG_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PZR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PZR_ATTRIBUTE1_O in VARCHAR2
,P_PZR_ATTRIBUTE2_O in VARCHAR2
,P_PZR_ATTRIBUTE3_O in VARCHAR2
,P_PZR_ATTRIBUTE4_O in VARCHAR2
,P_PZR_ATTRIBUTE5_O in VARCHAR2
,P_PZR_ATTRIBUTE6_O in VARCHAR2
,P_PZR_ATTRIBUTE7_O in VARCHAR2
,P_PZR_ATTRIBUTE8_O in VARCHAR2
,P_PZR_ATTRIBUTE9_O in VARCHAR2
,P_PZR_ATTRIBUTE10_O in VARCHAR2
,P_PZR_ATTRIBUTE11_O in VARCHAR2
,P_PZR_ATTRIBUTE12_O in VARCHAR2
,P_PZR_ATTRIBUTE13_O in VARCHAR2
,P_PZR_ATTRIBUTE14_O in VARCHAR2
,P_PZR_ATTRIBUTE15_O in VARCHAR2
,P_PZR_ATTRIBUTE16_O in VARCHAR2
,P_PZR_ATTRIBUTE17_O in VARCHAR2
,P_PZR_ATTRIBUTE18_O in VARCHAR2
,P_PZR_ATTRIBUTE19_O in VARCHAR2
,P_PZR_ATTRIBUTE20_O in VARCHAR2
,P_PZR_ATTRIBUTE21_O in VARCHAR2
,P_PZR_ATTRIBUTE22_O in VARCHAR2
,P_PZR_ATTRIBUTE23_O in VARCHAR2
,P_PZR_ATTRIBUTE24_O in VARCHAR2
,P_PZR_ATTRIBUTE25_O in VARCHAR2
,P_PZR_ATTRIBUTE26_O in VARCHAR2
,P_PZR_ATTRIBUTE27_O in VARCHAR2
,P_PZR_ATTRIBUTE28_O in VARCHAR2
,P_PZR_ATTRIBUTE29_O in VARCHAR2
,P_PZR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_pzr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_pzr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_pzr_RKD;

/
