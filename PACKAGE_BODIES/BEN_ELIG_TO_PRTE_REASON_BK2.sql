--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_TO_PRTE_REASON_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_TO_PRTE_REASON_BK2" as
/* $Header: bepeoapi.pkb 120.0 2005/05/28 10:37:39 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:18 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_ELIG_TO_PRTE_REASON_A
(P_ELIG_TO_PRTE_RSN_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_LER_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_PGM_ID in NUMBER
,P_PL_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_IGNR_PRTN_OVRID_FLAG in VARCHAR2
,P_ELIG_INELIG_CD in VARCHAR2
,P_PRTN_EFF_STRT_DT_CD in VARCHAR2
,P_PRTN_EFF_STRT_DT_RL in NUMBER
,P_PRTN_EFF_END_DT_CD in VARCHAR2
,P_PRTN_EFF_END_DT_RL in NUMBER
,P_WAIT_PERD_DT_TO_USE_CD in VARCHAR2
,P_WAIT_PERD_DT_TO_USE_RL in NUMBER
,P_WAIT_PERD_VAL in NUMBER
,P_WAIT_PERD_UOM in VARCHAR2
,P_WAIT_PERD_RL in NUMBER
,P_MX_POE_DET_DT_CD in VARCHAR2
,P_MX_POE_DET_DT_RL in NUMBER
,P_MX_POE_VAL in NUMBER
,P_MX_POE_UOM in VARCHAR2
,P_MX_POE_RL in NUMBER
,P_MX_POE_APLS_CD in VARCHAR2
,P_PRTN_OVRIDBL_FLAG in VARCHAR2
,P_VRFY_FMLY_MMBR_CD in VARCHAR2
,P_VRFY_FMLY_MMBR_RL in NUMBER
,P_PEO_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PEO_ATTRIBUTE1 in VARCHAR2
,P_PEO_ATTRIBUTE2 in VARCHAR2
,P_PEO_ATTRIBUTE3 in VARCHAR2
,P_PEO_ATTRIBUTE4 in VARCHAR2
,P_PEO_ATTRIBUTE5 in VARCHAR2
,P_PEO_ATTRIBUTE6 in VARCHAR2
,P_PEO_ATTRIBUTE7 in VARCHAR2
,P_PEO_ATTRIBUTE8 in VARCHAR2
,P_PEO_ATTRIBUTE9 in VARCHAR2
,P_PEO_ATTRIBUTE10 in VARCHAR2
,P_PEO_ATTRIBUTE11 in VARCHAR2
,P_PEO_ATTRIBUTE12 in VARCHAR2
,P_PEO_ATTRIBUTE13 in VARCHAR2
,P_PEO_ATTRIBUTE14 in VARCHAR2
,P_PEO_ATTRIBUTE15 in VARCHAR2
,P_PEO_ATTRIBUTE16 in VARCHAR2
,P_PEO_ATTRIBUTE17 in VARCHAR2
,P_PEO_ATTRIBUTE18 in VARCHAR2
,P_PEO_ATTRIBUTE19 in VARCHAR2
,P_PEO_ATTRIBUTE20 in VARCHAR2
,P_PEO_ATTRIBUTE21 in VARCHAR2
,P_PEO_ATTRIBUTE22 in VARCHAR2
,P_PEO_ATTRIBUTE23 in VARCHAR2
,P_PEO_ATTRIBUTE24 in VARCHAR2
,P_PEO_ATTRIBUTE25 in VARCHAR2
,P_PEO_ATTRIBUTE26 in VARCHAR2
,P_PEO_ATTRIBUTE27 in VARCHAR2
,P_PEO_ATTRIBUTE28 in VARCHAR2
,P_PEO_ATTRIBUTE29 in VARCHAR2
,P_PEO_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_TO_PRTE_REASON_BK2.UPDATE_ELIG_TO_PRTE_REASON_A', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_TO_PRTE_REASON_BK2.UPDATE_ELIG_TO_PRTE_REASON_A', 20);
end UPDATE_ELIG_TO_PRTE_REASON_A;
procedure UPDATE_ELIG_TO_PRTE_REASON_B
(P_ELIG_TO_PRTE_RSN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LER_ID in NUMBER
,P_OIPL_ID in NUMBER
,P_PGM_ID in NUMBER
,P_PL_ID in NUMBER
,P_PTIP_ID in NUMBER
,P_PLIP_ID in NUMBER
,P_IGNR_PRTN_OVRID_FLAG in VARCHAR2
,P_ELIG_INELIG_CD in VARCHAR2
,P_PRTN_EFF_STRT_DT_CD in VARCHAR2
,P_PRTN_EFF_STRT_DT_RL in NUMBER
,P_PRTN_EFF_END_DT_CD in VARCHAR2
,P_PRTN_EFF_END_DT_RL in NUMBER
,P_WAIT_PERD_DT_TO_USE_CD in VARCHAR2
,P_WAIT_PERD_DT_TO_USE_RL in NUMBER
,P_WAIT_PERD_VAL in NUMBER
,P_WAIT_PERD_UOM in VARCHAR2
,P_WAIT_PERD_RL in NUMBER
,P_MX_POE_DET_DT_CD in VARCHAR2
,P_MX_POE_DET_DT_RL in NUMBER
,P_MX_POE_VAL in NUMBER
,P_MX_POE_UOM in VARCHAR2
,P_MX_POE_RL in NUMBER
,P_MX_POE_APLS_CD in VARCHAR2
,P_PRTN_OVRIDBL_FLAG in VARCHAR2
,P_VRFY_FMLY_MMBR_CD in VARCHAR2
,P_VRFY_FMLY_MMBR_RL in NUMBER
,P_PEO_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PEO_ATTRIBUTE1 in VARCHAR2
,P_PEO_ATTRIBUTE2 in VARCHAR2
,P_PEO_ATTRIBUTE3 in VARCHAR2
,P_PEO_ATTRIBUTE4 in VARCHAR2
,P_PEO_ATTRIBUTE5 in VARCHAR2
,P_PEO_ATTRIBUTE6 in VARCHAR2
,P_PEO_ATTRIBUTE7 in VARCHAR2
,P_PEO_ATTRIBUTE8 in VARCHAR2
,P_PEO_ATTRIBUTE9 in VARCHAR2
,P_PEO_ATTRIBUTE10 in VARCHAR2
,P_PEO_ATTRIBUTE11 in VARCHAR2
,P_PEO_ATTRIBUTE12 in VARCHAR2
,P_PEO_ATTRIBUTE13 in VARCHAR2
,P_PEO_ATTRIBUTE14 in VARCHAR2
,P_PEO_ATTRIBUTE15 in VARCHAR2
,P_PEO_ATTRIBUTE16 in VARCHAR2
,P_PEO_ATTRIBUTE17 in VARCHAR2
,P_PEO_ATTRIBUTE18 in VARCHAR2
,P_PEO_ATTRIBUTE19 in VARCHAR2
,P_PEO_ATTRIBUTE20 in VARCHAR2
,P_PEO_ATTRIBUTE21 in VARCHAR2
,P_PEO_ATTRIBUTE22 in VARCHAR2
,P_PEO_ATTRIBUTE23 in VARCHAR2
,P_PEO_ATTRIBUTE24 in VARCHAR2
,P_PEO_ATTRIBUTE25 in VARCHAR2
,P_PEO_ATTRIBUTE26 in VARCHAR2
,P_PEO_ATTRIBUTE27 in VARCHAR2
,P_PEO_ATTRIBUTE28 in VARCHAR2
,P_PEO_ATTRIBUTE29 in VARCHAR2
,P_PEO_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_ELIG_TO_PRTE_REASON_BK2.UPDATE_ELIG_TO_PRTE_REASON_B', 10);
hr_utility.set_location(' Leaving: BEN_ELIG_TO_PRTE_REASON_BK2.UPDATE_ELIG_TO_PRTE_REASON_B', 20);
end UPDATE_ELIG_TO_PRTE_REASON_B;
end BEN_ELIG_TO_PRTE_REASON_BK2;

/