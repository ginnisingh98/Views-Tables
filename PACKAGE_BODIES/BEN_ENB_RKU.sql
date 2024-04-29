--------------------------------------------------------
--  DDL for Package Body BEN_ENB_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENB_RKU" as
/* $Header: beenbrhi.pkb 115.15 2002/12/16 07:02:08 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:07 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_ENRT_BNFT_ID in NUMBER
,P_DFLT_FLAG in VARCHAR2
,P_VAL_HAS_BN_PRORTD_FLAG in VARCHAR2
,P_BNDRY_PERD_CD in VARCHAR2
,P_VAL in NUMBER
,P_NNMNTRY_UOM in VARCHAR2
,P_BNFT_TYP_CD in VARCHAR2
,P_ENTR_VAL_AT_ENRT_FLAG in VARCHAR2
,P_MN_VAL in NUMBER
,P_MX_VAL in NUMBER
,P_INCRMT_VAL in NUMBER
,P_DFLT_VAL in NUMBER
,P_RT_TYP_CD in VARCHAR2
,P_CVG_MLT_CD in VARCHAR2
,P_CTFN_RQD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_CRNTLY_ENRLD_FLAG in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID in NUMBER
,P_PRTT_ENRT_RSLT_ID in NUMBER
,P_COMP_LVL_FCTR_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_ENB_ATTRIBUTE_CATEGORY in VARCHAR2
,P_ENB_ATTRIBUTE1 in VARCHAR2
,P_ENB_ATTRIBUTE2 in VARCHAR2
,P_ENB_ATTRIBUTE3 in VARCHAR2
,P_ENB_ATTRIBUTE4 in VARCHAR2
,P_ENB_ATTRIBUTE5 in VARCHAR2
,P_ENB_ATTRIBUTE6 in VARCHAR2
,P_ENB_ATTRIBUTE7 in VARCHAR2
,P_ENB_ATTRIBUTE8 in VARCHAR2
,P_ENB_ATTRIBUTE9 in VARCHAR2
,P_ENB_ATTRIBUTE10 in VARCHAR2
,P_ENB_ATTRIBUTE11 in VARCHAR2
,P_ENB_ATTRIBUTE12 in VARCHAR2
,P_ENB_ATTRIBUTE13 in VARCHAR2
,P_ENB_ATTRIBUTE14 in VARCHAR2
,P_ENB_ATTRIBUTE15 in VARCHAR2
,P_ENB_ATTRIBUTE16 in VARCHAR2
,P_ENB_ATTRIBUTE17 in VARCHAR2
,P_ENB_ATTRIBUTE18 in VARCHAR2
,P_ENB_ATTRIBUTE19 in VARCHAR2
,P_ENB_ATTRIBUTE20 in VARCHAR2
,P_ENB_ATTRIBUTE21 in VARCHAR2
,P_ENB_ATTRIBUTE22 in VARCHAR2
,P_ENB_ATTRIBUTE23 in VARCHAR2
,P_ENB_ATTRIBUTE24 in VARCHAR2
,P_ENB_ATTRIBUTE25 in VARCHAR2
,P_ENB_ATTRIBUTE26 in VARCHAR2
,P_ENB_ATTRIBUTE27 in VARCHAR2
,P_ENB_ATTRIBUTE28 in VARCHAR2
,P_ENB_ATTRIBUTE29 in VARCHAR2
,P_ENB_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_MX_WOUT_CTFN_VAL in NUMBER
,P_MX_WO_CTFN_FLAG in VARCHAR2
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DFLT_FLAG_O in VARCHAR2
,P_VAL_HAS_BN_PRORTD_FLAG_O in VARCHAR2
,P_BNDRY_PERD_CD_O in VARCHAR2
,P_VAL_O in NUMBER
,P_NNMNTRY_UOM_O in VARCHAR2
,P_BNFT_TYP_CD_O in VARCHAR2
,P_ENTR_VAL_AT_ENRT_FLAG_O in VARCHAR2
,P_MN_VAL_O in NUMBER
,P_MX_VAL_O in NUMBER
,P_INCRMT_VAL_O in NUMBER
,P_DFLT_VAL_O in NUMBER
,P_RT_TYP_CD_O in VARCHAR2
,P_CVG_MLT_CD_O in VARCHAR2
,P_CTFN_RQD_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_CRNTLY_ENRLD_FLAG_O in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID_O in NUMBER
,P_PRTT_ENRT_RSLT_ID_O in NUMBER
,P_COMP_LVL_FCTR_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ENB_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_ENB_ATTRIBUTE1_O in VARCHAR2
,P_ENB_ATTRIBUTE2_O in VARCHAR2
,P_ENB_ATTRIBUTE3_O in VARCHAR2
,P_ENB_ATTRIBUTE4_O in VARCHAR2
,P_ENB_ATTRIBUTE5_O in VARCHAR2
,P_ENB_ATTRIBUTE6_O in VARCHAR2
,P_ENB_ATTRIBUTE7_O in VARCHAR2
,P_ENB_ATTRIBUTE8_O in VARCHAR2
,P_ENB_ATTRIBUTE9_O in VARCHAR2
,P_ENB_ATTRIBUTE10_O in VARCHAR2
,P_ENB_ATTRIBUTE11_O in VARCHAR2
,P_ENB_ATTRIBUTE12_O in VARCHAR2
,P_ENB_ATTRIBUTE13_O in VARCHAR2
,P_ENB_ATTRIBUTE14_O in VARCHAR2
,P_ENB_ATTRIBUTE15_O in VARCHAR2
,P_ENB_ATTRIBUTE16_O in VARCHAR2
,P_ENB_ATTRIBUTE17_O in VARCHAR2
,P_ENB_ATTRIBUTE18_O in VARCHAR2
,P_ENB_ATTRIBUTE19_O in VARCHAR2
,P_ENB_ATTRIBUTE20_O in VARCHAR2
,P_ENB_ATTRIBUTE21_O in VARCHAR2
,P_ENB_ATTRIBUTE22_O in VARCHAR2
,P_ENB_ATTRIBUTE23_O in VARCHAR2
,P_ENB_ATTRIBUTE24_O in VARCHAR2
,P_ENB_ATTRIBUTE25_O in VARCHAR2
,P_ENB_ATTRIBUTE26_O in VARCHAR2
,P_ENB_ATTRIBUTE27_O in VARCHAR2
,P_ENB_ATTRIBUTE28_O in VARCHAR2
,P_ENB_ATTRIBUTE29_O in VARCHAR2
,P_ENB_ATTRIBUTE30_O in VARCHAR2
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_MX_WOUT_CTFN_VAL_O in NUMBER
,P_MX_WO_CTFN_FLAG_O in VARCHAR2
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_enb_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_enb_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_enb_RKU;

/
