--------------------------------------------------------
--  DDL for Package Body BEN_PGM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PGM_RKD" as
/* $Header: bepgmrhi.pkb 120.1 2005/12/09 05:02:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:23 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PGM_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_DPNT_ADRS_RQD_FLAG_O in VARCHAR2
,P_PGM_PRVDS_NO_AUTO_ENRT_FLA_O in VARCHAR2
,P_DPNT_DOB_RQD_FLAG_O in VARCHAR2
,P_PGM_PRVDS_NO_DFLT_ENRT_FLA_O in VARCHAR2
,P_DPNT_LEGV_ID_RQD_FLAG_O in VARCHAR2
,P_DPNT_DSGN_LVL_CD_O in VARCHAR2
,P_PGM_STAT_CD_O in VARCHAR2
,P_IVR_IDENT_O in VARCHAR2
,P_PGM_TYP_CD_O in VARCHAR2
,P_ELIG_APLS_FLAG_O in VARCHAR2
,P_USES_ALL_ASMTS_FOR_RTS_FLA_O in VARCHAR2
,P_URL_REF_NAME_O in VARCHAR2
,P_PGM_DESC_O in VARCHAR2
,P_PRTN_ELIG_OVRID_ALWD_FLAG_O in VARCHAR2
,P_PGM_USE_ALL_ASNTS_ELIG_FLA_O in VARCHAR2
,P_DPNT_DSGN_CD_O in VARCHAR2
,P_MX_DPNT_PCT_PRTT_LF_AMT_O in NUMBER
,P_MX_SPS_PCT_PRTT_LF_AMT_O in NUMBER
,P_ACTY_REF_PERD_CD_O in VARCHAR2
,P_COORD_CVG_FOR_ALL_PLS_FLG_O in VARCHAR2
,P_ENRT_CVG_END_DT_CD_O in VARCHAR2
,P_ENRT_CVG_END_DT_RL_O in NUMBER
,P_DPNT_CVG_END_DT_CD_O in VARCHAR2
,P_DPNT_CVG_END_DT_RL_O in NUMBER
,P_DPNT_CVG_STRT_DT_CD_O in VARCHAR2
,P_DPNT_CVG_STRT_DT_RL_O in NUMBER
,P_DPNT_DSGN_NO_CTFN_RQD_FLAG_O in VARCHAR2
,P_DRVBL_FCTR_DPNT_ELIG_FLAG_O in VARCHAR2
,P_DRVBL_FCTR_PRTN_ELIG_FLAG_O in VARCHAR2
,P_ENRT_CVG_STRT_DT_CD_O in VARCHAR2
,P_ENRT_CVG_STRT_DT_RL_O in NUMBER
,P_ENRT_INFO_RT_FREQ_CD_O in VARCHAR2
,P_RT_STRT_DT_CD_O in VARCHAR2
,P_RT_STRT_DT_RL_O in NUMBER
,P_RT_END_DT_CD_O in VARCHAR2
,P_RT_END_DT_RL_O in NUMBER
,P_PGM_GRP_CD_O in VARCHAR2
,P_PGM_UOM_O in VARCHAR2
,P_DRVBL_FCTR_APLS_RTS_FLAG_O in VARCHAR2
,P_ALWS_UNRSTRCTD_ENRT_FLAG_O in VARCHAR2
,P_ENRT_CD_O in VARCHAR2
,P_ENRT_MTHD_CD_O in VARCHAR2
,P_POE_LVL_CD_O in VARCHAR2
,P_ENRT_RL_O in NUMBER
,P_AUTO_ENRT_MTHD_RL_O in NUMBER
,P_TRK_INELIG_PER_FLAG_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PER_CVRD_CD_O in VARCHAR2
,P_VRFY_FMLY_MMBR_RL_O in NUMBER
,P_VRFY_FMLY_MMBR_CD_O in VARCHAR2
,P_SHORT_NAME_O in VARCHAR2
,P_SHORT_CODE_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_LEGISLATION_SUBGROUP_O in VARCHAR2
,P_DFLT_PGM_FLAG_O in VARCHAR2
,P_USE_PROG_POINTS_FLAG_O in VARCHAR2
,P_DFLT_STEP_CD_O in VARCHAR2
,P_DFLT_STEP_RL_O in NUMBER
,P_UPDATE_SALARY_CD_O in VARCHAR2
,P_USE_MULTI_PAY_RATES_FLAG_O in VARCHAR2
,P_DFLT_ELEMENT_TYPE_ID_O in NUMBER
,P_DFLT_INPUT_VALUE_ID_O in NUMBER
,P_USE_SCORES_CD_O in VARCHAR2
,P_SCORES_CALC_MTHD_CD_O in VARCHAR2
,P_SCORES_CALC_RL_O in NUMBER
,P_GSP_ALLOW_OVERRIDE_FLAG_O in VARCHAR2
,P_USE_VARIABLE_RATES_FLAG_O in VARCHAR2
,P_SALARY_CALC_MTHD_CD_O in VARCHAR2
,P_SALARY_CALC_MTHD_RL_O in NUMBER
,P_SUSP_IF_DPNT_SSN_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_DOB_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_ADR_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_DPNT_FLAG_O in VARCHAR2
,P_DPNT_CTFN_DETERMINE_CD_O in VARCHAR2
,P_PGM_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PGM_ATTRIBUTE1_O in VARCHAR2
,P_PGM_ATTRIBUTE2_O in VARCHAR2
,P_PGM_ATTRIBUTE3_O in VARCHAR2
,P_PGM_ATTRIBUTE4_O in VARCHAR2
,P_PGM_ATTRIBUTE5_O in VARCHAR2
,P_PGM_ATTRIBUTE6_O in VARCHAR2
,P_PGM_ATTRIBUTE7_O in VARCHAR2
,P_PGM_ATTRIBUTE8_O in VARCHAR2
,P_PGM_ATTRIBUTE9_O in VARCHAR2
,P_PGM_ATTRIBUTE10_O in VARCHAR2
,P_PGM_ATTRIBUTE11_O in VARCHAR2
,P_PGM_ATTRIBUTE12_O in VARCHAR2
,P_PGM_ATTRIBUTE13_O in VARCHAR2
,P_PGM_ATTRIBUTE14_O in VARCHAR2
,P_PGM_ATTRIBUTE15_O in VARCHAR2
,P_PGM_ATTRIBUTE16_O in VARCHAR2
,P_PGM_ATTRIBUTE17_O in VARCHAR2
,P_PGM_ATTRIBUTE18_O in VARCHAR2
,P_PGM_ATTRIBUTE19_O in VARCHAR2
,P_PGM_ATTRIBUTE20_O in VARCHAR2
,P_PGM_ATTRIBUTE21_O in VARCHAR2
,P_PGM_ATTRIBUTE22_O in VARCHAR2
,P_PGM_ATTRIBUTE23_O in VARCHAR2
,P_PGM_ATTRIBUTE24_O in VARCHAR2
,P_PGM_ATTRIBUTE25_O in VARCHAR2
,P_PGM_ATTRIBUTE26_O in VARCHAR2
,P_PGM_ATTRIBUTE27_O in VARCHAR2
,P_PGM_ATTRIBUTE28_O in VARCHAR2
,P_PGM_ATTRIBUTE29_O in VARCHAR2
,P_PGM_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_pgm_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_pgm_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_pgm_RKD;

/