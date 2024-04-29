--------------------------------------------------------
--  DDL for Package Body BEN_ETC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ETC_RKD" as
/* $Header: beetcrhi.pkb 120.0 2005/05/28 03:00:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:30 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ELIG_TTL_CVG_VOL_PRTE_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
,P_NO_MN_CVG_VOL_AMT_APLS_FLA_O in VARCHAR2
,P_NO_MX_CVG_VOL_AMT_APLS_FLA_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_MN_CVG_VOL_AMT_O in NUMBER
,P_MX_CVG_VOL_AMT_O in NUMBER
,P_CVG_VOL_DET_CD_O in VARCHAR2
,P_CVG_VOL_DET_RL_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_ETC_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ETC_ATTRIBUTE1_O in VARCHAR2
,P_ETC_ATTRIBUTE2_O in VARCHAR2
,P_ETC_ATTRIBUTE3_O in VARCHAR2
,P_ETC_ATTRIBUTE4_O in VARCHAR2
,P_ETC_ATTRIBUTE5_O in VARCHAR2
,P_ETC_ATTRIBUTE6_O in VARCHAR2
,P_ETC_ATTRIBUTE7_O in VARCHAR2
,P_ETC_ATTRIBUTE8_O in VARCHAR2
,P_ETC_ATTRIBUTE9_O in VARCHAR2
,P_ETC_ATTRIBUTE10_O in VARCHAR2
,P_ETC_ATTRIBUTE11_O in VARCHAR2
,P_ETC_ATTRIBUTE12_O in VARCHAR2
,P_ETC_ATTRIBUTE13_O in VARCHAR2
,P_ETC_ATTRIBUTE14_O in VARCHAR2
,P_ETC_ATTRIBUTE15_O in VARCHAR2
,P_ETC_ATTRIBUTE16_O in VARCHAR2
,P_ETC_ATTRIBUTE17_O in VARCHAR2
,P_ETC_ATTRIBUTE18_O in VARCHAR2
,P_ETC_ATTRIBUTE19_O in VARCHAR2
,P_ETC_ATTRIBUTE20_O in VARCHAR2
,P_ETC_ATTRIBUTE21_O in VARCHAR2
,P_ETC_ATTRIBUTE22_O in VARCHAR2
,P_ETC_ATTRIBUTE23_O in VARCHAR2
,P_ETC_ATTRIBUTE24_O in VARCHAR2
,P_ETC_ATTRIBUTE25_O in VARCHAR2
,P_ETC_ATTRIBUTE26_O in VARCHAR2
,P_ETC_ATTRIBUTE27_O in VARCHAR2
,P_ETC_ATTRIBUTE28_O in VARCHAR2
,P_ETC_ATTRIBUTE29_O in VARCHAR2
,P_ETC_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_ETC_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: BEN_ETC_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end BEN_ETC_RKD;

/