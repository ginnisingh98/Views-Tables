--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_BNFT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_BNFT_BK1" as
/* $Header: beenbapi.pkb 115.11 2002/12/16 07:02:01 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:06 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ENRT_BNFT_A
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
,P_PROGRAM_UPDATE_DATE in DATE
,P_MX_WOUT_CTFN_VAL in NUMBER
,P_MX_WO_CTFN_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_ENRT_BNFT_BK1.CREATE_ENRT_BNFT_A', 10);
hr_utility.set_location(' Leaving: BEN_ENRT_BNFT_BK1.CREATE_ENRT_BNFT_A', 20);
end CREATE_ENRT_BNFT_A;
procedure CREATE_ENRT_BNFT_B
(P_DFLT_FLAG in VARCHAR2
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
,P_PROGRAM_UPDATE_DATE in DATE
,P_MX_WOUT_CTFN_VAL in NUMBER
,P_MX_WO_CTFN_FLAG in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_ENRT_BNFT_BK1.CREATE_ENRT_BNFT_B', 10);
hr_utility.set_location(' Leaving: BEN_ENRT_BNFT_BK1.CREATE_ENRT_BNFT_B', 20);
end CREATE_ENRT_BNFT_B;
end BEN_ENRT_BNFT_BK1;

/