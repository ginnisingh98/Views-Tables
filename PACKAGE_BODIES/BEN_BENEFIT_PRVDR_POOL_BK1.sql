--------------------------------------------------------
--  DDL for Package Body BEN_BENEFIT_PRVDR_POOL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFIT_PRVDR_POOL_BK1" as
/* $Header: bebppapi.pkb 120.0 2005/05/28 00:48:09 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:47 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_BENEFIT_PRVDR_POOL_A
(P_BNFT_PRVDR_POOL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_PGM_POOL_FLAG in VARCHAR2
,P_EXCS_ALWYS_FFTD_FLAG in VARCHAR2
,P_USE_FOR_PGM_POOL_FLAG in VARCHAR2
,P_PCT_RNDG_CD in VARCHAR2
,P_PCT_RNDG_RL in NUMBER
,P_VAL_RNDG_CD in VARCHAR2
,P_VAL_RNDG_RL in NUMBER
,P_DFLT_EXCS_TRTMT_CD in VARCHAR2
,P_DFLT_EXCS_TRTMT_RL in NUMBER
,P_RLOVR_RSTRCN_CD in VARCHAR2
,P_NO_MN_DSTRBL_PCT_FLAG in VARCHAR2
,P_NO_MN_DSTRBL_VAL_FLAG in VARCHAR2
,P_NO_MX_DSTRBL_PCT_FLAG in VARCHAR2
,P_NO_MX_DSTRBL_VAL_FLAG in VARCHAR2
,P_AUTO_ALCT_EXCS_FLAG in VARCHAR2
,P_ALWS_NGTV_CRS_FLAG in VARCHAR2
,P_USES_NET_CRS_MTHD_FLAG in VARCHAR2
,P_MX_DFCIT_PCT_POOL_CRS_NUM in NUMBER
,P_MX_DFCIT_PCT_COMP_NUM in NUMBER
,P_COMP_LVL_FCTR_ID in NUMBER
,P_MN_DSTRBL_PCT_NUM in NUMBER
,P_MN_DSTRBL_VAL in NUMBER
,P_MX_DSTRBL_PCT_NUM in NUMBER
,P_MX_DSTRBL_VAL in NUMBER
,P_EXCS_TRTMT_CD in VARCHAR2
,P_PTIP_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_PGM_ID in NUMBER
,P_OIPLIP_ID in NUMBER
,P_CMBN_PLIP_ID in NUMBER
,P_CMBN_PTIP_ID in NUMBER
,P_CMBN_PTIP_OPT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_BPP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_BPP_ATTRIBUTE1 in VARCHAR2
,P_BPP_ATTRIBUTE2 in VARCHAR2
,P_BPP_ATTRIBUTE3 in VARCHAR2
,P_BPP_ATTRIBUTE4 in VARCHAR2
,P_BPP_ATTRIBUTE5 in VARCHAR2
,P_BPP_ATTRIBUTE6 in VARCHAR2
,P_BPP_ATTRIBUTE7 in VARCHAR2
,P_BPP_ATTRIBUTE8 in VARCHAR2
,P_BPP_ATTRIBUTE9 in VARCHAR2
,P_BPP_ATTRIBUTE10 in VARCHAR2
,P_BPP_ATTRIBUTE11 in VARCHAR2
,P_BPP_ATTRIBUTE12 in VARCHAR2
,P_BPP_ATTRIBUTE13 in VARCHAR2
,P_BPP_ATTRIBUTE14 in VARCHAR2
,P_BPP_ATTRIBUTE15 in VARCHAR2
,P_BPP_ATTRIBUTE16 in VARCHAR2
,P_BPP_ATTRIBUTE17 in VARCHAR2
,P_BPP_ATTRIBUTE18 in VARCHAR2
,P_BPP_ATTRIBUTE19 in VARCHAR2
,P_BPP_ATTRIBUTE20 in VARCHAR2
,P_BPP_ATTRIBUTE21 in VARCHAR2
,P_BPP_ATTRIBUTE22 in VARCHAR2
,P_BPP_ATTRIBUTE23 in VARCHAR2
,P_BPP_ATTRIBUTE24 in VARCHAR2
,P_BPP_ATTRIBUTE25 in VARCHAR2
,P_BPP_ATTRIBUTE26 in VARCHAR2
,P_BPP_ATTRIBUTE27 in VARCHAR2
,P_BPP_ATTRIBUTE28 in VARCHAR2
,P_BPP_ATTRIBUTE29 in VARCHAR2
,P_BPP_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BENEFIT_PRVDR_POOL_BK1.CREATE_BENEFIT_PRVDR_POOL_A', 10);
hr_utility.set_location(' Leaving: BEN_BENEFIT_PRVDR_POOL_BK1.CREATE_BENEFIT_PRVDR_POOL_A', 20);
end CREATE_BENEFIT_PRVDR_POOL_A;
procedure CREATE_BENEFIT_PRVDR_POOL_B
(P_NAME in VARCHAR2
,P_PGM_POOL_FLAG in VARCHAR2
,P_EXCS_ALWYS_FFTD_FLAG in VARCHAR2
,P_USE_FOR_PGM_POOL_FLAG in VARCHAR2
,P_PCT_RNDG_CD in VARCHAR2
,P_PCT_RNDG_RL in NUMBER
,P_VAL_RNDG_CD in VARCHAR2
,P_VAL_RNDG_RL in NUMBER
,P_DFLT_EXCS_TRTMT_CD in VARCHAR2
,P_DFLT_EXCS_TRTMT_RL in NUMBER
,P_RLOVR_RSTRCN_CD in VARCHAR2
,P_NO_MN_DSTRBL_PCT_FLAG in VARCHAR2
,P_NO_MN_DSTRBL_VAL_FLAG in VARCHAR2
,P_NO_MX_DSTRBL_PCT_FLAG in VARCHAR2
,P_NO_MX_DSTRBL_VAL_FLAG in VARCHAR2
,P_AUTO_ALCT_EXCS_FLAG in VARCHAR2
,P_ALWS_NGTV_CRS_FLAG in VARCHAR2
,P_USES_NET_CRS_MTHD_FLAG in VARCHAR2
,P_MX_DFCIT_PCT_POOL_CRS_NUM in NUMBER
,P_MX_DFCIT_PCT_COMP_NUM in NUMBER
,P_COMP_LVL_FCTR_ID in NUMBER
,P_MN_DSTRBL_PCT_NUM in NUMBER
,P_MN_DSTRBL_VAL in NUMBER
,P_MX_DSTRBL_PCT_NUM in NUMBER
,P_MX_DSTRBL_VAL in NUMBER
,P_EXCS_TRTMT_CD in VARCHAR2
,P_PTIP_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_PGM_ID in NUMBER
,P_OIPLIP_ID in NUMBER
,P_CMBN_PLIP_ID in NUMBER
,P_CMBN_PTIP_ID in NUMBER
,P_CMBN_PTIP_OPT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_BPP_ATTRIBUTE_CATEGORY in VARCHAR2
,P_BPP_ATTRIBUTE1 in VARCHAR2
,P_BPP_ATTRIBUTE2 in VARCHAR2
,P_BPP_ATTRIBUTE3 in VARCHAR2
,P_BPP_ATTRIBUTE4 in VARCHAR2
,P_BPP_ATTRIBUTE5 in VARCHAR2
,P_BPP_ATTRIBUTE6 in VARCHAR2
,P_BPP_ATTRIBUTE7 in VARCHAR2
,P_BPP_ATTRIBUTE8 in VARCHAR2
,P_BPP_ATTRIBUTE9 in VARCHAR2
,P_BPP_ATTRIBUTE10 in VARCHAR2
,P_BPP_ATTRIBUTE11 in VARCHAR2
,P_BPP_ATTRIBUTE12 in VARCHAR2
,P_BPP_ATTRIBUTE13 in VARCHAR2
,P_BPP_ATTRIBUTE14 in VARCHAR2
,P_BPP_ATTRIBUTE15 in VARCHAR2
,P_BPP_ATTRIBUTE16 in VARCHAR2
,P_BPP_ATTRIBUTE17 in VARCHAR2
,P_BPP_ATTRIBUTE18 in VARCHAR2
,P_BPP_ATTRIBUTE19 in VARCHAR2
,P_BPP_ATTRIBUTE20 in VARCHAR2
,P_BPP_ATTRIBUTE21 in VARCHAR2
,P_BPP_ATTRIBUTE22 in VARCHAR2
,P_BPP_ATTRIBUTE23 in VARCHAR2
,P_BPP_ATTRIBUTE24 in VARCHAR2
,P_BPP_ATTRIBUTE25 in VARCHAR2
,P_BPP_ATTRIBUTE26 in VARCHAR2
,P_BPP_ATTRIBUTE27 in VARCHAR2
,P_BPP_ATTRIBUTE28 in VARCHAR2
,P_BPP_ATTRIBUTE29 in VARCHAR2
,P_BPP_ATTRIBUTE30 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BENEFIT_PRVDR_POOL_BK1.CREATE_BENEFIT_PRVDR_POOL_B', 10);
hr_utility.set_location(' Leaving: BEN_BENEFIT_PRVDR_POOL_BK1.CREATE_BENEFIT_PRVDR_POOL_B', 20);
end CREATE_BENEFIT_PRVDR_POOL_B;
end BEN_BENEFIT_PRVDR_POOL_BK1;

/
