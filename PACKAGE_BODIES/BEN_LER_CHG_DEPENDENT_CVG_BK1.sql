--------------------------------------------------------
--  DDL for Package Body BEN_LER_CHG_DEPENDENT_CVG_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_CHG_DEPENDENT_CVG_BK1" as
/* $Header: beldcapi.pkb 120.0 2005/05/28 03:19:20 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:41 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_LER_CHG_DEPENDENT_CVG_A
(P_LER_CHG_DPNT_CVG_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_PL_ID in NUMBER
,P_PGM_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LER_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_ADD_RMV_CVG_CD in VARCHAR2
,P_CVG_EFF_END_CD in VARCHAR2
,P_CVG_EFF_STRT_CD in VARCHAR2
,P_LER_CHG_DPNT_CVG_RL in NUMBER
,P_LER_CHG_DPNT_CVG_CD in VARCHAR2
,P_CVG_EFF_STRT_RL in NUMBER
,P_CVG_EFF_END_RL in NUMBER
,P_LDC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LDC_ATTRIBUTE1 in VARCHAR2
,P_LDC_ATTRIBUTE2 in VARCHAR2
,P_LDC_ATTRIBUTE3 in VARCHAR2
,P_LDC_ATTRIBUTE4 in VARCHAR2
,P_LDC_ATTRIBUTE5 in VARCHAR2
,P_LDC_ATTRIBUTE6 in VARCHAR2
,P_LDC_ATTRIBUTE7 in VARCHAR2
,P_LDC_ATTRIBUTE8 in VARCHAR2
,P_LDC_ATTRIBUTE9 in VARCHAR2
,P_LDC_ATTRIBUTE10 in VARCHAR2
,P_LDC_ATTRIBUTE11 in VARCHAR2
,P_LDC_ATTRIBUTE12 in VARCHAR2
,P_LDC_ATTRIBUTE13 in VARCHAR2
,P_LDC_ATTRIBUTE14 in VARCHAR2
,P_LDC_ATTRIBUTE15 in VARCHAR2
,P_LDC_ATTRIBUTE16 in VARCHAR2
,P_LDC_ATTRIBUTE17 in VARCHAR2
,P_LDC_ATTRIBUTE18 in VARCHAR2
,P_LDC_ATTRIBUTE19 in VARCHAR2
,P_LDC_ATTRIBUTE20 in VARCHAR2
,P_LDC_ATTRIBUTE21 in VARCHAR2
,P_LDC_ATTRIBUTE22 in VARCHAR2
,P_LDC_ATTRIBUTE23 in VARCHAR2
,P_LDC_ATTRIBUTE24 in VARCHAR2
,P_LDC_ATTRIBUTE25 in VARCHAR2
,P_LDC_ATTRIBUTE26 in VARCHAR2
,P_LDC_ATTRIBUTE27 in VARCHAR2
,P_LDC_ATTRIBUTE28 in VARCHAR2
,P_LDC_ATTRIBUTE29 in VARCHAR2
,P_LDC_ATTRIBUTE30 in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG in VARCHAR2
,P_CTFN_DETERMINE_CD in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_LER_CHG_DEPENDENT_CVG_BK1.CREATE_LER_CHG_DEPENDENT_CVG_A', 10);
hr_utility.set_location(' Leaving: BEN_LER_CHG_DEPENDENT_CVG_BK1.CREATE_LER_CHG_DEPENDENT_CVG_A', 20);
end CREATE_LER_CHG_DEPENDENT_CVG_A;
procedure CREATE_LER_CHG_DEPENDENT_CVG_B
(P_PL_ID in NUMBER
,P_PGM_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LER_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_ADD_RMV_CVG_CD in VARCHAR2
,P_CVG_EFF_END_CD in VARCHAR2
,P_CVG_EFF_STRT_CD in VARCHAR2
,P_LER_CHG_DPNT_CVG_RL in NUMBER
,P_LER_CHG_DPNT_CVG_CD in VARCHAR2
,P_CVG_EFF_STRT_RL in NUMBER
,P_CVG_EFF_END_RL in NUMBER
,P_LDC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_LDC_ATTRIBUTE1 in VARCHAR2
,P_LDC_ATTRIBUTE2 in VARCHAR2
,P_LDC_ATTRIBUTE3 in VARCHAR2
,P_LDC_ATTRIBUTE4 in VARCHAR2
,P_LDC_ATTRIBUTE5 in VARCHAR2
,P_LDC_ATTRIBUTE6 in VARCHAR2
,P_LDC_ATTRIBUTE7 in VARCHAR2
,P_LDC_ATTRIBUTE8 in VARCHAR2
,P_LDC_ATTRIBUTE9 in VARCHAR2
,P_LDC_ATTRIBUTE10 in VARCHAR2
,P_LDC_ATTRIBUTE11 in VARCHAR2
,P_LDC_ATTRIBUTE12 in VARCHAR2
,P_LDC_ATTRIBUTE13 in VARCHAR2
,P_LDC_ATTRIBUTE14 in VARCHAR2
,P_LDC_ATTRIBUTE15 in VARCHAR2
,P_LDC_ATTRIBUTE16 in VARCHAR2
,P_LDC_ATTRIBUTE17 in VARCHAR2
,P_LDC_ATTRIBUTE18 in VARCHAR2
,P_LDC_ATTRIBUTE19 in VARCHAR2
,P_LDC_ATTRIBUTE20 in VARCHAR2
,P_LDC_ATTRIBUTE21 in VARCHAR2
,P_LDC_ATTRIBUTE22 in VARCHAR2
,P_LDC_ATTRIBUTE23 in VARCHAR2
,P_LDC_ATTRIBUTE24 in VARCHAR2
,P_LDC_ATTRIBUTE25 in VARCHAR2
,P_LDC_ATTRIBUTE26 in VARCHAR2
,P_LDC_ATTRIBUTE27 in VARCHAR2
,P_LDC_ATTRIBUTE28 in VARCHAR2
,P_LDC_ATTRIBUTE29 in VARCHAR2
,P_LDC_ATTRIBUTE30 in VARCHAR2
,P_SUSP_IF_CTFN_NOT_PRVD_FLAG in VARCHAR2
,P_CTFN_DETERMINE_CD in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_LER_CHG_DEPENDENT_CVG_BK1.CREATE_LER_CHG_DEPENDENT_CVG_B', 10);
hr_utility.set_location(' Leaving: BEN_LER_CHG_DEPENDENT_CVG_BK1.CREATE_LER_CHG_DEPENDENT_CVG_B', 20);
end CREATE_LER_CHG_DEPENDENT_CVG_B;
end BEN_LER_CHG_DEPENDENT_CVG_BK1;

/
