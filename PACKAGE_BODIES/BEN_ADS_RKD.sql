--------------------------------------------------------
--  DDL for Package Body BEN_ADS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ADS_RKD" as
/* $Header: beadsrhi.pkb 120.0.12010000.3 2008/08/25 14:01:51 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ACTY_RT_DED_SCHED_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DED_SCHED_PY_FREQ_ID_O in NUMBER
,P_ACTY_BASE_RT_ID_O in NUMBER
,P_DED_SCHED_RL_O in NUMBER
,P_DED_SCHED_CD_O in VARCHAR2
,P_ADS_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ADS_ATTRIBUTE1_O in VARCHAR2
,P_ADS_ATTRIBUTE2_O in VARCHAR2
,P_ADS_ATTRIBUTE3_O in VARCHAR2
,P_ADS_ATTRIBUTE4_O in VARCHAR2
,P_ADS_ATTRIBUTE5_O in VARCHAR2
,P_ADS_ATTRIBUTE6_O in VARCHAR2
,P_ADS_ATTRIBUTE7_O in VARCHAR2
,P_ADS_ATTRIBUTE8_O in VARCHAR2
,P_ADS_ATTRIBUTE9_O in VARCHAR2
,P_ADS_ATTRIBUTE10_O in VARCHAR2
,P_ADS_ATTRIBUTE11_O in VARCHAR2
,P_ADS_ATTRIBUTE12_O in VARCHAR2
,P_ADS_ATTRIBUTE13_O in VARCHAR2
,P_ADS_ATTRIBUTE14_O in VARCHAR2
,P_ADS_ATTRIBUTE15_O in VARCHAR2
,P_ADS_ATTRIBUTE16_O in VARCHAR2
,P_ADS_ATTRIBUTE17_O in VARCHAR2
,P_ADS_ATTRIBUTE18_O in VARCHAR2
,P_ADS_ATTRIBUTE19_O in VARCHAR2
,P_ADS_ATTRIBUTE20_O in VARCHAR2
,P_ADS_ATTRIBUTE21_O in VARCHAR2
,P_ADS_ATTRIBUTE22_O in VARCHAR2
,P_ADS_ATTRIBUTE23_O in VARCHAR2
,P_ADS_ATTRIBUTE24_O in VARCHAR2
,P_ADS_ATTRIBUTE25_O in VARCHAR2
,P_ADS_ATTRIBUTE26_O in VARCHAR2
,P_ADS_ATTRIBUTE27_O in VARCHAR2
,P_ADS_ATTRIBUTE28_O in VARCHAR2
,P_ADS_ATTRIBUTE29_O in VARCHAR2
,P_ADS_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ads_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ads_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ads_RKD;

/
