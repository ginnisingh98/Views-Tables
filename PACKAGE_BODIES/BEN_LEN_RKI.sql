--------------------------------------------------------
--  DDL for Package Body BEN_LEN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LEN_RKI" as
/* $Header: belenrhi.pkb 120.1.12000000.2 2007/05/13 22:46:27 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:18 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_LEE_RSN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_POPL_ENRT_TYP_CYCL_ID in NUMBER
,P_LER_ID in NUMBER
,P_CLS_ENRT_DT_TO_USE_CD in VARCHAR2
,P_DYS_AFTR_END_TO_DFLT_NUM in NUMBER
,P_ENRT_CVG_END_DT_CD in VARCHAR2
,P_ENRT_CVG_STRT_DT_CD in VARCHAR2
,P_ENRT_PERD_STRT_DT_CD in VARCHAR2
,P_ENRT_PERD_STRT_DT_RL in NUMBER
,P_ENRT_PERD_END_DT_CD in VARCHAR2
,P_ENRT_PERD_END_DT_RL in NUMBER
,P_ADDL_PROCG_DYS_NUM in NUMBER
,P_DYS_NO_ENRL_NOT_ELIG_NUM in NUMBER
,P_DYS_NO_ENRL_CANT_ENRL_NUM in NUMBER
,P_RT_END_DT_CD in VARCHAR2
,P_RT_END_DT_RL in NUMBER
,P_RT_STRT_DT_CD in VARCHAR2
,P_RT_STRT_DT_RL in NUMBER
,P_ENRT_CVG_END_DT_RL in NUMBER
,P_ENRT_CVG_STRT_DT_RL in NUMBER
,P_LEN_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LEN_ATTRIBUTE1 in VARCHAR2
,P_LEN_ATTRIBUTE2 in VARCHAR2
,P_LEN_ATTRIBUTE3 in VARCHAR2
,P_LEN_ATTRIBUTE4 in VARCHAR2
,P_LEN_ATTRIBUTE5 in VARCHAR2
,P_LEN_ATTRIBUTE6 in VARCHAR2
,P_LEN_ATTRIBUTE7 in VARCHAR2
,P_LEN_ATTRIBUTE8 in VARCHAR2
,P_LEN_ATTRIBUTE9 in VARCHAR2
,P_LEN_ATTRIBUTE10 in VARCHAR2
,P_LEN_ATTRIBUTE11 in VARCHAR2
,P_LEN_ATTRIBUTE12 in VARCHAR2
,P_LEN_ATTRIBUTE13 in VARCHAR2
,P_LEN_ATTRIBUTE14 in VARCHAR2
,P_LEN_ATTRIBUTE15 in VARCHAR2
,P_LEN_ATTRIBUTE16 in VARCHAR2
,P_LEN_ATTRIBUTE17 in VARCHAR2
,P_LEN_ATTRIBUTE18 in VARCHAR2
,P_LEN_ATTRIBUTE19 in VARCHAR2
,P_LEN_ATTRIBUTE20 in VARCHAR2
,P_LEN_ATTRIBUTE21 in VARCHAR2
,P_LEN_ATTRIBUTE22 in VARCHAR2
,P_LEN_ATTRIBUTE23 in VARCHAR2
,P_LEN_ATTRIBUTE24 in VARCHAR2
,P_LEN_ATTRIBUTE25 in VARCHAR2
,P_LEN_ATTRIBUTE26 in VARCHAR2
,P_LEN_ATTRIBUTE27 in VARCHAR2
,P_LEN_ATTRIBUTE28 in VARCHAR2
,P_LEN_ATTRIBUTE29 in VARCHAR2
,P_LEN_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_ENRT_PERD_DET_OVRLP_BCKDT_CD in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
,P_REINSTATE_CD in VARCHAR2
,P_REINSTATE_OVRDN_CD in VARCHAR2
,P_ENRT_PERD_STRT_DAYS in NUMBER
,P_ENRT_PERD_END_DAYS in NUMBER
,P_DEFER_DEENROL_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_len_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_len_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_len_RKI;

/