--------------------------------------------------------
--  DDL for Package Body BEN_CTP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTP_RKD" as
/* $Header: bectprhi.pkb 120.0 2005/05/28 01:26:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:23 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PTIP_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_COORD_CVG_FOR_ALL_PLS_FLAG_O in VARCHAR2
,P_DPNT_DSGN_CD_O in VARCHAR2
,P_DPNT_CVG_NO_CTFN_RQD_FLAG_O in VARCHAR2
,P_DPNT_CVG_STRT_DT_CD_O in VARCHAR2
,P_RT_END_DT_CD_O in VARCHAR2
,P_RT_STRT_DT_CD_O in VARCHAR2
,P_ENRT_CVG_END_DT_CD_O in VARCHAR2
,P_ENRT_CVG_STRT_DT_CD_O in VARCHAR2
,P_DPNT_CVG_STRT_DT_RL_O in NUMBER
,P_DPNT_CVG_END_DT_CD_O in VARCHAR2
,P_DPNT_CVG_END_DT_RL_O in NUMBER
,P_DPNT_ADRS_RQD_FLAG_O in VARCHAR2
,P_DPNT_LEGV_ID_RQD_FLAG_O in VARCHAR2
,P_SUSP_IF_DPNT_SSN_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_DOB_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_ADR_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_DPNT_FLAG_O in VARCHAR2
,P_DPNT_CTFN_DETERMINE_CD_O in VARCHAR2
,P_POSTELCN_EDIT_RL_O in NUMBER
,P_RT_END_DT_RL_O in NUMBER
,P_RT_STRT_DT_RL_O in NUMBER
,P_ENRT_CVG_END_DT_RL_O in NUMBER
,P_ENRT_CVG_STRT_DT_RL_O in NUMBER
,P_RQD_PERD_ENRT_NENRT_RL_O in NUMBER
,P_AUTO_ENRT_MTHD_RL_O in NUMBER
,P_ENRT_MTHD_CD_O in VARCHAR2
,P_ENRT_CD_O in VARCHAR2
,P_ENRT_RL_O in NUMBER
,P_DFLT_ENRT_CD_O in VARCHAR2
,P_DFLT_ENRT_DET_RL_O in NUMBER
,P_DRVBL_FCTR_APLS_RTS_FLAG_O in VARCHAR2
,P_DRVBL_FCTR_PRTN_ELIG_FLAG_O in VARCHAR2
,P_ELIG_APLS_FLAG_O in VARCHAR2
,P_PRTN_ELIG_OVRID_ALWD_FLAG_O in VARCHAR2
,P_TRK_INELIG_PER_FLAG_O in VARCHAR2
,P_DPNT_DOB_RQD_FLAG_O in VARCHAR2
,P_CRS_THIS_PL_TYP_ONLY_FLAG_O in VARCHAR2
,P_PTIP_STAT_CD_O in VARCHAR2
,P_MX_CVG_ALWD_AMT_O in NUMBER
,P_MX_ENRD_ALWD_OVRID_NUM_O in NUMBER
,P_MN_ENRD_RQD_OVRID_NUM_O in NUMBER
,P_NO_MX_PL_TYP_OVRID_FLAG_O in VARCHAR2
,P_ORDR_NUM_O in NUMBER
,P_PRVDS_CR_FLAG_O in VARCHAR2
,P_RQD_PERD_ENRT_NENRT_VAL_O in NUMBER
,P_RQD_PERD_ENRT_NENRT_TM_UOM_O in VARCHAR2
,P_WVBL_FLAG_O in VARCHAR2
,P_DRVD_FCTR_DPNT_CVG_FLAG_O in VARCHAR2
,P_NO_MN_PL_TYP_OVERID_FLAG_O in VARCHAR2
,P_SBJ_TO_SPS_LF_INS_MX_FLAG_O in VARCHAR2
,P_SBJ_TO_DPNT_LF_INS_MX_FLAG_O in VARCHAR2
,P_USE_TO_SUM_EE_LF_INS_FLAG_O in VARCHAR2
,P_PER_CVRD_CD_O in VARCHAR2
,P_SHORT_NAME_O in VARCHAR2
,P_SHORT_CODE_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_LEGISLATION_SUBGROUP_O in VARCHAR2
,P_VRFY_FMLY_MMBR_CD_O in VARCHAR2
,P_VRFY_FMLY_MMBR_RL_O in NUMBER
,P_IVR_IDENT_O in VARCHAR2
,P_URL_REF_NAME_O in VARCHAR2
,P_RQD_ENRT_PERD_TCO_CD_O in VARCHAR2
,P_PGM_ID_O in NUMBER
,P_PL_TYP_ID_O in NUMBER
,P_CMBN_PTIP_ID_O in NUMBER
,P_CMBN_PTIP_OPT_ID_O in NUMBER
,P_ACRS_PTIP_CVG_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CTP_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CTP_ATTRIBUTE1_O in VARCHAR2
,P_CTP_ATTRIBUTE2_O in VARCHAR2
,P_CTP_ATTRIBUTE3_O in VARCHAR2
,P_CTP_ATTRIBUTE4_O in VARCHAR2
,P_CTP_ATTRIBUTE5_O in VARCHAR2
,P_CTP_ATTRIBUTE6_O in VARCHAR2
,P_CTP_ATTRIBUTE7_O in VARCHAR2
,P_CTP_ATTRIBUTE8_O in VARCHAR2
,P_CTP_ATTRIBUTE9_O in VARCHAR2
,P_CTP_ATTRIBUTE10_O in VARCHAR2
,P_CTP_ATTRIBUTE11_O in VARCHAR2
,P_CTP_ATTRIBUTE12_O in VARCHAR2
,P_CTP_ATTRIBUTE13_O in VARCHAR2
,P_CTP_ATTRIBUTE14_O in VARCHAR2
,P_CTP_ATTRIBUTE15_O in VARCHAR2
,P_CTP_ATTRIBUTE16_O in VARCHAR2
,P_CTP_ATTRIBUTE17_O in VARCHAR2
,P_CTP_ATTRIBUTE18_O in VARCHAR2
,P_CTP_ATTRIBUTE19_O in VARCHAR2
,P_CTP_ATTRIBUTE20_O in VARCHAR2
,P_CTP_ATTRIBUTE21_O in VARCHAR2
,P_CTP_ATTRIBUTE22_O in VARCHAR2
,P_CTP_ATTRIBUTE23_O in VARCHAR2
,P_CTP_ATTRIBUTE24_O in VARCHAR2
,P_CTP_ATTRIBUTE25_O in VARCHAR2
,P_CTP_ATTRIBUTE26_O in VARCHAR2
,P_CTP_ATTRIBUTE27_O in VARCHAR2
,P_CTP_ATTRIBUTE28_O in VARCHAR2
,P_CTP_ATTRIBUTE29_O in VARCHAR2
,P_CTP_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ctp_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ctp_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ctp_RKD;

/
