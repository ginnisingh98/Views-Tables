--------------------------------------------------------
--  DDL for Package Body BEN_PLN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_RKD" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PL_ID in NUMBER
,P_DATETRACK_MODE in VARCHAR2
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_EFFECTIVE_START_DATE_O in DATE
,P_EFFECTIVE_END_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_ALWS_QDRO_FLAG_O in VARCHAR2
,P_ALWS_QMCSO_FLAG_O in VARCHAR2
,P_ALWS_REIMBMTS_FLAG_O in VARCHAR2
,P_BNF_ADDL_INSTN_TXT_ALWD_FL_O in VARCHAR2
,P_BNF_ADRS_RQD_FLAG_O in VARCHAR2
,P_BNF_CNTNGT_BNFS_ALWD_FLAG_O in VARCHAR2
,P_BNF_CTFN_RQD_FLAG_O in VARCHAR2
,P_BNF_DOB_RQD_FLAG_O in VARCHAR2
,P_BNF_DSGE_MNR_TTEE_RQD_FLAG_O in VARCHAR2
,P_BNF_INCRMT_AMT_O in NUMBER
,P_BNF_DFLT_BNF_CD_O in VARCHAR2
,P_BNF_LEGV_ID_RQD_FLAG_O in VARCHAR2
,P_BNF_MAY_DSGT_ORG_FLAG_O in VARCHAR2
,P_BNF_MN_DSGNTBL_AMT_O in NUMBER
,P_BNF_MN_DSGNTBL_PCT_VAL_O in NUMBER
,P_RQD_PERD_ENRT_NENRT_VAL_O in NUMBER
,P_ORDR_NUM_O in NUMBER
,P_BNF_PCT_INCRMT_VAL_O in NUMBER
,P_BNF_PCT_AMT_ALWD_CD_O in VARCHAR2
,P_BNF_QDRO_RL_APLS_FLAG_O in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_CD_O in VARCHAR2
,P_DFLT_TO_ASN_PNDG_CTFN_RL_O in NUMBER
,P_DRVBL_FCTR_APLS_RTS_FLAG_O in VARCHAR2
,P_DRVBL_FCTR_PRTN_ELIG_FLAG_O in VARCHAR2
,P_DPNT_DSGN_CD_O in VARCHAR2
,P_ELIG_APLS_FLAG_O in VARCHAR2
,P_INVK_DCLN_PRTN_PL_FLAG_O in VARCHAR2
,P_INVK_FLX_CR_PL_FLAG_O in VARCHAR2
,P_IMPTD_INCM_CALC_CD_O in VARCHAR2
,P_DRVBL_DPNT_ELIG_FLAG_O in VARCHAR2
,P_TRK_INELIG_PER_FLAG_O in VARCHAR2
,P_PL_CD_O in VARCHAR2
,P_AUTO_ENRT_MTHD_RL_O in NUMBER
,P_IVR_IDENT_O in VARCHAR2
,P_URL_REF_NAME_O in VARCHAR2
,P_CMPR_CLMS_TO_CVG_OR_BAL_CD_O in VARCHAR2
,P_COBRA_PYMT_DUE_DY_NUM_O in NUMBER
,P_DPNT_CVD_BY_OTHR_APLS_FLAG_O in VARCHAR2
,P_ENRT_MTHD_CD_O in VARCHAR2
,P_ENRT_CD_O in VARCHAR2
,P_ENRT_CVG_STRT_DT_CD_O in VARCHAR2
,P_ENRT_CVG_END_DT_CD_O in VARCHAR2
,P_FRFS_APLY_FLAG_O in VARCHAR2
,P_HC_PL_SUBJ_HCFA_APRVL_FLAG_O in VARCHAR2
,P_HGHLY_CMPD_RL_APLS_FLAG_O in VARCHAR2
,P_INCPTN_DT_O in DATE
,P_MN_CVG_RL_O in NUMBER
,P_MN_CVG_RQD_AMT_O in NUMBER
,P_MN_OPTS_RQD_NUM_O in NUMBER
,P_MX_CVG_ALWD_AMT_O in NUMBER
,P_MX_CVG_RL_O in NUMBER
,P_MX_OPTS_ALWD_NUM_O in NUMBER
,P_MX_CVG_WCFN_MLT_NUM_O in NUMBER
,P_MX_CVG_WCFN_AMT_O in NUMBER
,P_MX_CVG_INCR_ALWD_AMT_O in NUMBER
,P_MX_CVG_INCR_WCF_ALWD_AMT_O in NUMBER
,P_MX_CVG_MLT_INCR_NUM_O in NUMBER
,P_MX_CVG_MLT_INCR_WCF_NUM_O in NUMBER
,P_MX_WTG_DT_TO_USE_CD_O in VARCHAR2
,P_MX_WTG_DT_TO_USE_RL_O in NUMBER
,P_MX_WTG_PERD_PRTE_UOM_O in VARCHAR2
,P_MX_WTG_PERD_PRTE_VAL_O in NUMBER
,P_MX_WTG_PERD_RL_O in NUMBER
,P_NIP_DFLT_ENRT_CD_O in VARCHAR2
,P_NIP_DFLT_ENRT_DET_RL_O in NUMBER
,P_DPNT_ADRS_RQD_FLAG_O in VARCHAR2
,P_DPNT_CVG_END_DT_CD_O in VARCHAR2
,P_DPNT_CVG_END_DT_RL_O in NUMBER
,P_DPNT_CVG_STRT_DT_CD_O in VARCHAR2
,P_DPNT_CVG_STRT_DT_RL_O in NUMBER
,P_DPNT_DOB_RQD_FLAG_O in VARCHAR2
,P_DPNT_LEG_ID_RQD_FLAG_O in VARCHAR2
,P_DPNT_NO_CTFN_RQD_FLAG_O in VARCHAR2
,P_NO_MN_CVG_AMT_APLS_FLAG_O in VARCHAR2
,P_NO_MN_CVG_INCR_APLS_FLAG_O in VARCHAR2
,P_NO_MN_OPTS_NUM_APLS_FLAG_O in VARCHAR2
,P_NO_MX_CVG_AMT_APLS_FLAG_O in VARCHAR2
,P_NO_MX_CVG_INCR_APLS_FLAG_O in VARCHAR2
,P_NO_MX_OPTS_NUM_APLS_FLAG_O in VARCHAR2
,P_NIP_PL_UOM_O in VARCHAR2
,P_RQD_PERD_ENRT_NENRT_UOM_O in VARCHAR2
,P_NIP_ACTY_REF_PERD_CD_O in VARCHAR2
,P_NIP_ENRT_INFO_RT_FREQ_CD_O in VARCHAR2
,P_PER_CVRD_CD_O in VARCHAR2
,P_ENRT_CVG_END_DT_RL_O in NUMBER
,P_POSTELCN_EDIT_RL_O in NUMBER
,P_ENRT_CVG_STRT_DT_RL_O in NUMBER
,P_PRORT_PRTL_YR_CVG_RSTRN_CD_O in VARCHAR2
,P_PRORT_PRTL_YR_CVG_RSTRN_RL_O in NUMBER
,P_PRTN_ELIG_OVRID_ALWD_FLAG_O in VARCHAR2
,P_SVGS_PL_FLAG_O in VARCHAR2
,P_SUBJ_TO_IMPTD_INCM_TYP_CD_O in VARCHAR2
,P_USE_ALL_ASNTS_ELIG_FLAG_O in VARCHAR2
,P_USE_ALL_ASNTS_FOR_RT_FLAG_O in VARCHAR2
,P_VSTG_APLS_FLAG_O in VARCHAR2
,P_WVBL_FLAG_O in VARCHAR2
,P_HC_SVC_TYP_CD_O in VARCHAR2
,P_PL_STAT_CD_O in VARCHAR2
,P_PRMRY_FNDG_MTHD_CD_O in VARCHAR2
,P_RT_END_DT_CD_O in VARCHAR2
,P_RT_END_DT_RL_O in NUMBER
,P_RT_STRT_DT_RL_O in NUMBER
,P_RT_STRT_DT_CD_O in VARCHAR2
,P_BNF_DSGN_CD_O in VARCHAR2
,P_PL_TYP_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_ENRT_PL_OPT_FLAG_O in VARCHAR2
,P_BNFT_PRVDR_POOL_ID_O in NUMBER
,P_MAY_ENRL_PL_N_OIPL_FLAG_O in VARCHAR2
,P_ENRT_RL_O in NUMBER
,P_RQD_PERD_ENRT_NENRT_RL_O in NUMBER
,P_ALWS_UNRSTRCTD_ENRT_FLAG_O in VARCHAR2
,P_BNFT_OR_OPTION_RSTRCTN_CD_O in VARCHAR2
,P_CVG_INCR_R_DECR_ONLY_CD_O in VARCHAR2
,P_UNSSPND_ENRT_CD_O in VARCHAR2
,P_PLN_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_PLN_ATTRIBUTE1_O in VARCHAR2
,P_PLN_ATTRIBUTE2_O in VARCHAR2
,P_PLN_ATTRIBUTE3_O in VARCHAR2
,P_PLN_ATTRIBUTE4_O in VARCHAR2
,P_PLN_ATTRIBUTE5_O in VARCHAR2
,P_PLN_ATTRIBUTE6_O in VARCHAR2
,P_PLN_ATTRIBUTE7_O in VARCHAR2
,P_PLN_ATTRIBUTE8_O in VARCHAR2
,P_PLN_ATTRIBUTE9_O in VARCHAR2
,P_PLN_ATTRIBUTE10_O in VARCHAR2
,P_PLN_ATTRIBUTE11_O in VARCHAR2
,P_PLN_ATTRIBUTE12_O in VARCHAR2
,P_PLN_ATTRIBUTE13_O in VARCHAR2
,P_PLN_ATTRIBUTE14_O in VARCHAR2
,P_PLN_ATTRIBUTE15_O in VARCHAR2
,P_PLN_ATTRIBUTE16_O in VARCHAR2
,P_PLN_ATTRIBUTE17_O in VARCHAR2
,P_PLN_ATTRIBUTE18_O in VARCHAR2
,P_PLN_ATTRIBUTE19_O in VARCHAR2
,P_PLN_ATTRIBUTE20_O in VARCHAR2
,P_PLN_ATTRIBUTE21_O in VARCHAR2
,P_PLN_ATTRIBUTE22_O in VARCHAR2
,P_PLN_ATTRIBUTE23_O in VARCHAR2
,P_PLN_ATTRIBUTE24_O in VARCHAR2
,P_PLN_ATTRIBUTE25_O in VARCHAR2
,P_PLN_ATTRIBUTE26_O in VARCHAR2
,P_PLN_ATTRIBUTE27_O in VARCHAR2
,P_PLN_ATTRIBUTE28_O in VARCHAR2
,P_PLN_ATTRIBUTE29_O in VARCHAR2
,P_PLN_ATTRIBUTE30_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG_O in VARCHAR2
,P_CTFN_DETERMINE_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_SSN_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_DOB_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_DPNT_ADR_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_DPNT_FLAG_O in VARCHAR2
,P_SUSP_IF_BNF_SSN_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_BNF_DOB_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_BNF_ADR_NT_PRV_CD_O in VARCHAR2
,P_SUSP_IF_CTFN_NOT_BNF_FLAG_O in VARCHAR2
,P_DPNT_CTFN_DETERMINE_CD_O in VARCHAR2
,P_BNF_CTFN_DETERMINE_CD_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_ACTL_PREM_ID_O in NUMBER
,P_VRFY_FMLY_MMBR_CD_O in VARCHAR2
,P_VRFY_FMLY_MMBR_RL_O in NUMBER
,P_ALWS_TMPRY_ID_CRD_FLAG_O in VARCHAR2
,P_NIP_DFLT_FLAG_O in VARCHAR2
,P_FRFS_DISTR_MTHD_CD_O in VARCHAR2
,P_FRFS_DISTR_MTHD_RL_O in NUMBER
,P_FRFS_CNTR_DET_CD_O in VARCHAR2
,P_FRFS_DISTR_DET_CD_O in VARCHAR2
,P_COST_ALLOC_KEYFLEX_1_ID_O in NUMBER
,P_COST_ALLOC_KEYFLEX_2_ID_O in NUMBER
,P_POST_TO_GL_FLAG_O in VARCHAR2
,P_FRFS_VAL_DET_CD_O in VARCHAR2
,P_FRFS_MX_CRYFWD_VAL_O in NUMBER
,P_FRFS_PORTION_DET_CD_O in VARCHAR2
,P_BNDRY_PERD_CD_O in VARCHAR2
,P_SHORT_NAME_O in VARCHAR2
,P_SHORT_CODE_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_LEGISLATION_SUBGROUP_O in VARCHAR2
,P_GROUP_PL_ID_O in NUMBER
,P_MAPPING_TABLE_NAME_O in VARCHAR2
,P_MAPPING_TABLE_PK_ID_O in NUMBER
,P_FUNCTION_CODE_O in VARCHAR2
,P_PL_YR_NOT_APPLCBL_FLAG_O in VARCHAR2
,P_USE_CSD_RSD_PRCCNG_CD_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_pln_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_pln_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_pln_RKD;

/
