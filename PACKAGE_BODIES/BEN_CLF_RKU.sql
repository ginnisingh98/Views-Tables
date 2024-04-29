--------------------------------------------------------
--  DDL for Package Body BEN_CLF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLF_RKU" as
/* $Header: beclfrhi.pkb 120.0 2005/05/28 01:04:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_COMP_LVL_FCTR_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_NAME in VARCHAR2
,P_COMP_LVL_DET_CD in VARCHAR2
,P_COMP_LVL_DET_RL in NUMBER
,P_COMP_LVL_UOM in VARCHAR2
,P_COMP_SRC_CD in VARCHAR2
,P_DEFINED_BALANCE_ID in NUMBER
,P_NO_MN_COMP_FLAG in VARCHAR2
,P_NO_MX_COMP_FLAG in VARCHAR2
,P_MX_COMP_VAL in NUMBER
,P_MN_COMP_VAL in NUMBER
,P_RNDG_CD in VARCHAR2
,P_RNDG_RL in NUMBER
,P_BNFTS_BAL_ID in NUMBER
,P_COMP_ALT_VAL_TO_USE_CD in VARCHAR2
,P_COMP_CALC_RL in NUMBER
,P_PRORATION_FLAG in VARCHAR2
,P_START_DAY_MO in VARCHAR2
,P_END_DAY_MO in VARCHAR2
,P_START_YEAR in VARCHAR2
,P_END_YEAR in VARCHAR2
,P_CLF_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CLF_ATTRIBUTE1 in VARCHAR2
,P_CLF_ATTRIBUTE2 in VARCHAR2
,P_CLF_ATTRIBUTE3 in VARCHAR2
,P_CLF_ATTRIBUTE4 in VARCHAR2
,P_CLF_ATTRIBUTE5 in VARCHAR2
,P_CLF_ATTRIBUTE6 in VARCHAR2
,P_CLF_ATTRIBUTE7 in VARCHAR2
,P_CLF_ATTRIBUTE8 in VARCHAR2
,P_CLF_ATTRIBUTE9 in VARCHAR2
,P_CLF_ATTRIBUTE10 in VARCHAR2
,P_CLF_ATTRIBUTE11 in VARCHAR2
,P_CLF_ATTRIBUTE12 in VARCHAR2
,P_CLF_ATTRIBUTE13 in VARCHAR2
,P_CLF_ATTRIBUTE14 in VARCHAR2
,P_CLF_ATTRIBUTE15 in VARCHAR2
,P_CLF_ATTRIBUTE16 in VARCHAR2
,P_CLF_ATTRIBUTE17 in VARCHAR2
,P_CLF_ATTRIBUTE18 in VARCHAR2
,P_CLF_ATTRIBUTE19 in VARCHAR2
,P_CLF_ATTRIBUTE20 in VARCHAR2
,P_CLF_ATTRIBUTE21 in VARCHAR2
,P_CLF_ATTRIBUTE22 in VARCHAR2
,P_CLF_ATTRIBUTE23 in VARCHAR2
,P_CLF_ATTRIBUTE24 in VARCHAR2
,P_CLF_ATTRIBUTE25 in VARCHAR2
,P_CLF_ATTRIBUTE26 in VARCHAR2
,P_CLF_ATTRIBUTE27 in VARCHAR2
,P_CLF_ATTRIBUTE28 in VARCHAR2
,P_CLF_ATTRIBUTE29 in VARCHAR2
,P_CLF_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_STTD_SAL_PRDCTY_CD in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_NAME_O in VARCHAR2
,P_COMP_LVL_DET_CD_O in VARCHAR2
,P_COMP_LVL_DET_RL_O in NUMBER
,P_COMP_LVL_UOM_O in VARCHAR2
,P_COMP_SRC_CD_O in VARCHAR2
,P_DEFINED_BALANCE_ID_O in NUMBER
,P_NO_MN_COMP_FLAG_O in VARCHAR2
,P_NO_MX_COMP_FLAG_O in VARCHAR2
,P_MX_COMP_VAL_O in NUMBER
,P_MN_COMP_VAL_O in NUMBER
,P_RNDG_CD_O in VARCHAR2
,P_RNDG_RL_O in NUMBER
,P_BNFTS_BAL_ID_O in NUMBER
,P_COMP_ALT_VAL_TO_USE_CD_O in VARCHAR2
,P_COMP_CALC_RL_O in NUMBER
,P_PRORATION_FLAG_O in VARCHAR2
,P_START_DAY_MO_O in VARCHAR2
,P_END_DAY_MO_O in VARCHAR2
,P_START_YEAR_O in VARCHAR2
,P_END_YEAR_O in VARCHAR2
,P_CLF_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CLF_ATTRIBUTE1_O in VARCHAR2
,P_CLF_ATTRIBUTE2_O in VARCHAR2
,P_CLF_ATTRIBUTE3_O in VARCHAR2
,P_CLF_ATTRIBUTE4_O in VARCHAR2
,P_CLF_ATTRIBUTE5_O in VARCHAR2
,P_CLF_ATTRIBUTE6_O in VARCHAR2
,P_CLF_ATTRIBUTE7_O in VARCHAR2
,P_CLF_ATTRIBUTE8_O in VARCHAR2
,P_CLF_ATTRIBUTE9_O in VARCHAR2
,P_CLF_ATTRIBUTE10_O in VARCHAR2
,P_CLF_ATTRIBUTE11_O in VARCHAR2
,P_CLF_ATTRIBUTE12_O in VARCHAR2
,P_CLF_ATTRIBUTE13_O in VARCHAR2
,P_CLF_ATTRIBUTE14_O in VARCHAR2
,P_CLF_ATTRIBUTE15_O in VARCHAR2
,P_CLF_ATTRIBUTE16_O in VARCHAR2
,P_CLF_ATTRIBUTE17_O in VARCHAR2
,P_CLF_ATTRIBUTE18_O in VARCHAR2
,P_CLF_ATTRIBUTE19_O in VARCHAR2
,P_CLF_ATTRIBUTE20_O in VARCHAR2
,P_CLF_ATTRIBUTE21_O in VARCHAR2
,P_CLF_ATTRIBUTE22_O in VARCHAR2
,P_CLF_ATTRIBUTE23_O in VARCHAR2
,P_CLF_ATTRIBUTE24_O in VARCHAR2
,P_CLF_ATTRIBUTE25_O in VARCHAR2
,P_CLF_ATTRIBUTE26_O in VARCHAR2
,P_CLF_ATTRIBUTE27_O in VARCHAR2
,P_CLF_ATTRIBUTE28_O in VARCHAR2
,P_CLF_ATTRIBUTE29_O in VARCHAR2
,P_CLF_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_STTD_SAL_PRDCTY_CD_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_clf_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_clf_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_clf_RKU;

/
