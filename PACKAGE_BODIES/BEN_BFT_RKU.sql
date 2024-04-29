--------------------------------------------------------
--  DDL for Package Body BEN_BFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BFT_RKU" as
/* $Header: bebftrhi.pkb 115.23 2003/08/18 05:05:29 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:40 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_BENEFIT_ACTION_ID in NUMBER
,P_PROCESS_DATE in DATE
,P_UNEAI_EFFECTIVE_DATE in DATE
,P_MODE_CD in VARCHAR2
,P_DERIVABLE_FACTORS_FLAG in VARCHAR2
,P_CLOSE_UNEAI_FLAG in VARCHAR2
,P_VALIDATE_FLAG in VARCHAR2
,P_PERSON_ID in NUMBER
,P_PERSON_TYPE_ID in NUMBER
,P_PGM_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PL_ID in NUMBER
,P_POPL_ENRT_TYP_CYCL_ID in NUMBER
,P_NO_PROGRAMS_FLAG in VARCHAR2
,P_NO_PLANS_FLAG in VARCHAR2
,P_COMP_SELECTION_RL in NUMBER
,P_PERSON_SELECTION_RL in NUMBER
,P_LER_ID in NUMBER
,P_ORGANIZATION_ID in NUMBER
,P_BENFTS_GRP_ID in NUMBER
,P_LOCATION_ID in NUMBER
,P_PSTL_ZIP_RNG_ID in NUMBER
,P_RPTG_GRP_ID in NUMBER
,P_PL_TYP_ID in NUMBER
,P_OPT_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_LEGAL_ENTITY_ID in NUMBER
,P_PAYROLL_ID in NUMBER
,P_DEBUG_MESSAGES_FLAG in VARCHAR2
,P_CM_TRGR_TYP_CD in VARCHAR2
,P_CM_TYP_ID in NUMBER
,P_AGE_FCTR_ID in NUMBER
,P_MIN_AGE in NUMBER
,P_MAX_AGE in NUMBER
,P_LOS_FCTR_ID in NUMBER
,P_MIN_LOS in NUMBER
,P_MAX_LOS in NUMBER
,P_CMBN_AGE_LOS_FCTR_ID in NUMBER
,P_MIN_CMBN in NUMBER
,P_MAX_CMBN in NUMBER
,P_DATE_FROM in DATE
,P_ELIG_ENROL_CD in VARCHAR2
,P_ACTN_TYP_ID in NUMBER
,P_USE_FCTR_TO_SEL_FLAG in VARCHAR2
,P_LOS_DET_TO_USE_CD in VARCHAR2
,P_AUDIT_LOG_FLAG in VARCHAR2
,P_LMT_PRPNIP_BY_ORG_FLAG in VARCHAR2
,P_LF_EVT_OCRD_DT in DATE
,P_PTNL_LER_FOR_PER_STAT_CD in VARCHAR2
,P_BFT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_BFT_ATTRIBUTE1 in VARCHAR2
,P_BFT_ATTRIBUTE3 in VARCHAR2
,P_BFT_ATTRIBUTE4 in VARCHAR2
,P_BFT_ATTRIBUTE5 in VARCHAR2
,P_BFT_ATTRIBUTE6 in VARCHAR2
,P_BFT_ATTRIBUTE7 in VARCHAR2
,P_BFT_ATTRIBUTE8 in VARCHAR2
,P_BFT_ATTRIBUTE9 in VARCHAR2
,P_BFT_ATTRIBUTE10 in VARCHAR2
,P_BFT_ATTRIBUTE11 in VARCHAR2
,P_BFT_ATTRIBUTE12 in VARCHAR2
,P_BFT_ATTRIBUTE13 in VARCHAR2
,P_BFT_ATTRIBUTE14 in VARCHAR2
,P_BFT_ATTRIBUTE15 in VARCHAR2
,P_BFT_ATTRIBUTE16 in VARCHAR2
,P_BFT_ATTRIBUTE17 in VARCHAR2
,P_BFT_ATTRIBUTE18 in VARCHAR2
,P_BFT_ATTRIBUTE19 in VARCHAR2
,P_BFT_ATTRIBUTE20 in VARCHAR2
,P_BFT_ATTRIBUTE21 in VARCHAR2
,P_BFT_ATTRIBUTE22 in VARCHAR2
,P_BFT_ATTRIBUTE23 in VARCHAR2
,P_BFT_ATTRIBUTE24 in VARCHAR2
,P_BFT_ATTRIBUTE25 in VARCHAR2
,P_BFT_ATTRIBUTE26 in VARCHAR2
,P_BFT_ATTRIBUTE27 in VARCHAR2
,P_BFT_ATTRIBUTE28 in VARCHAR2
,P_BFT_ATTRIBUTE29 in VARCHAR2
,P_BFT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ENRT_PERD_ID in NUMBER
,P_INELG_ACTION_CD in VARCHAR2
,P_ORG_HIERARCHY_ID in NUMBER
,P_ORG_STARTING_NODE_ID in NUMBER
,P_GRADE_LADDER_ID in NUMBER
,P_ASG_EVENTS_TO_ALL_SEL_DT in VARCHAR2
,P_RATE_ID in NUMBER
,P_PER_SEL_DT_CD in VARCHAR2
,P_PER_SEL_FREQ_CD in VARCHAR2
,P_PER_SEL_DT_FROM in DATE
,P_PER_SEL_DT_TO in DATE
,P_YEAR_FROM in NUMBER
,P_YEAR_TO in NUMBER
,P_CAGR_ID in NUMBER
,P_QUAL_TYPE in NUMBER
,P_QUAL_STATUS in VARCHAR2
,P_CONCAT_SEGS in VARCHAR2
,P_GRANT_PRICE_VAL in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_PROCESS_DATE_O in DATE
,P_UNEAI_EFFECTIVE_DATE_O in DATE
,P_MODE_CD_O in VARCHAR2
,P_DERIVABLE_FACTORS_FLAG_O in VARCHAR2
,P_CLOSE_UNEAI_FLAG_O in VARCHAR2
,P_VALIDATE_FLAG_O in VARCHAR2
,P_PERSON_ID_O in NUMBER
,P_PERSON_TYPE_ID_O in NUMBER
,P_PGM_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PL_ID_O in NUMBER
,P_POPL_ENRT_TYP_CYCL_ID_O in NUMBER
,P_NO_PROGRAMS_FLAG_O in VARCHAR2
,P_NO_PLANS_FLAG_O in VARCHAR2
,P_COMP_SELECTION_RL_O in NUMBER
,P_PERSON_SELECTION_RL_O in NUMBER
,P_LER_ID_O in NUMBER
,P_ORGANIZATION_ID_O in NUMBER
,P_BENFTS_GRP_ID_O in NUMBER
,P_LOCATION_ID_O in NUMBER
,P_PSTL_ZIP_RNG_ID_O in NUMBER
,P_RPTG_GRP_ID_O in NUMBER
,P_PL_TYP_ID_O in NUMBER
,P_OPT_ID_O in NUMBER
,P_ELIGY_PRFL_ID_O in NUMBER
,P_VRBL_RT_PRFL_ID_O in NUMBER
,P_LEGAL_ENTITY_ID_O in NUMBER
,P_PAYROLL_ID_O in NUMBER
,P_DEBUG_MESSAGES_FLAG_O in VARCHAR2
,P_CM_TRGR_TYP_CD_O in VARCHAR2
,P_CM_TYP_ID_O in NUMBER
,P_AGE_FCTR_ID_O in NUMBER
,P_MIN_AGE_O in NUMBER
,P_MAX_AGE_O in NUMBER
,P_LOS_FCTR_ID_O in NUMBER
,P_MIN_LOS_O in NUMBER
,P_MAX_LOS_O in NUMBER
,P_CMBN_AGE_LOS_FCTR_ID_O in NUMBER
,P_MIN_CMBN_O in NUMBER
,P_MAX_CMBN_O in NUMBER
,P_DATE_FROM_O in DATE
,P_ELIG_ENROL_CD_O in VARCHAR2
,P_ACTN_TYP_ID_O in NUMBER
,P_USE_FCTR_TO_SEL_FLAG_O in VARCHAR2
,P_LOS_DET_TO_USE_CD_O in VARCHAR2
,P_AUDIT_LOG_FLAG_O in VARCHAR2
,P_LMT_PRPNIP_BY_ORG_FLAG_O in VARCHAR2
,P_LF_EVT_OCRD_DT_O in DATE
,P_PTNL_LER_FOR_PER_STAT_CD_O in VARCHAR2
,P_BFT_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_BFT_ATTRIBUTE1_O in VARCHAR2
,P_BFT_ATTRIBUTE3_O in VARCHAR2
,P_BFT_ATTRIBUTE4_O in VARCHAR2
,P_BFT_ATTRIBUTE5_O in VARCHAR2
,P_BFT_ATTRIBUTE6_O in VARCHAR2
,P_BFT_ATTRIBUTE7_O in VARCHAR2
,P_BFT_ATTRIBUTE8_O in VARCHAR2
,P_BFT_ATTRIBUTE9_O in VARCHAR2
,P_BFT_ATTRIBUTE10_O in VARCHAR2
,P_BFT_ATTRIBUTE11_O in VARCHAR2
,P_BFT_ATTRIBUTE12_O in VARCHAR2
,P_BFT_ATTRIBUTE13_O in VARCHAR2
,P_BFT_ATTRIBUTE14_O in VARCHAR2
,P_BFT_ATTRIBUTE15_O in VARCHAR2
,P_BFT_ATTRIBUTE16_O in VARCHAR2
,P_BFT_ATTRIBUTE17_O in VARCHAR2
,P_BFT_ATTRIBUTE18_O in VARCHAR2
,P_BFT_ATTRIBUTE19_O in VARCHAR2
,P_BFT_ATTRIBUTE20_O in VARCHAR2
,P_BFT_ATTRIBUTE21_O in VARCHAR2
,P_BFT_ATTRIBUTE22_O in VARCHAR2
,P_BFT_ATTRIBUTE23_O in VARCHAR2
,P_BFT_ATTRIBUTE24_O in VARCHAR2
,P_BFT_ATTRIBUTE25_O in VARCHAR2
,P_BFT_ATTRIBUTE26_O in VARCHAR2
,P_BFT_ATTRIBUTE27_O in VARCHAR2
,P_BFT_ATTRIBUTE28_O in VARCHAR2
,P_BFT_ATTRIBUTE29_O in VARCHAR2
,P_BFT_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ENRT_PERD_ID_O in NUMBER
,P_INELG_ACTION_CD_O in VARCHAR2
,P_ORG_HIERARCHY_ID_O in NUMBER
,P_ORG_STARTING_NODE_ID_O in NUMBER
,P_GRADE_LADDER_ID_O in NUMBER
,P_ASG_EVENTS_TO_ALL_SEL_DT_O in VARCHAR2
,P_RATE_ID_O in NUMBER
,P_PER_SEL_DT_CD_O in VARCHAR2
,P_PER_SEL_FREQ_CD_O in VARCHAR2
,P_PER_SEL_DT_FROM_O in DATE
,P_PER_SEL_DT_TO_O in DATE
,P_YEAR_FROM_O in NUMBER
,P_YEAR_TO_O in NUMBER
,P_CAGR_ID_O in NUMBER
,P_QUAL_TYPE_O in NUMBER
,P_QUAL_STATUS_O in VARCHAR2
,P_CONCAT_SEGS_O in VARCHAR2
,P_GRANT_PRICE_VAL_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_bft_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_bft_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_bft_RKU;

/