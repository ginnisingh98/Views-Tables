--------------------------------------------------------
--  DDL for Package Body BEN_CCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCT_RKU" as
/* $Header: becctrhi.pkb 120.0 2005/05/28 00:58:57 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:58 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CM_TYP_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_DESC_TXT in VARCHAR2
,P_CM_TYP_RL in NUMBER
,P_CM_USG_CD in VARCHAR2
,P_WHNVR_TRGRD_FLAG in VARCHAR2
,P_SHRT_NAME in VARCHAR2
,P_PC_KIT_CD in VARCHAR2
,P_TRK_MLG_FLAG in VARCHAR2
,P_MX_NUM_AVLBL_VAL in NUMBER
,P_TO_BE_SENT_DT_CD in VARCHAR2
,P_TO_BE_SENT_DT_RL in NUMBER
,P_INSPN_RQD_FLAG in VARCHAR2
,P_INSPN_RQD_RL in NUMBER
,P_RCPENT_CD in VARCHAR2
,P_PARNT_CM_TYP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_CCT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CCT_ATTRIBUTE1 in VARCHAR2
,P_CCT_ATTRIBUTE10 in VARCHAR2
,P_CCT_ATTRIBUTE11 in VARCHAR2
,P_CCT_ATTRIBUTE12 in VARCHAR2
,P_CCT_ATTRIBUTE13 in VARCHAR2
,P_CCT_ATTRIBUTE14 in VARCHAR2
,P_CCT_ATTRIBUTE15 in VARCHAR2
,P_CCT_ATTRIBUTE16 in VARCHAR2
,P_CCT_ATTRIBUTE17 in VARCHAR2
,P_CCT_ATTRIBUTE18 in VARCHAR2
,P_CCT_ATTRIBUTE19 in VARCHAR2
,P_CCT_ATTRIBUTE2 in VARCHAR2
,P_CCT_ATTRIBUTE20 in VARCHAR2
,P_CCT_ATTRIBUTE21 in VARCHAR2
,P_CCT_ATTRIBUTE22 in VARCHAR2
,P_CCT_ATTRIBUTE23 in VARCHAR2
,P_CCT_ATTRIBUTE24 in VARCHAR2
,P_CCT_ATTRIBUTE25 in VARCHAR2
,P_CCT_ATTRIBUTE26 in VARCHAR2
,P_CCT_ATTRIBUTE27 in VARCHAR2
,P_CCT_ATTRIBUTE28 in VARCHAR2
,P_CCT_ATTRIBUTE29 in VARCHAR2
,P_CCT_ATTRIBUTE3 in VARCHAR2
,P_CCT_ATTRIBUTE30 in VARCHAR2
,P_CCT_ATTRIBUTE4 in VARCHAR2
,P_CCT_ATTRIBUTE5 in VARCHAR2
,P_CCT_ATTRIBUTE6 in VARCHAR2
,P_CCT_ATTRIBUTE7 in VARCHAR2
,P_CCT_ATTRIBUTE8 in VARCHAR2
,P_CCT_ATTRIBUTE9 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_DESC_TXT_O in VARCHAR2
,P_CM_TYP_RL_O in NUMBER
,P_CM_USG_CD_O in VARCHAR2
,P_WHNVR_TRGRD_FLAG_O in VARCHAR2
,P_SHRT_NAME_O in VARCHAR2
,P_PC_KIT_CD_O in VARCHAR2
,P_TRK_MLG_FLAG_O in VARCHAR2
,P_MX_NUM_AVLBL_VAL_O in NUMBER
,P_TO_BE_SENT_DT_CD_O in VARCHAR2
,P_TO_BE_SENT_DT_RL_O in NUMBER
,P_INSPN_RQD_FLAG_O in VARCHAR2
,P_INSPN_RQD_RL_O in NUMBER
,P_RCPENT_CD_O in VARCHAR2
,P_PARNT_CM_TYP_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CCT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CCT_ATTRIBUTE1_O in VARCHAR2
,P_CCT_ATTRIBUTE10_O in VARCHAR2
,P_CCT_ATTRIBUTE11_O in VARCHAR2
,P_CCT_ATTRIBUTE12_O in VARCHAR2
,P_CCT_ATTRIBUTE13_O in VARCHAR2
,P_CCT_ATTRIBUTE14_O in VARCHAR2
,P_CCT_ATTRIBUTE15_O in VARCHAR2
,P_CCT_ATTRIBUTE16_O in VARCHAR2
,P_CCT_ATTRIBUTE17_O in VARCHAR2
,P_CCT_ATTRIBUTE18_O in VARCHAR2
,P_CCT_ATTRIBUTE19_O in VARCHAR2
,P_CCT_ATTRIBUTE2_O in VARCHAR2
,P_CCT_ATTRIBUTE20_O in VARCHAR2
,P_CCT_ATTRIBUTE21_O in VARCHAR2
,P_CCT_ATTRIBUTE22_O in VARCHAR2
,P_CCT_ATTRIBUTE23_O in VARCHAR2
,P_CCT_ATTRIBUTE24_O in VARCHAR2
,P_CCT_ATTRIBUTE25_O in VARCHAR2
,P_CCT_ATTRIBUTE26_O in VARCHAR2
,P_CCT_ATTRIBUTE27_O in VARCHAR2
,P_CCT_ATTRIBUTE28_O in VARCHAR2
,P_CCT_ATTRIBUTE29_O in VARCHAR2
,P_CCT_ATTRIBUTE3_O in VARCHAR2
,P_CCT_ATTRIBUTE30_O in VARCHAR2
,P_CCT_ATTRIBUTE4_O in VARCHAR2
,P_CCT_ATTRIBUTE5_O in VARCHAR2
,P_CCT_ATTRIBUTE6_O in VARCHAR2
,P_CCT_ATTRIBUTE7_O in VARCHAR2
,P_CCT_ATTRIBUTE8_O in VARCHAR2
,P_CCT_ATTRIBUTE9_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cct_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_cct_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_cct_RKU;

/