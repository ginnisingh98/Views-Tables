--------------------------------------------------------
--  DDL for Package Body BEN_LBR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LBR_RKU" as
/* $Header: belbrrhi.pkb 120.0 2005/05/28 03:16:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:40 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_LER_BNFT_RSTRN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NO_MX_CVG_AMT_APLS_FLAG in VARCHAR2
,P_NO_MN_CVG_INCR_APLS_FLAG in VARCHAR2
,P_NO_MX_CVG_INCR_APLS_FLAG in VARCHAR2
,P_MX_CVG_INCR_WCF_ALWD_AMT in NUMBER
,P_MX_CVG_INCR_ALWD_AMT in NUMBER
,P_MX_CVG_ALWD_AMT in NUMBER
,P_MX_CVG_MLT_INCR_NUM in NUMBER
,P_MX_CVG_MLT_INCR_WCF_NUM in NUMBER
,P_MX_CVG_RL in NUMBER
,P_MX_CVG_WCFN_AMT in NUMBER
,P_MX_CVG_WCFN_MLT_NUM in NUMBER
,P_MN_CVG_AMT in NUMBER
,P_MN_CVG_RL in NUMBER
,P_CVG_INCR_R_DECR_ONLY_CD in VARCHAR2
,P_UNSSPND_ENRT_CD in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_CD in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_RL in NUMBER
,P_LER_ID in NUMBER
,P_PL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_LBR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LBR_ATTRIBUTE1 in VARCHAR2
,P_LBR_ATTRIBUTE2 in VARCHAR2
,P_LBR_ATTRIBUTE3 in VARCHAR2
,P_LBR_ATTRIBUTE4 in VARCHAR2
,P_LBR_ATTRIBUTE5 in VARCHAR2
,P_LBR_ATTRIBUTE6 in VARCHAR2
,P_LBR_ATTRIBUTE7 in VARCHAR2
,P_LBR_ATTRIBUTE8 in VARCHAR2
,P_LBR_ATTRIBUTE9 in VARCHAR2
,P_LBR_ATTRIBUTE10 in VARCHAR2
,P_LBR_ATTRIBUTE11 in VARCHAR2
,P_LBR_ATTRIBUTE12 in VARCHAR2
,P_LBR_ATTRIBUTE13 in VARCHAR2
,P_LBR_ATTRIBUTE14 in VARCHAR2
,P_LBR_ATTRIBUTE15 in VARCHAR2
,P_LBR_ATTRIBUTE16 in VARCHAR2
,P_LBR_ATTRIBUTE17 in VARCHAR2
,P_LBR_ATTRIBUTE18 in VARCHAR2
,P_LBR_ATTRIBUTE19 in VARCHAR2
,P_LBR_ATTRIBUTE20 in VARCHAR2
,P_LBR_ATTRIBUTE21 in VARCHAR2
,P_LBR_ATTRIBUTE22 in VARCHAR2
,P_LBR_ATTRIBUTE23 in VARCHAR2
,P_LBR_ATTRIBUTE24 in VARCHAR2
,P_LBR_ATTRIBUTE25 in VARCHAR2
,P_LBR_ATTRIBUTE26 in VARCHAR2
,P_LBR_ATTRIBUTE27 in VARCHAR2
,P_LBR_ATTRIBUTE28 in VARCHAR2
,P_LBR_ATTRIBUTE29 in VARCHAR2
,P_LBR_ATTRIBUTE30 in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG in VARCHAR2
,P_CTFN_DETERMINE_CD in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NO_MX_CVG_AMT_APLS_FLAG_O in VARCHAR2
,P_NO_MN_CVG_INCR_APLS_FLAG_O in VARCHAR2
,P_NO_MX_CVG_INCR_APLS_FLAG_O in VARCHAR2
,P_MX_CVG_INCR_WCF_ALWD_AMT_O in NUMBER
,P_MX_CVG_INCR_ALWD_AMT_O in NUMBER
,P_MX_CVG_ALWD_AMT_O in NUMBER
,P_MX_CVG_MLT_INCR_NUM_O in NUMBER
,P_MX_CVG_MLT_INCR_WCF_NUM_O in NUMBER
,P_MX_CVG_RL_O in NUMBER
,P_MX_CVG_WCFN_AMT_O in NUMBER
,P_MX_CVG_WCFN_MLT_NUM_O in NUMBER
,P_MN_CVG_AMT_O in NUMBER
,P_MN_CVG_RL_O in NUMBER
,P_CVG_INCR_R_DECR_ONLY_CD_O in VARCHAR2
,P_UNSSPND_ENRT_CD_O in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_CD_O in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_RL_O in NUMBER
,P_LER_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PLIP_ID_O in NUMBER
,P_LBR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_LBR_ATTRIBUTE1_O in VARCHAR2
,P_LBR_ATTRIBUTE2_O in VARCHAR2
,P_LBR_ATTRIBUTE3_O in VARCHAR2
,P_LBR_ATTRIBUTE4_O in VARCHAR2
,P_LBR_ATTRIBUTE5_O in VARCHAR2
,P_LBR_ATTRIBUTE6_O in VARCHAR2
,P_LBR_ATTRIBUTE7_O in VARCHAR2
,P_LBR_ATTRIBUTE8_O in VARCHAR2
,P_LBR_ATTRIBUTE9_O in VARCHAR2
,P_LBR_ATTRIBUTE10_O in VARCHAR2
,P_LBR_ATTRIBUTE11_O in VARCHAR2
,P_LBR_ATTRIBUTE12_O in VARCHAR2
,P_LBR_ATTRIBUTE13_O in VARCHAR2
,P_LBR_ATTRIBUTE14_O in VARCHAR2
,P_LBR_ATTRIBUTE15_O in VARCHAR2
,P_LBR_ATTRIBUTE16_O in VARCHAR2
,P_LBR_ATTRIBUTE17_O in VARCHAR2
,P_LBR_ATTRIBUTE18_O in VARCHAR2
,P_LBR_ATTRIBUTE19_O in VARCHAR2
,P_LBR_ATTRIBUTE20_O in VARCHAR2
,P_LBR_ATTRIBUTE21_O in VARCHAR2
,P_LBR_ATTRIBUTE22_O in VARCHAR2
,P_LBR_ATTRIBUTE23_O in VARCHAR2
,P_LBR_ATTRIBUTE24_O in VARCHAR2
,P_LBR_ATTRIBUTE25_O in VARCHAR2
,P_LBR_ATTRIBUTE26_O in VARCHAR2
,P_LBR_ATTRIBUTE27_O in VARCHAR2
,P_LBR_ATTRIBUTE28_O in VARCHAR2
,P_LBR_ATTRIBUTE29_O in VARCHAR2
,P_LBR_ATTRIBUTE30_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG_O in VARCHAR2
,P_CTFN_DETERMINE_CD_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_lbr_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_lbr_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_lbr_RKU;

/
