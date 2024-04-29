--------------------------------------------------------
--  DDL for Package Body BEN_CCM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCM_RKD" as
/* $Header: beccmrhi.pkb 120.5 2006/03/22 02:53:46 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:57 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_CVG_AMT_CALC_MTHD_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_INCRMT_VAL_O in NUMBER
,P_MX_VAL_O in NUMBER
,P_MN_VAL_O in NUMBER
,P_NO_MX_VAL_DFND_FLAG_O in VARCHAR2
,P_NO_MN_VAL_DFND_FLAG_O in VARCHAR2
,P_RNDG_CD_O in VARCHAR2
,P_RNDG_RL_O in NUMBER
,P_LWR_LMT_VAL_O in NUMBER
,P_LWR_LMT_CALC_RL_O in NUMBER
,P_UPR_LMT_VAL_O in NUMBER
,P_UPR_LMT_CALC_RL_O in NUMBER
,P_VAL_O in NUMBER
,P_VAL_OVRID_ALWD_FLAG_O in VARCHAR2
,P_VAL_CALC_RL_O in NUMBER
,P_UOM_O in VARCHAR2
,P_NNMNTRY_UOM_O in VARCHAR2
,P_BNDRY_PERD_CD_O in VARCHAR2
,P_BNFT_TYP_CD_O in VARCHAR2
,P_CVG_MLT_CD_O in VARCHAR2
,P_RT_TYP_CD_O in VARCHAR2
,P_DFLT_VAL_O in NUMBER
,P_ENTR_VAL_AT_ENRT_FLAG_O in VARCHAR2
,P_DFLT_FLAG_O in VARCHAR2
,P_COMP_LVL_FCTR_ID_O in NUMBER
,P_OIPL_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_PLIP_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CCM_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CCM_ATTRIBUTE1_O in VARCHAR2
,P_CCM_ATTRIBUTE2_O in VARCHAR2
,P_CCM_ATTRIBUTE3_O in VARCHAR2
,P_CCM_ATTRIBUTE4_O in VARCHAR2
,P_CCM_ATTRIBUTE5_O in VARCHAR2
,P_CCM_ATTRIBUTE6_O in VARCHAR2
,P_CCM_ATTRIBUTE7_O in VARCHAR2
,P_CCM_ATTRIBUTE8_O in VARCHAR2
,P_CCM_ATTRIBUTE9_O in VARCHAR2
,P_CCM_ATTRIBUTE10_O in VARCHAR2
,P_CCM_ATTRIBUTE11_O in VARCHAR2
,P_CCM_ATTRIBUTE12_O in VARCHAR2
,P_CCM_ATTRIBUTE13_O in VARCHAR2
,P_CCM_ATTRIBUTE14_O in VARCHAR2
,P_CCM_ATTRIBUTE15_O in VARCHAR2
,P_CCM_ATTRIBUTE16_O in VARCHAR2
,P_CCM_ATTRIBUTE17_O in VARCHAR2
,P_CCM_ATTRIBUTE18_O in VARCHAR2
,P_CCM_ATTRIBUTE19_O in VARCHAR2
,P_CCM_ATTRIBUTE20_O in VARCHAR2
,P_CCM_ATTRIBUTE21_O in VARCHAR2
,P_CCM_ATTRIBUTE22_O in VARCHAR2
,P_CCM_ATTRIBUTE23_O in VARCHAR2
,P_CCM_ATTRIBUTE24_O in VARCHAR2
,P_CCM_ATTRIBUTE25_O in VARCHAR2
,P_CCM_ATTRIBUTE26_O in VARCHAR2
,P_CCM_ATTRIBUTE27_O in VARCHAR2
,P_CCM_ATTRIBUTE28_O in VARCHAR2
,P_CCM_ATTRIBUTE29_O in VARCHAR2
,P_CCM_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ccm_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ccm_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ccm_RKD;

/