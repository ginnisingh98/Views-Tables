--------------------------------------------------------
--  DDL for Package Body BEN_CPD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPD_RKU" as
/* $Header: becpdrhi.pkb 120.1.12010000.3 2010/03/12 06:12:31 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:33 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PL_ID in NUMBER
,P_LF_EVT_OCRD_DT in DATE
,P_OIPL_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_NAME in VARCHAR2
,P_GROUP_PL_ID in NUMBER
,P_GROUP_OIPL_ID in NUMBER
,P_OPT_HIDDEN_FLAG in VARCHAR2
,P_OPT_ID in NUMBER
,P_PL_UOM in VARCHAR2
,P_PL_ORDR_NUM in NUMBER
,P_OIPL_ORDR_NUM in NUMBER
,P_PL_XCHG_RATE in NUMBER
,P_OPT_COUNT in NUMBER
,P_USES_BDGT_FLAG in VARCHAR2
,P_PRSRV_BDGT_CD in VARCHAR2
,P_UPD_START_DT in DATE
,P_UPD_END_DT in DATE
,P_APPROVAL_MODE in VARCHAR2
,P_ENRT_PERD_START_DT in DATE
,P_ENRT_PERD_END_DT in DATE
,P_YR_PERD_START_DT in DATE
,P_YR_PERD_END_DT in DATE
,P_WTHN_YR_START_DT in DATE
,P_WTHN_YR_END_DT in DATE
,P_ENRT_PERD_ID in NUMBER
,P_YR_PERD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PERF_REVW_STRT_DT in DATE
,P_ASG_UPDT_EFF_DATE in DATE
,P_EMP_INTERVIEW_TYP_CD in VARCHAR2
,P_SALARY_CHANGE_REASON in VARCHAR2
,P_WS_ABR_ID in NUMBER
,P_WS_NNMNTRY_UOM in VARCHAR2
,P_WS_RNDG_CD in VARCHAR2
,P_WS_SUB_ACTY_TYP_CD in VARCHAR2
,P_DIST_BDGT_ABR_ID in NUMBER
,P_DIST_BDGT_NNMNTRY_UOM in VARCHAR2
,P_DIST_BDGT_RNDG_CD in VARCHAR2
,P_WS_BDGT_ABR_ID in NUMBER
,P_WS_BDGT_NNMNTRY_UOM in VARCHAR2
,P_WS_BDGT_RNDG_CD in VARCHAR2
,P_RSRV_ABR_ID in NUMBER
,P_RSRV_NNMNTRY_UOM in VARCHAR2
,P_RSRV_RNDG_CD in VARCHAR2
,P_ELIG_SAL_ABR_ID in NUMBER
,P_ELIG_SAL_NNMNTRY_UOM in VARCHAR2
,P_ELIG_SAL_RNDG_CD in VARCHAR2
,P_MISC1_ABR_ID in NUMBER
,P_MISC1_NNMNTRY_UOM in VARCHAR2
,P_MISC1_RNDG_CD in VARCHAR2
,P_MISC2_ABR_ID in NUMBER
,P_MISC2_NNMNTRY_UOM in VARCHAR2
,P_MISC2_RNDG_CD in VARCHAR2
,P_MISC3_ABR_ID in NUMBER
,P_MISC3_NNMNTRY_UOM in VARCHAR2
,P_MISC3_RNDG_CD in VARCHAR2
,P_STAT_SAL_ABR_ID in NUMBER
,P_STAT_SAL_NNMNTRY_UOM in VARCHAR2
,P_STAT_SAL_RNDG_CD in VARCHAR2
,P_REC_ABR_ID in NUMBER
,P_REC_NNMNTRY_UOM in VARCHAR2
,P_REC_RNDG_CD in VARCHAR2
,P_TOT_COMP_ABR_ID in NUMBER
,P_TOT_COMP_NNMNTRY_UOM in VARCHAR2
,P_TOT_COMP_RNDG_CD in VARCHAR2
,P_OTH_COMP_ABR_ID in NUMBER
,P_OTH_COMP_NNMNTRY_UOM in VARCHAR2
,P_OTH_COMP_RNDG_CD in VARCHAR2
,P_ACTUAL_FLAG in VARCHAR2
,P_ACTY_REF_PERD_CD in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_PL_ANNULIZATION_FACTOR in NUMBER
,P_PL_STAT_CD in VARCHAR2
,P_UOM_PRECISION in NUMBER
,P_WS_ELEMENT_TYPE_ID in NUMBER
,P_WS_INPUT_VALUE_ID in NUMBER
,P_DATA_FREEZE_DATE in DATE
,P_WS_AMT_EDIT_CD in VARCHAR2
,P_WS_AMT_EDIT_ENF_CD_FOR_NUL in VARCHAR2
,P_WS_OVER_BUDGET_EDIT_CD in VARCHAR2
,P_WS_OVER_BUDGET_TOL_PCT in NUMBER
,P_BDGT_OVER_BUDGET_EDIT_CD in VARCHAR2
,P_BDGT_OVER_BUDGET_TOL_PCT in NUMBER
,P_AUTO_DISTR_FLAG in VARCHAR2
,P_PQH_DOCUMENT_SHORT_NAME in VARCHAR2
,P_OVRID_RT_STRT_DT in DATE
,P_DO_NOT_PROCESS_FLAG in VARCHAR2
,P_OVR_PERF_REVW_STRT_DT in DATE
,P_POST_ZERO_SALARY_INCREASE in VARCHAR2
,P_SHOW_APPRAISALS_N_DAYS in NUMBER
,P_GRADE_RANGE_VALIDATION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE_O in DATE
,P_NAME_O in VARCHAR2
,P_GROUP_PL_ID_O in NUMBER
,P_GROUP_OIPL_ID_O in NUMBER
,P_OPT_HIDDEN_FLAG_O in VARCHAR2
,P_OPT_ID_O in NUMBER
,P_PL_UOM_O in VARCHAR2
,P_PL_ORDR_NUM_O in NUMBER
,P_OIPL_ORDR_NUM_O in NUMBER
,P_PL_XCHG_RATE_O in NUMBER
,P_OPT_COUNT_O in NUMBER
,P_USES_BDGT_FLAG_O in VARCHAR2
,P_PRSRV_BDGT_CD_O in VARCHAR2
,P_UPD_START_DT_O in DATE
,P_UPD_END_DT_O in DATE
,P_APPROVAL_MODE_O in VARCHAR2
,P_ENRT_PERD_START_DT_O in DATE
,P_ENRT_PERD_END_DT_O in DATE
,P_YR_PERD_START_DT_O in DATE
,P_YR_PERD_END_DT_O in DATE
,P_WTHN_YR_START_DT_O in DATE
,P_WTHN_YR_END_DT_O in DATE
,P_ENRT_PERD_ID_O in NUMBER
,P_YR_PERD_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_PERF_REVW_STRT_DT_O in DATE
,P_ASG_UPDT_EFF_DATE_O in DATE
,P_EMP_INTERVIEW_TYP_CD_O in VARCHAR2
,P_SALARY_CHANGE_REASON_O in VARCHAR2
,P_WS_ABR_ID_O in NUMBER
,P_WS_NNMNTRY_UOM_O in VARCHAR2
,P_WS_RNDG_CD_O in VARCHAR2
,P_WS_SUB_ACTY_TYP_CD_O in VARCHAR2
,P_DIST_BDGT_ABR_ID_O in NUMBER
,P_DIST_BDGT_NNMNTRY_UOM_O in VARCHAR2
,P_DIST_BDGT_RNDG_CD_O in VARCHAR2
,P_WS_BDGT_ABR_ID_O in NUMBER
,P_WS_BDGT_NNMNTRY_UOM_O in VARCHAR2
,P_WS_BDGT_RNDG_CD_O in VARCHAR2
,P_RSRV_ABR_ID_O in NUMBER
,P_RSRV_NNMNTRY_UOM_O in VARCHAR2
,P_RSRV_RNDG_CD_O in VARCHAR2
,P_ELIG_SAL_ABR_ID_O in NUMBER
,P_ELIG_SAL_NNMNTRY_UOM_O in VARCHAR2
,P_ELIG_SAL_RNDG_CD_O in VARCHAR2
,P_MISC1_ABR_ID_O in NUMBER
,P_MISC1_NNMNTRY_UOM_O in VARCHAR2
,P_MISC1_RNDG_CD_O in VARCHAR2
,P_MISC2_ABR_ID_O in NUMBER
,P_MISC2_NNMNTRY_UOM_O in VARCHAR2
,P_MISC2_RNDG_CD_O in VARCHAR2
,P_MISC3_ABR_ID_O in NUMBER
,P_MISC3_NNMNTRY_UOM_O in VARCHAR2
,P_MISC3_RNDG_CD_O in VARCHAR2
,P_STAT_SAL_ABR_ID_O in NUMBER
,P_STAT_SAL_NNMNTRY_UOM_O in VARCHAR2
,P_STAT_SAL_RNDG_CD_O in VARCHAR2
,P_REC_ABR_ID_O in NUMBER
,P_REC_NNMNTRY_UOM_O in VARCHAR2
,P_REC_RNDG_CD_O in VARCHAR2
,P_TOT_COMP_ABR_ID_O in NUMBER
,P_TOT_COMP_NNMNTRY_UOM_O in VARCHAR2
,P_TOT_COMP_RNDG_CD_O in VARCHAR2
,P_OTH_COMP_ABR_ID_O in NUMBER
,P_OTH_COMP_NNMNTRY_UOM_O in VARCHAR2
,P_OTH_COMP_RNDG_CD_O in VARCHAR2
,P_ACTUAL_FLAG_O in VARCHAR2
,P_ACTY_REF_PERD_CD_O in VARCHAR2
,P_LEGISLATION_CODE_O in VARCHAR2
,P_PL_ANNULIZATION_FACTOR_O in NUMBER
,P_PL_STAT_CD_O in VARCHAR2
,P_UOM_PRECISION_O in NUMBER
,P_WS_ELEMENT_TYPE_ID_O in NUMBER
,P_WS_INPUT_VALUE_ID_O in NUMBER
,P_DATA_FREEZE_DATE_O in DATE
,P_WS_AMT_EDIT_CD_O in VARCHAR2
,P_WS_AMT_EDIT_ENF_CD_FOR_NUL_O in VARCHAR2
,P_WS_OVER_BUDGET_EDIT_CD_O in VARCHAR2
,P_WS_OVER_BUDGET_TOL_PCT_O in NUMBER
,P_BDGT_OVER_BUDGET_EDIT_CD_O in VARCHAR2
,P_BDGT_OVER_BUDGET_TOL_PCT_O in NUMBER
,P_AUTO_DISTR_FLAG_O in VARCHAR2
,P_PQH_DOCUMENT_SHORT_NAME_O in VARCHAR2
,P_OVRID_RT_STRT_DT_O in DATE
,P_DO_NOT_PROCESS_FLAG_O in VARCHAR2
,P_OVR_PERF_REVW_STRT_DT_O in DATE
,P_POST_ZERO_SALARY_INCREASE_O in VARCHAR2
,P_SHOW_APPRAISALS_N_DAYS_O in NUMBER
,P_GRADE_RANGE_VALIDATION_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_CPD_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_CPD_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_CPD_RKU;

/
