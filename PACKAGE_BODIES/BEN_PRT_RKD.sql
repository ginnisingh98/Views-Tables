--------------------------------------------------------
--  DDL for Package Body BEN_PRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRT_RKD" as
/* $Header: beprtrhi.pkb 120.0.12010000.3 2008/08/25 13:51:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_POE_RT_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_MN_POE_NUM_O in NUMBER
,P_MX_POE_NUM_O in NUMBER
,P_NO_MN_POE_FLAG_O in VARCHAR2
,P_NO_MX_POE_FLAG_O in VARCHAR2
,P_RNDG_CD_O in VARCHAR2
,P_RNDG_RL_O in NUMBER
,P_POE_NNMNTRY_UOM_O in VARCHAR2
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PRT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PRT_ATTRIBUTE1_O in VARCHAR2
,P_PRT_ATTRIBUTE2_O in VARCHAR2
,P_PRT_ATTRIBUTE3_O in VARCHAR2
,P_PRT_ATTRIBUTE4_O in VARCHAR2
,P_PRT_ATTRIBUTE5_O in VARCHAR2
,P_PRT_ATTRIBUTE6_O in VARCHAR2
,P_PRT_ATTRIBUTE7_O in VARCHAR2
,P_PRT_ATTRIBUTE8_O in VARCHAR2
,P_PRT_ATTRIBUTE9_O in VARCHAR2
,P_PRT_ATTRIBUTE10_O in VARCHAR2
,P_PRT_ATTRIBUTE11_O in VARCHAR2
,P_PRT_ATTRIBUTE12_O in VARCHAR2
,P_PRT_ATTRIBUTE13_O in VARCHAR2
,P_PRT_ATTRIBUTE14_O in VARCHAR2
,P_PRT_ATTRIBUTE15_O in VARCHAR2
,P_PRT_ATTRIBUTE16_O in VARCHAR2
,P_PRT_ATTRIBUTE17_O in VARCHAR2
,P_PRT_ATTRIBUTE18_O in VARCHAR2
,P_PRT_ATTRIBUTE19_O in VARCHAR2
,P_PRT_ATTRIBUTE20_O in VARCHAR2
,P_PRT_ATTRIBUTE21_O in VARCHAR2
,P_PRT_ATTRIBUTE22_O in VARCHAR2
,P_PRT_ATTRIBUTE23_O in VARCHAR2
,P_PRT_ATTRIBUTE24_O in VARCHAR2
,P_PRT_ATTRIBUTE25_O in VARCHAR2
,P_PRT_ATTRIBUTE26_O in VARCHAR2
,P_PRT_ATTRIBUTE27_O in VARCHAR2
,P_PRT_ATTRIBUTE28_O in VARCHAR2
,P_PRT_ATTRIBUTE29_O in VARCHAR2
,P_PRT_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_CBR_DSBLTY_APLS_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_prt_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_prt_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_prt_RKD;

/
