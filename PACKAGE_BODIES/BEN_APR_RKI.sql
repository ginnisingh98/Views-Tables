--------------------------------------------------------
--  DDL for Package Body BEN_APR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_APR_RKI" as
/* $Header: beaprrhi.pkb 120.0 2005/05/28 00:26:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:28 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_ACTL_PREM_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_ACTY_REF_PERD_CD in VARCHAR2
,P_UOM in VARCHAR2
,P_RT_TYP_CD in VARCHAR2
,P_BNFT_RT_TYP_CD in VARCHAR2
,P_VAL in NUMBER
,P_MLT_CD in VARCHAR2
,P_PRDCT_CD in VARCHAR2
,P_RNDG_CD in VARCHAR2
,P_RNDG_RL in NUMBER
,P_VAL_CALC_RL in NUMBER
,P_PREM_ASNMT_CD in VARCHAR2
,P_PREM_ASNMT_LVL_CD in VARCHAR2
,P_ACTL_PREM_TYP_CD in VARCHAR2
,P_PREM_PYR_CD in VARCHAR2
,P_CR_LKBK_VAL in NUMBER
,P_CR_LKBK_UOM in VARCHAR2
,P_CR_LKBK_CRNT_PY_ONLY_FLAG in VARCHAR2
,P_PRSPTV_R_RTSPTV_CD in VARCHAR2
,P_UPR_LMT_VAL in NUMBER
,P_UPR_LMT_CALC_RL in NUMBER
,P_LWR_LMT_VAL in NUMBER
,P_LWR_LMT_CALC_RL in NUMBER
,P_COST_ALLOCATION_KEYFLEX_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_PL_ID in NUMBER
,P_COMP_LVL_FCTR_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PRTL_MO_DET_MTHD_CD in VARCHAR2
,P_PRTL_MO_DET_MTHD_RL in NUMBER
,P_WSH_RL_DY_MO_NUM in NUMBER
,P_VRBL_RT_ADD_ON_CALC_RL in NUMBER
,P_APR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_APR_ATTRIBUTE1 in VARCHAR2
,P_APR_ATTRIBUTE2 in VARCHAR2
,P_APR_ATTRIBUTE3 in VARCHAR2
,P_APR_ATTRIBUTE4 in VARCHAR2
,P_APR_ATTRIBUTE5 in VARCHAR2
,P_APR_ATTRIBUTE6 in VARCHAR2
,P_APR_ATTRIBUTE7 in VARCHAR2
,P_APR_ATTRIBUTE8 in VARCHAR2
,P_APR_ATTRIBUTE9 in VARCHAR2
,P_APR_ATTRIBUTE10 in VARCHAR2
,P_APR_ATTRIBUTE11 in VARCHAR2
,P_APR_ATTRIBUTE12 in VARCHAR2
,P_APR_ATTRIBUTE13 in VARCHAR2
,P_APR_ATTRIBUTE14 in VARCHAR2
,P_APR_ATTRIBUTE15 in VARCHAR2
,P_APR_ATTRIBUTE16 in VARCHAR2
,P_APR_ATTRIBUTE17 in VARCHAR2
,P_APR_ATTRIBUTE18 in VARCHAR2
,P_APR_ATTRIBUTE19 in VARCHAR2
,P_APR_ATTRIBUTE20 in VARCHAR2
,P_APR_ATTRIBUTE21 in VARCHAR2
,P_APR_ATTRIBUTE22 in VARCHAR2
,P_APR_ATTRIBUTE23 in VARCHAR2
,P_APR_ATTRIBUTE24 in VARCHAR2
,P_APR_ATTRIBUTE25 in VARCHAR2
,P_APR_ATTRIBUTE26 in VARCHAR2
,P_APR_ATTRIBUTE27 in VARCHAR2
,P_APR_ATTRIBUTE28 in VARCHAR2
,P_APR_ATTRIBUTE29 in VARCHAR2
,P_APR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_apr_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_apr_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_apr_RKI;

/
