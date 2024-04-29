--------------------------------------------------------
--  DDL for Package Body BEN_PRD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRD_RKU" as
/* $Header: beprdrhi.pkb 120.0.12010000.2 2008/08/05 15:20:11 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PAIRD_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_USE_PARNT_DED_SCHED_FLAG in VARCHAR2
,P_ASN_ON_CHC_OF_PARNT_FLAG in VARCHAR2
,P_USE_PARNT_PRTL_MO_CD_FLAG in VARCHAR2
,P_ALLOC_SME_AS_PARNT_FLAG in VARCHAR2
,P_USE_PARNT_PYMT_SCHED_FLAG in VARCHAR2
,P_NO_CMBND_MX_AMT_DFND_FLAG in VARCHAR2
,P_CMBND_MX_AMT in NUMBER
,P_CMBND_MN_AMT in NUMBER
,P_CMBND_MX_PCT_NUM in NUMBER
,P_CMBND_MN_PCT_NUM in NUMBER
,P_NO_CMBND_MN_AMT_DFND_FLAG in VARCHAR2
,P_NO_CMBND_MN_PCT_DFND_FLAG in VARCHAR2
,P_NO_CMBND_MX_PCT_DFND_FLAG in VARCHAR2
,P_PARNT_ACTY_BASE_RT_ID in NUMBER
,P_CHLD_ACTY_BASE_RT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRD_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PRD_ATTRIBUTE1 in VARCHAR2
,P_PRD_ATTRIBUTE2 in VARCHAR2
,P_PRD_ATTRIBUTE3 in VARCHAR2
,P_PRD_ATTRIBUTE4 in VARCHAR2
,P_PRD_ATTRIBUTE5 in VARCHAR2
,P_PRD_ATTRIBUTE6 in VARCHAR2
,P_PRD_ATTRIBUTE7 in VARCHAR2
,P_PRD_ATTRIBUTE8 in VARCHAR2
,P_PRD_ATTRIBUTE9 in VARCHAR2
,P_PRD_ATTRIBUTE10 in VARCHAR2
,P_PRD_ATTRIBUTE11 in VARCHAR2
,P_PRD_ATTRIBUTE12 in VARCHAR2
,P_PRD_ATTRIBUTE13 in VARCHAR2
,P_PRD_ATTRIBUTE14 in VARCHAR2
,P_PRD_ATTRIBUTE15 in VARCHAR2
,P_PRD_ATTRIBUTE16 in VARCHAR2
,P_PRD_ATTRIBUTE17 in VARCHAR2
,P_PRD_ATTRIBUTE18 in VARCHAR2
,P_PRD_ATTRIBUTE19 in VARCHAR2
,P_PRD_ATTRIBUTE20 in VARCHAR2
,P_PRD_ATTRIBUTE21 in VARCHAR2
,P_PRD_ATTRIBUTE22 in VARCHAR2
,P_PRD_ATTRIBUTE23 in VARCHAR2
,P_PRD_ATTRIBUTE24 in VARCHAR2
,P_PRD_ATTRIBUTE25 in VARCHAR2
,P_PRD_ATTRIBUTE26 in VARCHAR2
,P_PRD_ATTRIBUTE27 in VARCHAR2
,P_PRD_ATTRIBUTE28 in VARCHAR2
,P_PRD_ATTRIBUTE29 in VARCHAR2
,P_PRD_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_USE_PARNT_DED_SCHED_FLAG_O in VARCHAR2
,P_ASN_ON_CHC_OF_PARNT_FLAG_O in VARCHAR2
,P_USE_PARNT_PRTL_MO_CD_FLAG_O in VARCHAR2
,P_ALLOC_SME_AS_PARNT_FLAG_O in VARCHAR2
,P_USE_PARNT_PYMT_SCHED_FLAG_O in VARCHAR2
,P_NO_CMBND_MX_AMT_DFND_FLAG_O in VARCHAR2
,P_CMBND_MX_AMT_O in NUMBER
,P_CMBND_MN_AMT_O in NUMBER
,P_CMBND_MX_PCT_NUM_O in NUMBER
,P_CMBND_MN_PCT_NUM_O in NUMBER
,P_NO_CMBND_MN_AMT_DFND_FLAG_O in VARCHAR2
,P_NO_CMBND_MN_PCT_DFND_FLAG_O in VARCHAR2
,P_NO_CMBND_MX_PCT_DFND_FLAG_O in VARCHAR2
,P_PARNT_ACTY_BASE_RT_ID_O in NUMBER
,P_CHLD_ACTY_BASE_RT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PRD_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PRD_ATTRIBUTE1_O in VARCHAR2
,P_PRD_ATTRIBUTE2_O in VARCHAR2
,P_PRD_ATTRIBUTE3_O in VARCHAR2
,P_PRD_ATTRIBUTE4_O in VARCHAR2
,P_PRD_ATTRIBUTE5_O in VARCHAR2
,P_PRD_ATTRIBUTE6_O in VARCHAR2
,P_PRD_ATTRIBUTE7_O in VARCHAR2
,P_PRD_ATTRIBUTE8_O in VARCHAR2
,P_PRD_ATTRIBUTE9_O in VARCHAR2
,P_PRD_ATTRIBUTE10_O in VARCHAR2
,P_PRD_ATTRIBUTE11_O in VARCHAR2
,P_PRD_ATTRIBUTE12_O in VARCHAR2
,P_PRD_ATTRIBUTE13_O in VARCHAR2
,P_PRD_ATTRIBUTE14_O in VARCHAR2
,P_PRD_ATTRIBUTE15_O in VARCHAR2
,P_PRD_ATTRIBUTE16_O in VARCHAR2
,P_PRD_ATTRIBUTE17_O in VARCHAR2
,P_PRD_ATTRIBUTE18_O in VARCHAR2
,P_PRD_ATTRIBUTE19_O in VARCHAR2
,P_PRD_ATTRIBUTE20_O in VARCHAR2
,P_PRD_ATTRIBUTE21_O in VARCHAR2
,P_PRD_ATTRIBUTE22_O in VARCHAR2
,P_PRD_ATTRIBUTE23_O in VARCHAR2
,P_PRD_ATTRIBUTE24_O in VARCHAR2
,P_PRD_ATTRIBUTE25_O in VARCHAR2
,P_PRD_ATTRIBUTE26_O in VARCHAR2
,P_PRD_ATTRIBUTE27_O in VARCHAR2
,P_PRD_ATTRIBUTE28_O in VARCHAR2
,P_PRD_ATTRIBUTE29_O in VARCHAR2
,P_PRD_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_prd_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_prd_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_prd_RKU;

/
