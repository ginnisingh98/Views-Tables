--------------------------------------------------------
--  DDL for Package Body BEN_HWF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_HWF_RKU" as
/* $Header: behwfrhi.pkb 120.0 2005/05/28 03:12:16 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_HRS_WKD_IN_PERD_FCTR_ID in NUMBER
,P_NAME in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_HRS_SRC_CD in VARCHAR2
,P_RNDG_CD in VARCHAR2
,P_RNDG_RL in NUMBER
,P_HRS_WKD_DET_CD in VARCHAR2
,P_HRS_WKD_DET_RL in NUMBER
,P_NO_MN_HRS_WKD_FLAG in VARCHAR2
,P_MX_HRS_NUM in NUMBER
,P_NO_MX_HRS_WKD_FLAG in VARCHAR2
,P_ONCE_R_CNTUG_CD in VARCHAR2
,P_MN_HRS_NUM in NUMBER
,P_HRS_ALT_VAL_TO_USE_CD in VARCHAR2
,P_PYRL_FREQ_CD in VARCHAR2
,P_HRS_WKD_CALC_RL in NUMBER
,P_DEFINED_BALANCE_ID in NUMBER
,P_BNFTS_BAL_ID in NUMBER
,P_HWF_ATTRIBUTE_CATEGORY in VARCHAR2
,P_HWF_ATTRIBUTE1 in VARCHAR2
,P_HWF_ATTRIBUTE2 in VARCHAR2
,P_HWF_ATTRIBUTE3 in VARCHAR2
,P_HWF_ATTRIBUTE4 in VARCHAR2
,P_HWF_ATTRIBUTE5 in VARCHAR2
,P_HWF_ATTRIBUTE6 in VARCHAR2
,P_HWF_ATTRIBUTE7 in VARCHAR2
,P_HWF_ATTRIBUTE8 in VARCHAR2
,P_HWF_ATTRIBUTE9 in VARCHAR2
,P_HWF_ATTRIBUTE10 in VARCHAR2
,P_HWF_ATTRIBUTE11 in VARCHAR2
,P_HWF_ATTRIBUTE12 in VARCHAR2
,P_HWF_ATTRIBUTE13 in VARCHAR2
,P_HWF_ATTRIBUTE14 in VARCHAR2
,P_HWF_ATTRIBUTE15 in VARCHAR2
,P_HWF_ATTRIBUTE16 in VARCHAR2
,P_HWF_ATTRIBUTE17 in VARCHAR2
,P_HWF_ATTRIBUTE18 in VARCHAR2
,P_HWF_ATTRIBUTE19 in VARCHAR2
,P_HWF_ATTRIBUTE20 in VARCHAR2
,P_HWF_ATTRIBUTE21 in VARCHAR2
,P_HWF_ATTRIBUTE22 in VARCHAR2
,P_HWF_ATTRIBUTE23 in VARCHAR2
,P_HWF_ATTRIBUTE24 in VARCHAR2
,P_HWF_ATTRIBUTE25 in VARCHAR2
,P_HWF_ATTRIBUTE26 in VARCHAR2
,P_HWF_ATTRIBUTE27 in VARCHAR2
,P_HWF_ATTRIBUTE28 in VARCHAR2
,P_HWF_ATTRIBUTE29 in VARCHAR2
,P_HWF_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_NAME_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_HRS_SRC_CD_O in VARCHAR2
,P_RNDG_CD_O in VARCHAR2
,P_RNDG_RL_O in NUMBER
,P_HRS_WKD_DET_CD_O in VARCHAR2
,P_HRS_WKD_DET_RL_O in NUMBER
,P_NO_MN_HRS_WKD_FLAG_O in VARCHAR2
,P_MX_HRS_NUM_O in NUMBER
,P_NO_MX_HRS_WKD_FLAG_O in VARCHAR2
,P_ONCE_R_CNTUG_CD_O in VARCHAR2
,P_MN_HRS_NUM_O in NUMBER
,P_HRS_ALT_VAL_TO_USE_CD_O in VARCHAR2
,P_PYRL_FREQ_CD_O in VARCHAR2
,P_HRS_WKD_CALC_RL_O in NUMBER
,P_DEFINED_BALANCE_ID_O in NUMBER
,P_BNFTS_BAL_ID_O in NUMBER
,P_HWF_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_HWF_ATTRIBUTE1_O in VARCHAR2
,P_HWF_ATTRIBUTE2_O in VARCHAR2
,P_HWF_ATTRIBUTE3_O in VARCHAR2
,P_HWF_ATTRIBUTE4_O in VARCHAR2
,P_HWF_ATTRIBUTE5_O in VARCHAR2
,P_HWF_ATTRIBUTE6_O in VARCHAR2
,P_HWF_ATTRIBUTE7_O in VARCHAR2
,P_HWF_ATTRIBUTE8_O in VARCHAR2
,P_HWF_ATTRIBUTE9_O in VARCHAR2
,P_HWF_ATTRIBUTE10_O in VARCHAR2
,P_HWF_ATTRIBUTE11_O in VARCHAR2
,P_HWF_ATTRIBUTE12_O in VARCHAR2
,P_HWF_ATTRIBUTE13_O in VARCHAR2
,P_HWF_ATTRIBUTE14_O in VARCHAR2
,P_HWF_ATTRIBUTE15_O in VARCHAR2
,P_HWF_ATTRIBUTE16_O in VARCHAR2
,P_HWF_ATTRIBUTE17_O in VARCHAR2
,P_HWF_ATTRIBUTE18_O in VARCHAR2
,P_HWF_ATTRIBUTE19_O in VARCHAR2
,P_HWF_ATTRIBUTE20_O in VARCHAR2
,P_HWF_ATTRIBUTE21_O in VARCHAR2
,P_HWF_ATTRIBUTE22_O in VARCHAR2
,P_HWF_ATTRIBUTE23_O in VARCHAR2
,P_HWF_ATTRIBUTE24_O in VARCHAR2
,P_HWF_ATTRIBUTE25_O in VARCHAR2
,P_HWF_ATTRIBUTE26_O in VARCHAR2
,P_HWF_ATTRIBUTE27_O in VARCHAR2
,P_HWF_ATTRIBUTE28_O in VARCHAR2
,P_HWF_ATTRIBUTE29_O in VARCHAR2
,P_HWF_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_hwf_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_hwf_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_hwf_RKU;

/